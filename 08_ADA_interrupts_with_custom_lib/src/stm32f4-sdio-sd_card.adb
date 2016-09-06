with ada.interrupts.names;
with stm32f4.periphs;
with stm32f4.dma.interrupts;
with stm32f4.sdio.interrupts;
with serial;

package body stm32f4.sdio.sd_card is

   DEBUG    : constant boolean := true;

   stream_memory_to_sdio : constant dma.t_dma_stream_index := 3;
   stream_sdio_to_memory : constant dma.t_dma_stream_index := 6;

   dma_handler_memory_to_sdio : 
      dma.interrupts.handler
        (controller  => stm32f4.periphs.DMA2'access,
         stream      => stream_memory_to_sdio,
         IRQ         => Ada.Interrupts.Names.DMA2_Stream3_Interrupt);

   dma_handler_sdio_to_memory : 
      dma.interrupts.handler
        (controller  => stm32f4.periphs.DMA2'access,
         stream      => stream_sdio_to_memory,
         IRQ         => Ada.Interrupts.Names.DMA2_Stream6_Interrupt);

   type t_sd_card is record
      ccs   : t_CCS;    -- Card Capacity Status
      ocr   : t_OCR;    -- Operating Condition Register
      cid   : t_CID;    -- Card IDentification register 

      -- Relative Card Address (RCA) formatted to fit in the SDIO_ARG
      -- register 
      id    : sdio.t_SDIO_ARG;
   end record;

   sd_card : t_sd_card;

   ----------------
   -- Initialize --
   ----------------

   procedure initialize is

      function to_sdio_arg is new ada.unchecked_conversion
        (t_OCR, sdio.t_SDIO_ARG);

      success     : boolean;
      sdio_status : sdio.t_SDIO_STA;

   begin

      ------------------------
      -- Low level settings --
      ------------------------

      -- Set up GPIO pins, clocks and irqs
      sdio.initialize;

      ---------------------------------
      -- Card identification process --
      ---------------------------------

      send_command (CMD0_GO_IDLE_STATE, 0, sdio.NO_RESPONSE, sdio_status,
         success);

      if not success then
         goto bad_return;
      end if;

      --
      -- Is it an SD memory card version 2.00 or later ?
      --

      --  Argument [31:12]: reserved, shall be set to '0'
      --           [11:8]:  Supply voltage (VHS) 0x1 (range: 2.7-3.6V)
      --           [7:0]:   Check Pattern 

      send_command (CMD8_SEND_IF_COND, 16#1AA#, sdio.SHORT_RESPONSE,
         sdio_status, success);

      if not success then
         serial.put_line
           ("No SD memory card OR v1.x SD memory card OR voltage mismatch");
         goto bad_return;
      end if;

      if get_short_response /= 16#1AA# then
         serial.put_line ("Unusable card");
         goto bad_return;
      end if;

      --
      -- Set voltage and detect SD type
      --

      for i in 1 .. 100 loop
         sd_card.ocr :=
           (VDD_3_DOT_3 => true,
            VDD_1_DOT_8 => false,
            CCS         => SDHC_or_SDXC,
            power_up    => 0,
            others => <>);

         -- ACMD41 expect an R3 response : failed CRC and wrong RESPCMD must be
         -- ignored!
         send_app_command
           (0, ACMD41_SD_APP_OP_COND, to_sdio_arg (sd_card.ocr),
            sdio.SHORT_RESPONSE, sdio_status, success);

         sd_card.ocr := to_ocr (get_short_response);
         exit when sd_card.ocr.power_up = 1;
      end loop;

      if sd_card.ocr.power_up /= 1 then
         serial.put_line ("Unusable card");
         goto bad_return;
      end if;

      sd_card.ccs := sd_card.ocr.CCS;

      if sd_card.ccs = SDHC_or_SDXC then
         serial.put_line
           ("Ver2.00 or later High Capacity (SDHC) or Extended Capacity SD Memory Card (SDXC)");
      else
         serial.put_line
           ("Ver2.00 or later Standard Capacity SD Memory Card (SDSC)");
      end if;

      --
      -- Asks any card to send their Card ID numbers (CID) on the CMD line 
      --

      send_command (CMD2_ALL_SEND_CID, 0, sdio.LONG_RESPONSE, sdio_status,
         success);

      if not success then
         goto bad_return;
      end if;
         
      sd_card.cid := to_cid (get_long_response);

      --
      -- Ask the card to publish a new relative RCA address 
      --

      send_command (CMD3_SEND_RELATIVE_ADDR, 0, sdio.SHORT_RESPONSE,
         sdio_status, success);

      declare
         function to_sdio_arg is new ada.unchecked_conversion
            (t_RCA, sdio.t_SDIO_ARG);
         rca : constant t_RCA := to_rca (get_short_response);
      begin
         sd_card.id := to_sdio_arg (rca) and 16#FFFF_0000#;
      end;

      if not success then
         goto bad_return;
      end if;

      --
      -- Set 4-bit bus transfer
      --

      -- Select the detected SD card
      send_command (CMD7_SELECT_CARD, sd_card.id, sdio.SHORT_RESPONSE,
         sdio_status, success);

      if not success then
         goto bad_return;
      end if;

      -- Note: defines the data bus width (2#00# = 1 bit or 2#10# = 4 bits bus)
      -- to be used for data transfer.
      send_app_command (sd_card.id, ACMD6_SET_BUS_WIDTH, 2#10#,
         sdio.SHORT_RESPONSE, sdio_status, success);

      if not success then
         goto bad_return;
      end if;

      -- Set the new clock parameters. Now use the card to nominal speed
      declare
         clkcr : t_SDIO_CLKCR := periphs.SDIO_CARD.CLKCR;
      begin
         clkcr.clkdiv := 0;
         clkcr.widbus := WIDBUS_4WIDE_MODE;
         periphs.SDIO_CARD.CLKCR := clkcr;
      end;

      case periphs.SDIO_CARD.CLKCR.WIDBUS is
         when WIDBUS_1WIDE_MODE => serial.put_line ("bus width: 1 bit");
         when WIDBUS_4WIDE_MODE => serial.put_line ("bus width: 4 bit");
         when others => serial.put_line ("bus width: ????");
      end case;

      -- Successful return
      serial.put_line ("SD card initialized");
      return;

   <<bad_return>>
      serial.put_line ("SD card initialization failed!");
      return;

   end initialize;


   ---------------------------------
   -- Send command / Get response --
   ---------------------------------

   procedure send_command
     (cmd_index      : in  sdio.t_cmd_index;
      argument       : in  sdio.t_SDIO_ARG;
      response_type  : in  sdio.t_waitresp;
      status         : out sdio.t_SDIO_STA;
      success        : out boolean)
   is
      function to_word is new ada.unchecked_conversion
        (sdio.t_SDIO_RESPx, word);
      function to_word is new ada.unchecked_conversion
        (sdio.t_SDIO_RESPCMD, word);
      cmd : sdio.t_SDIO_CMD;
   begin

      cmd := periphs.SDIO_CARD.CMD;

      -- Clear status flags (cf. default value)
      periphs.SDIO_CARD.ICR  := (others => CLEAR);

      -- Disable interrupts
      periphs.SDIO_CARD.MASK := (others => false);

      -- Set the command parameters
      periphs.SDIO_CARD.ARG   := argument;
      cmd.CMDINDEX            := cmd_index;
      cmd.WAITRESP            := response_type;
      cmd.CPSMEN              := 1;

      -- /!\ Command is launched here /!\
      periphs.SDIO_CARD.CMD   := cmd;

      -- Block till we get a response
      if response_type = sdio.NO_RESPONSE or
         response_type = sdio.NO_RESPONSE2 
      then
         loop
            exit when periphs.SDIO_CARD.STATUS.CMDSENT  or
                      periphs.SDIO_CARD.STATUS.CTIMEOUT;
         end loop;
      else
         loop
            exit when periphs.SDIO_CARD.STATUS.CMDREND  or
                      periphs.SDIO_CARD.STATUS.CCRCFAIL or
                      periphs.SDIO_CARD.STATUS.CTIMEOUT;
         end loop;
      end if;

      status := periphs.SDIO_CARD.STATUS;

      if DEBUG then
         serial.put
           ("RESPCMD: " & word'image (to_word (periphs.SDIO_CARD.RESPCMD)) &
            ", RESP1: " & word'image (to_word (periphs.SDIO_CARD.RESP1)));
         if response_type = sdio.SHORT_RESPONSE then
            serial.new_line;
         else
            serial.put_line
              (", RESP2: " & word'image (to_word (periphs.SDIO_CARD.RESP2))   &
               ", RESP3: " & word'image (to_word (periphs.SDIO_CARD.RESP3))   &
               ", RESP4: " & word'image (to_word (periphs.SDIO_CARD.RESP4)));
         end if;
      end if;

      -- Timeout error
      if periphs.SDIO_CARD.STATUS.CTIMEOUT then
         serial.put_line ("timeout");
         success := false;
         return;
      end if;

      -- CRC fail
      if periphs.SDIO_CARD.STATUS.CCRCFAIL then
         if cmd_index /= CMD1_SEND_OP_COND and cmd_index /= CMD5_IO_SEND_OP_COND
         then
            serial.put_line ("CRC fail");
            success := false;
            return;
         end if;
      end if;

      success := true;
      
   end send_command;


   procedure send_app_command
     (cmd55_arg      : in  sdio.t_SDIO_ARG;
      cmd_index      : in  sdio.t_cmd_index;
      cmd_arg        : in  sdio.t_SDIO_ARG;
      response_type  : in  sdio.t_waitresp;
      status         : out sdio.t_SDIO_STA;
      success        : out boolean)
   is
      card_status : t_card_status;
   begin

      send_command
        (CMD55_APP_CMD, cmd55_arg, sdio.SHORT_RESPONSE, status, success);

      if not success then
         serial.put_line ("error: CMD55");
         return;
      end if;

      card_status := to_card_status (get_short_response);
      if not card_status.APP_CMD or
         not card_status.READY_FOR_DATA 
      then
         serial.put_line ("unexpected error: CMD55");
         return;
      end if;

      send_command (cmd_index, cmd_arg, response_type, status, success);

   end send_app_command;


   function get_short_response return t_short_response
   is
   begin
      return periphs.SDIO_CARD.RESP1;
   end get_short_response;


   function get_long_response return t_long_response
   is
      response : t_long_response;
   begin
      response.RESP1 := periphs.SDIO_CARD.RESP1;
      response.RESP2 := periphs.SDIO_CARD.RESP2;
      response.RESP3 := periphs.SDIO_CARD.RESP3;
      response.RESP4 := periphs.SDIO_CARD.RESP4;
      return response;
   end get_long_response;


   procedure get_card_status
     (status   : out t_card_status;
      success  : out boolean)
   is
      sdio_status : sdio.t_SDIO_STA; -- ignored
   begin
      send_command (CMD13_SEND_STATUS, sd_card.id, sdio.SHORT_RESPONSE,
         sdio_status, success);
      if not success then
         return;
      end if;
      status := to_card_status (get_short_response);
   end get_card_status;


   --------------
   -- Transfer --
   --------------

   procedure read_blocks_dma
     (bl_num   : in  word;       -- block number
      output   : out byte_array;
      success  : out boolean)
   is
      bl_addr     : word;
      interrupted : boolean;
      dma_interrupt_status : dma.t_DMA_stream_ISR;
      sdio_status          : sdio.t_SDIO_STA;
   begin

      -- 
      -- Setup and enable the DMA stream
      -- 

      set_dma_transfer
        (dma_controller => periphs.DMA2,
         stream         => stream_sdio_to_memory,
         direction      => dma.PERIPHERAL_TO_MEMORY,
         memory         => output);

      periphs.DMA2.streams(stream_sdio_to_memory).CR.EN := true;

      --
      -- Configure the data path
      --

      if sd_card.ccs = SDHC_or_SDXC then
         bl_addr  := bl_num;
      else -- SDSC
         bl_addr  := bl_num * 512;
         send_command
           (CMD16_SET_BLOCKLEN, 512, sdio.SHORT_RESPONSE, sdio_status,
            success);

         if not success then
            serial.put_line ("error: read_blocks: SET_BLOCKLEN");
            return;
         end if;
      end if;

      periphs.SDIO_CARD.DLEN.DATALENGTH := output'length;

      periphs.SDIO_CARD.MASK :=
        (DCRCFAIL => true,
         DTIMEOUT => true,
         RXOVERR  => true,
         DATAEND  => true,
         DBCKEND  => true,
         RXFIFOHF => true,
         RXFIFOF  => true,
         others   => false);

      periphs.SDIO_CARD.DCTRL :=
        (DTEN        => 1,
         DTDIR       => TO_HOST,
         DTMODE      => MODE_BLOCK,
         DMAEN       => 1, -- DMA enable
         DBLOCKSIZE  => BLOCK_512BYTES,
         others      => <>);

      --
      -- Send command
      --

      if output'length > 512 then

         send_command (CMD18_READ_MULTIPLE_BLOCK, bl_addr,
            sdio.SHORT_RESPONSE, sdio_status, success);

         if not success then
            serial.put_line ("error: read_blocks_dma: READ_MULTIPLE_BLOCK");
            return;
         end if;

      else

         send_command (CMD17_READ_SINGLE_BLOCK, bl_addr,
            sdio.SHORT_RESPONSE, sdio_status, success);

         if not success then
            serial.put ("error: read_blocks_dma: READ_SINGLE_BLOCK failure");
            return;
         end if;

      end if;

      --
      -- Loop until interrupted
      --

      loop

         -- 
         -- DMA interrupt
         -- 

         dma_handler_sdio_to_memory.has_been_interrupted (interrupted);

         if interrupted then

            dma_interrupt_status := dma_handler_sdio_to_memory.get_saved_ISR;

            if dma_interrupt_status.TRANSFER_COMPLETE then
               serial.put_line ("DMA: Transfer complete");
               exit;
            elsif dma_interrupt_status.FIFO_ERROR then
               serial.put_line ("DMA: FIFO error");
               exit;
            elsif dma_interrupt_status.DIRECT_MODE_ERROR then
               serial.put_line ("DMA: Direct mode error");
               exit;
            elsif dma_interrupt_status.TRANSFER_ERROR then
               serial.put_line ("DMA: Transfer error");
               exit;
            elsif dma_interrupt_status.HALF_TRANSFER_COMPLETE then
               serial.put_line ("DMA: half transfer complete");
            else
               serial.put_line ("DMA: unknown interrupt");
               raise program_error;
            end if;

         end if;
         
         -- 
         -- SDIO interrupt
         -- 

         sdio.interrupts.handler.has_been_interrupted (interrupted);

         if interrupted then
            serial.put_line ("<SDIO>");
            sdio_status := sdio.interrupts.handler.get_saved_status;

            if periphs.SDIO_CARD.STATUS.DATAEND then
               exit;
            else
               serial.put_line ("SDIO: other interrupt"); 
            end if;
         end if;

      end loop;

   end read_blocks_dma;


   procedure write_blocks_dma
     (bl_num   : in  word;       -- block number
      input    : in  byte_array;
      success  : out boolean)
   is
      ok                   : boolean;
      bl_addr              : word;
      interrupted          : boolean;
      dma_interrupt_status : dma.t_DMA_stream_ISR;
      sdio_status          : sdio.t_SDIO_STA;
      card_status          : t_card_status;
      bytes_transferred    : natural;

      cmd12_finalization   : boolean   := false;
   begin

      --
      -- Wait until the card is ready for data
      --

      loop
         get_card_status (card_status, success);
         if not success then
            return;
         end if;
         exit when card_status.READY_FOR_DATA;
      end loop;

      -- 
      -- Setup and enable the DMA stream
      -- 

      set_dma_transfer
        (dma_controller => periphs.DMA2,
         stream         => stream_memory_to_sdio,
         direction      => dma.MEMORY_TO_PERIPHERAL,
         memory         => input);

      -- SDIO DMA transfers are controlled by the SDIO peripheral. Thus, we can
      -- enable the DMA here without risking to overflow the DMA FIFO 
      periphs.DMA2.streams(stream_memory_to_sdio).CR.EN := true;

      --
      -- Configure the data path
      --

      if sd_card.ccs = SDHC_or_SDXC then
         bl_addr  := bl_num;
      else -- SDSC
         bl_addr  := bl_num * 512;
         send_command
           (CMD16_SET_BLOCKLEN, 512, sdio.SHORT_RESPONSE, sdio_status,
            success);

         if not success then
            serial.put ("error: read_blocks: SET_BLOCKLEN failure");
            return;
         end if;
      end if;

      periphs.SDIO_CARD.DLEN.DATALENGTH := input'length;

      periphs.SDIO_CARD.MASK :=
        (DCRCFAIL => true,
         DTIMEOUT => true,
         TXUNDERR => true,
         DATAEND  => true,
         DBCKEND  => true,
         TXFIFOF  => true,
         others   => false);

      periphs.SDIO_CARD.DCTRL :=
        (DTEN        => 0,
         DTDIR       => TO_CARD,
         DTMODE      => MODE_BLOCK,
         DMAEN       => 1, -- DMA enable
         DBLOCKSIZE  => BLOCK_512BYTES,
         others      => <>);

      --
      -- Send command
      --

      if input'length > 512 then

         send_command (CMD25_WRITE_BLOCKS, bl_addr, sdio.SHORT_RESPONSE,
            sdio_status, success);

         if not success then
            serial.put ("error: write_blocks_dma: WRITE_BLOCKS (CMD25) failure");
            return;
         end if;

      else

         send_command (CMD24_WRITE_BLOCK, bl_addr, sdio.SHORT_RESPONSE,
            sdio_status, success);

         if not success then
            serial.put ("error: write_blocks_dma: WRITE_BLOCK (CMD24) failure");
            return;
         end if;

      end if;

      --
      -- Launch the transfer
      --

      periphs.SDIO_CARD.DCTRL.DTEN := 1;

      --
      -- Loop until interrupted
      --

      loop
         -- 
         -- DMA interrupt
         -- 
         dma_handler_memory_to_sdio.has_been_interrupted (interrupted);

         if interrupted then
            dma_interrupt_status := dma_handler_memory_to_sdio.get_saved_ISR;

            if dma_interrupt_status.TRANSFER_COMPLETE then
               serial.put_line ("DMA: Transfer complete");
               goto ok_return;
            elsif dma_interrupt_status.FIFO_ERROR then
               serial.put_line ("DMA: FIFO error");
               goto bad_return;
            elsif dma_interrupt_status.DIRECT_MODE_ERROR then
               serial.put_line ("DMA: Direct mode error");
               goto bad_return;
            elsif dma_interrupt_status.TRANSFER_ERROR then
               serial.put_line ("DMA: Transfer error");
               goto bad_return;
            else
               serial.put_line ("DMA: unknown interrupt");
               raise program_error;
            end if;
         end if;

         -- 
         -- SDIO interrupt
         -- 
         sdio.interrupts.handler.has_been_interrupted (interrupted);

         if interrupted then
            serial.put_line ("<SDIO>");
            sdio_status := sdio.interrupts.handler.get_saved_status;

            if periphs.SDIO_CARD.STATUS.DATAEND then
               goto ok_return;
            else
               serial.put_line ("SDIO: other interrupt"); 
               goto bad_return;
            end if;
         end if;

      end loop;


   <<bad_return>>
      cmd12_finalization := true;

   <<ok_return>>

      bytes_transferred := natural (16#FFFF# -
         stm32f4.periphs.DMA2.streams(stream_memory_to_sdio).NDTR.NDT)
         * 4;

      if bytes_transferred = input'length then
         success := true;
      else
         serial.put_line
           ("Transferred only" & natural'image (bytes_transferred) & 
            " bytes (" & natural'image (input'length) & " expected)");
         success := false;
      end if;

      if not periphs.SDIO_CARD.STATUS.DBCKEND then
         serial.put_line
           ("DMA transfer complete while SDIO status DBCKEND is set to false");
      end if;

      if cmd12_finalization then
         send_command (CMD12_STOP_TRANSMISSION, 0, sdio.SHORT_RESPONSE,
            sdio_status, ok);
      end if;

   end write_blocks_dma;


end stm32f4.sdio.sd_card;
