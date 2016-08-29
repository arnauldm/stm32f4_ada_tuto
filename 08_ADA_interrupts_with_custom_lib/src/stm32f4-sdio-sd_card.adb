with ada.interrupts.names;
with ada.real_time; use ada.real_time;
with stm32f4.periphs;
with stm32f4.dma.interrupts;
with stm32f4.sdio.interrupts;
with serial;

package body stm32f4.sdio.sd_card is

   DEBUG    : constant boolean := true;

   DMA_mem_to_sdio_handler : 
      dma.interrupts.handler
        (controller  => stm32f4.periphs.DMA2'access,
         stream      => 3,
         IRQ         => Ada.Interrupts.Names.DMA2_Stream3_Interrupt);

   DMA_sdio_to_mem_handler : 
      dma.interrupts.handler
        (controller  => stm32f4.periphs.DMA2'access,
         stream      => 6,
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
           (VDD_3_DOT_3 => true, CCS => SDHC_or_SDXC, power_up => 0,
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

      send_command (CMD2, 0, sdio.LONG_RESPONSE, sdio_status, success);

      if not success then
         goto bad_return;
      end if;
         
      sd_card.cid := to_cid (get_long_response);

      --
      -- Ask the card to publish a new relative RCA address 
      --

      send_command (CMD3, 0, sdio.SHORT_RESPONSE, sdio_status, success);

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
      -- Select the detected SD card
      --

      serial.put_line ("SELECT_CARD (CMD7)"); 
      send_command (CMD7, sd_card.id, sdio.SHORT_RESPONSE, sdio_status, success);

      if not success then
         goto bad_return;
      end if;

      --
      -- Set 4-bit bus transfer
      --

      -- Note: defines the data bus width (2#00# = 1 bit or 2#10# = 4 bits bus)
      -- to be used for data transfer.
      send_app_command
        (sd_card.id, ACMD6, 2#10#, sdio.SHORT_RESPONSE, sdio_status, success);
      
      if not success then
         goto bad_return;
      end if;

      --
      -- Now use the card to nominal speed
      --

      delay until ada.real_time.clock + ada.real_time.microseconds (1);
      periphs.SDIO_CARD.CLKCR.CLKDIV   := 0;

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
      function to_mask is new ada.unchecked_conversion
        (word, sdio.t_SDIO_MASK);
      function to_word is new ada.unchecked_conversion
        (sdio.t_SDIO_RESPx, word);
      function to_word is new ada.unchecked_conversion
        (sdio.t_SDIO_RESPCMD, word);
      cmd : sdio.t_SDIO_CMD;
   begin

      cmd := periphs.SDIO_CARD.CMD;

      -- Clear status flags (cf. default value)
      periphs.SDIO_CARD.ICR  := (others => <>);

      -- Clear interrupts
      periphs.SDIO_CARD.MASK := to_mask (0);

      -- Set the command parameters
      periphs.SDIO_CARD.ARG   := argument;
      cmd.CMDINDEX            := cmd_index;
      cmd.WAITRESP            := response_type;
      cmd.CPSMEN              := 1;

      -- SDIO card host enabled to send a command
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
         serial.put_line
           ("RESPCMD: " & word'image (to_word (periphs.SDIO_CARD.RESPCMD)) &
            ", RESP1: " & word'image (to_word (periphs.SDIO_CARD.RESP1))   &
            ", RESP2: " & word'image (to_word (periphs.SDIO_CARD.RESP2))   &
            ", RESP3: " & word'image (to_word (periphs.SDIO_CARD.RESP3))   &
            ", RESP4: " & word'image (to_word (periphs.SDIO_CARD.RESP4)));
      end if;

      -- Timeout error
      if periphs.SDIO_CARD.STATUS.CTIMEOUT then
         serial.put_line ("timeout");
         success := false;
         return;
      end if;

      -- CRC fail
      if periphs.SDIO_CARD.STATUS.CCRCFAIL then
         if cmd_index = CMD1 or cmd_index = CMD5 then
            null;
         else
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
        (CMD55, cmd55_arg, sdio.SHORT_RESPONSE, status, success);

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


   --------------
   -- Transfer --
   --------------

   --
   -- Read 512 bytes blocks
   --

   procedure read_blocks
     (bl_num   : in  word;       -- block number
      output   : out byte_array;  -- output
      success  : out boolean)
   is
      sdio_status    : sdio.t_SDIO_STA;
      n_blocks       : positive;
      bl_addr        : word;
      idx            : natural;
   begin

      -- Important notes :
      -- 1) SDSC Card (CCS=0) uses byte unit address and SDHC and SDXC Cards
      --    (CCS=1) use block unit address (512 Bytes unit).
      -- 2) In the case of SDHC and SDXC Cards, block length set by CMD16
      --    command does not affect memory read and write commands. Always 512
      --    bytes fixed block length is used. 

      if sd_card.ccs = SDHC_or_SDXC then
         bl_addr  := bl_num;
      else
         -- SDSC
         bl_addr  := bl_num * 512;

         send_command
           (CMD16_SET_BLOCKLEN, 512, sdio.SHORT_RESPONSE, sdio_status,
            success);

         if not success then
            serial.put ("error: read_blocks: SET_BLOCKLEN failure");
            return;
         end if;
      end if;

      periphs.SDIO_CARD.DLEN.DATALENGTH := output'length;

      periphs.SDIO_CARD.DCTRL :=
        (DTEN        => 1,
         DTDIR       => TO_HOST,
         DTMODE      => MODE_BLOCK,
         DMAEN       => 0,
         DBLOCKSIZE  => BLOCK_512BYTES,
         others      => <>);

      --
      -- Sending data read command
      --

      -- Reading how many blocks ?
      n_blocks := output'length / 512;

      if n_blocks > 1 then

         send_command (CMD18_READ_MULTIPLE_BLOCK, bl_addr,
            sdio.SHORT_RESPONSE, sdio_status, success);

         if not success then
            serial.put ("error: read_blocks: READ_MULTIPLE_BLOCK failure");
            return;
         end if;

      else

         send_command (CMD17_READ_SINGLE_BLOCK, bl_addr,
            sdio.SHORT_RESPONSE, sdio_status, success);

         if not success then
            serial.put ("error: read_blocks: READ_SINGLE_BLOCK failure");
            return;
         end if;

      end if;

      --
      -- Polling flags and reading datas
      --

      idx   := output'first;

      while
         not periphs.SDIO_CARD.STATUS.DCRCFAIL and -- data CRC failed
         not periphs.SDIO_CARD.STATUS.DTIMEOUT and -- data timeout
         not periphs.SDIO_CARD.STATUS.RXOVERR  and -- FIFO error
         not periphs.SDIO_CARD.STATUS.DATAEND      -- data end
      loop

         declare
            subtype quad is byte_array (1 .. 4);
            function to_4_bytes is new ada.unchecked_conversion
              (word, quad);
         begin
            for i in periphs.SDIO_CARD.FIFO'range loop
               output (idx .. idx + 3) := to_4_bytes (periphs.SDIO_CARD.FIFO (i));
               idx := idx + 4;
            end loop;
         end;

      end loop;

   end read_blocks;


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

      set_dma_transfer
        (DMA_controller => periphs.DMA2,
         stream         => 6,
         direction      => dma.PERIPHERAL_TO_MEMORY,
         memory         => output);

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

      periphs.SDIO_CARD.DLEN.DATALENGTH := output'length;

      periphs.SDIO_CARD.DCTRL :=
        (DTEN        => 1,
         DTDIR       => TO_HOST,
         DTMODE      => MODE_BLOCK,
         DMAEN       => 1, -- DMA enable
         DBLOCKSIZE  => BLOCK_512BYTES,
         others      => <>);

      if output'length / 512 > 1 then

         send_command (CMD18_READ_MULTIPLE_BLOCK, bl_addr,
            sdio.SHORT_RESPONSE, sdio_status, success);

         if not success then
            serial.put ("error: read_blocks_dma: READ_MULTIPLE_BLOCK failure");
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


      periphs.DMA2.streams(6).CR.EN := 1;

      loop

         -- 
         -- DMA interrupt
         -- 

         DMA_sdio_to_mem_handler.has_been_interrupted (interrupted);

         if interrupted then
            dma_interrupt_status := DMA_sdio_to_mem_handler.get_saved_ISR;

            if dma_interrupt_status.FIFO_ERROR then
               serial.put_line ("FIFO error");
            end if;

            if dma_interrupt_status.DIRECT_MODE_ERROR then
               serial.put_line ("Direct mode error");
            end if;

            if dma_interrupt_status.TRANSFER_ERROR then
               serial.put_line ("Transfer error");
            end if;

            if dma_interrupt_status.HALF_TRANSFER_COMPLETE then
               serial.put_line ("Half transfer"); 
            end if;

            if dma_interrupt_status.TRANSFER_COMPLETE then
               serial.put_line ("Transfer complete");
               exit;
            end if;

         end if;
         
         -- 
         -- SDIO interrupt
         -- 

         sdio.interrupts.handler.has_been_interrupted (interrupted);

         if interrupted then
            sdio_status := sdio.interrupts.handler.get_saved_status;

            if periphs.SDIO_CARD.STATUS.DATAEND then
               exit;
            else
               serial.put_line ("SDIO interrupt: unexpected error!");
            end if;
         end if;

      end loop;

   end read_blocks_dma;


end stm32f4.sdio.sd_card;
