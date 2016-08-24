with ada.real_time; use ada.real_time;
with system; use system;
with ada.interrupts.names;
with ada.unchecked_conversion;

with stm32f4;
with stm32f4.periphs;
with stm32f4.gpio;
with stm32f4.rcc;
with stm32f4.nvic;
with stm32f4.dma.interrupts;
with stm32f4.sd;
   use type stm32f4.sd.t_CCS;
with serial;

package body stm32f4.sdio is

   DEBUG    : constant boolean := true;

   outbuf   : byte_array (1 .. 256) := (others => 0);
   inbuf    : byte_array (1 .. 256) := (others => 0);

   DMA_controller : dma.t_DMA_controller renames stm32f4.periphs.DMA2;
   stream_mem_to_sdio : constant dma.t_DMA_stream_index := 3;
   stream_sdio_to_mem : constant dma.t_DMA_stream_index := 6;

   DMA_mem_to_sdio_handler : 
      dma.interrupts.handler
        (DMA_controller'access,
         stream_mem_to_sdio,
         Ada.Interrupts.Names.DMA2_Stream3_Interrupt);

   DMA_sdio_to_mem_handler : 
      dma.interrupts.handler
        (DMA_controller'access,
         stream_sdio_to_mem,
         Ada.Interrupts.Names.DMA2_Stream6_Interrupt);

   type t_sd_card is record
      ccs   : sd.t_CCS;    -- Card Capacity Status
      ocr   : sd.t_OCR;    -- Operating Condition Register
      cid   : sd.t_CID;    -- Card IDentification register 
      -- Relative Card Address (RCA) formatted to fit in the SDIO_ARG
      -- register 
      id    : t_SDIO_ARG;
   end record;

   sd_card : t_sd_card;

   ----------------
   -- Initialize --
   ----------------

   procedure initialize is

      function to_sdio_arg is new ada.unchecked_conversion
        (sd.t_OCR, t_SDIO_ARG);

      success     : boolean;
      sdio_status : t_SDIO_STA;

   begin

      --
      -- Low level settings 
      --

      -- Set up GPIO pins, SDIO clock and also set up interrupt handler
      low_level_init;

      -- Enable DMA
      set_dma;

      --
      -- Card identification process 
      --

      -- Go idle state (CMD0)
      serial.put_line ("GO_IDLE_STATE (CMD0)");
      send_command (CMD0, 0, NO_RESPONSE, sdio_status, success);

      if not success then
         goto bad_return;
      end if;

      -- Initialize SD Memory Cards compliant to the Physical Layer
      -- Specification Version 2.00 or later (CMD8)
      --  Argument:
      --  - [31:12]: reserved, shall be set to '0'
      --  - [11:8]:  Supply voltage (VHS) 0x1 (range: 2.7-3.6V)
      --  - [7:0]:   Check Pattern (recommended 0xAA)
      serial.put_line ("SEND_IF_COND (CMD8)"); 
      send_command (CMD8, 16#1AA#, SHORT_RESPONSE, sdio_status, success);

      if not success then
         serial.put_line
           ("No SD memory card OR v1.x SD memory card OR voltage mismatch");
         goto bad_return;
      end if;

      if get_short_response /= 16#1AA# then
         serial.put_line ("Unusable card");
         goto bad_return;
      end if;

      -- Initialization Command (ACMD41)
      serial.put_line ("SD_APP_OP_COND (ACMD41)");

      for i in 1 .. 100 loop
         sd_card.ocr :=
           (VDD_3_DOT_3 => true, CCS => sd.SDHC_or_SDXC, power_up => 0,
            others => <>);

         -- ACMD41 expect an R3 response : failed CRC and wrong RESPCMD must be
         -- ignored!
         send_app_command
           (0, ACMD41, to_sdio_arg (sd_card.ocr), SHORT_RESPONSE,
            sdio_status, success);

         sd_card.ocr := sd.to_ocr (get_short_response);
         exit when sd_card.ocr.power_up = 1;
      end loop;

      if sd_card.ocr.power_up /= 1 then
         serial.put_line ("Unusable card");
         goto bad_return;
      end if;

      sd_card.ccs := sd_card.ocr.CCS;

      if sd_card.ccs = sd.SDHC_or_SDXC then
         serial.put_line
           ("Ver2.00 or later High Capacity (SDHC) or Extended Capacity SD Memory Card (SDXC)");
      else
         serial.put_line
           ("Ver2.00 or later Standard Capacity SD Memory Card (SDSC)");
      end if;

      -- Asks any card to send the CID numbers on the CMD line (CMD2)
      serial.put_line ("ALL_SEND_CID (CMD2)"); 
      send_command (CMD2, 0, LONG_RESPONSE, sdio_status, success);

      if not success then
         goto bad_return;
      end if;
         
      sd_card.cid := sd.to_cid (get_long_response);

      -- Ask the card to publish a new relative RCA address (CMD3)
      serial.put_line ("SEND_RELATIVE_ADDR (CMD3)"); 
      send_command (CMD3, 0, SHORT_RESPONSE, sdio_status, success);

      declare
         function to_sdio_arg is new ada.unchecked_conversion
            (sd.t_RCA, t_SDIO_ARG);
         rca : constant sd.t_RCA := sd.to_rca (get_short_response);
      begin
         sd_card.id := to_sdio_arg (rca) and 16#FFFF_0000#;
      end;

      if not success then
         goto bad_return;
      end if;

      -- Select the SD card
      serial.put_line ("SELECT_CARD (CMD7)"); 
      send_command (CMD7, sd_card.id, SHORT_RESPONSE, sdio_status, success);

      if not success then
         goto bad_return;
      end if;

      -- Defines the data bus width ('00'=1bit or '10'=4 bits bus) to be used
      -- for data transfer.
      serial.put_line ("SET_BUS_WIDTH (ACMD6)"); 
      send_app_command
        (sd_card.id, ACMD6, 2#10#, SHORT_RESPONSE, sdio_status, success);
      
      if not success then
         goto bad_return;
      end if;

      -- Now use the card to nominal speed
      serial.put_line ("Change clock speed");
      delay until ada.real_time.clock + ada.real_time.microseconds (1);
      periphs.SDIO_CARD.CLKCR.CLKDIV   := 0;

   <<ok_return>>
      serial.put_line ("SD card initialized");
      return;

   <<bad_return>>
      serial.put_line ("SD card initialization failed!");
      return;

   end initialize;


   procedure low_level_init is
   begin

      --
      -- Enable the peripherals
      --

      rcc.enable_gpio_clock (periphs.GPIOB);
      rcc.enable_gpio_clock (periphs.GPIOC);
      rcc.enable_gpio_clock (periphs.GPIOD);
      periphs.RCC.APB2ENR.SDIOEN := 1;

      --
      -- Setup GPIO pins
      --

      -- SDIO_D0 pin
      gpio.configure (periphs.SDIO_D0,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.FLOATING);
      gpio.set_alternate_function (periphs.SDIO_D0, gpio.GPIO_AF_SDIO);

      -- SDIO_D1 pin
      gpio.configure (periphs.SDIO_D1,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.FLOATING);
      gpio.set_alternate_function (periphs.SDIO_D1, gpio.GPIO_AF_SDIO);

      -- SDIO_D2 pin
      gpio.configure (periphs.SDIO_D2,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.FLOATING);
      gpio.set_alternate_function (periphs.SDIO_D2, gpio.GPIO_AF_SDIO);

      -- SDIO_D3 pin
      gpio.configure (periphs.SDIO_D3,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.FLOATING);
      gpio.set_alternate_function (periphs.SDIO_D3, gpio.GPIO_AF_SDIO);

      -- SDIO_CK pin
      gpio.configure (periphs.SDIO_CK,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.FLOATING);
      gpio.set_alternate_function (periphs.SDIO_CK, gpio.GPIO_AF_SDIO);

      -- SDIO_CMD pin
      -- /!\ SDIO_CMD has two operational modes (RM0090, p. 1025) :
      --  . Open-drain for initialization (only for MMCV3.31 or previous)
      --  . Push-pull for command transfer (SD/SD I/O card MMC4.2 use
      --    push-pull drivers also for initialization)
      gpio.configure (periphs.SDIO_CMD,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.FLOATING);

      gpio.set_alternate_function (periphs.SDIO_CMD, gpio.GPIO_AF_SDIO);

      --
      -- SDIO clock
      --

      periphs.SDIO_CARD.POWER.PWRCTRL  := POWER_OFF;
      delay until ada.real_time.clock + ada.real_time.microseconds (1);

      -- /!\ RM0090, p. 1025, 1064-1065
      -- . SDIO adapter clock (SDIOCLK) = 48 MHz
      -- . CLKDIV defines the divide factor between the input clock
      --   (SDIOCLK) and the output clock (SDIO_CK) : 
      --      SDIO_CK frequency = SDIOCLK / [CLKDIV + 2]
      -- . While the SD/SDIO card or MultiMediaCard is in identification
      --   mode, the SDIO_CK frequency must be less than 400 kHz.
      periphs.SDIO_CARD.CLKCR.CLKDIV   := 118;

      -- Default bus mode: SDIO_D0 used (1 bit bus width)
      periphs.SDIO_CARD.CLKCR.WIDBUS   := WIDBUS_1WIDE_MODE;

      -- The HW flow control functionality is used to avoid FIFO underrun
      -- and overrun errors 
      -- Errata sheet STM: glitches => DCRCFAIL asserted. Do not use.
      periphs.SDIO_CARD.CLKCR.HWFC_EN  := 0;

      -- Errata sheet STM: NEGEDGE=1 (falling) should *not* be used
      periphs.SDIO_CARD.CLKCR.NEGEDGE  := RISING_EDGE;

      -- The data timeout period in card bus clock periods
      periphs.SDIO_CARD.DTIMER         := 16#FFFF_FFFF#;

      -- Power up the SDIO card
      periphs.SDIO_CARD.POWER.PWRCTRL  := POWER_ON;
      delay until ada.real_time.clock + ada.real_time.microseconds (1);

      -- SDIO_CK is enabled
      periphs.SDIO_CARD.CLKCR.CLKEN    := 1;
      delay until ada.real_time.clock + ada.real_time.microseconds (1);

      --
      -- Setup IRQs 
      --

      declare
         function to_mask is new ada.unchecked_conversion
           (word, t_SDIO_MASK);
      begin
         periphs.SDIO_CARD.MASK := to_mask (0);
      end;

      periphs.SDIO_CARD.MASK.CCRCFAILIE   := 1; -- Command CRC fail
      periphs.SDIO_CARD.MASK.DCRCFAILIE   := 1; -- Data CRC fail
      periphs.SDIO_CARD.MASK.CTIMEOUTIE   := 1; -- Command timeout
      periphs.SDIO_CARD.MASK.DTIMEOUTIE   := 1; -- Data timeout
      periphs.SDIO_CARD.MASK.TXUNDERRIE   := 1; -- Tx FIFO underrun error
      periphs.SDIO_CARD.MASK.RXOVERRIE    := 1; -- Rx FIFO overrun error
      periphs.SDIO_CARD.MASK.CMDRENDIE    := 1; -- Command response received
      periphs.SDIO_CARD.MASK.CMDSENTIE    := 1; -- Command sent
      periphs.SDIO_CARD.MASK.DATAENDIE    := 1; -- Data end
      periphs.SDIO_CARD.MASK.STBITERRIE   := 1; -- Start bit error
      periphs.SDIO_CARD.MASK.DBCKENDIE    := 1; -- Data block end
      periphs.SDIO_CARD.MASK.CMDACTIE     := 1; -- Command acting 

      periphs.NVIC.ISER1.irq(nvic.SDIO)   := nvic.IRQ_ENABLED;

   end low_level_init;


   procedure set_dma
   is
   begin
      periphs.RCC.AHB1ENR.DMA2EN := 1;
   end set_dma;


   ---------------------------------
   -- Send command / Get response --
   ---------------------------------

   procedure send_command
     (cmd_index      : in  t_cmd_index;
      argument       : in  t_SDIO_ARG;
      response_type  : in  t_waitresp;
      status         : out t_SDIO_STA;
      success        : out boolean)
   is
      function to_mask is new ada.unchecked_conversion
        (word, t_SDIO_MASK);
      function to_word is new ada.unchecked_conversion
        (t_SDIO_RESPx, word);
      function to_word is new ada.unchecked_conversion
        (t_SDIO_RESPCMD, word);
      cmd : t_SDIO_CMD;
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
      if response_type = NO_RESPONSE or
         response_type = NO_RESPONSE2 
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
     (cmd55_arg      : in  t_SDIO_ARG;
      cmd_index      : in  t_cmd_index;
      cmd_arg        : in  t_SDIO_ARG;
      response_type  : in  t_waitresp;
      status         : out t_SDIO_STA;
      success        : out boolean)
   is
      card_status : sd.t_card_status;
   begin

      send_command
        (CMD55, cmd55_arg, SHORT_RESPONSE, status, success);

      if not success then
         serial.put_line ("error: CMD55");
         return;
      end if;

      card_status := sd.to_card_status (get_short_response);
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

   procedure set_dma_transfer
     (DMA_controller : in out dma.t_DMA_controller;
      stream         : dma.t_DMA_stream_index;
      direction      : dma.t_data_transfer_dir;
      memory         : byte_array_access)
   is
   begin

      -- Reset the stream
      if (DMA_controller.streams(stream).CR.EN = 1) then
         DMA_controller.streams(stream).CR.EN := 0;
         loop
            exit when DMA_controller.streams(stream).CR.EN = 0;
         end loop;
      end if;

      -- Clear interrupts flags
      dma.clear_stream_interrupts (DMA_controller, stream);

      -- Transfer direction 
      DMA_controller.streams(stream).CR.DIR  := direction;

      -- Peripheral FIFO address
      DMA_controller.streams(stream).PAR  := to_word
        (periphs.SDIO_CARD.FIFO'address);

      -- Memory address
      DMA_controller.streams(stream).M0AR := to_word (memory.all'address);

      -- Total number of items to be tranferred
      DMA_controller.streams(stream).NDTR.NDT := short (memory.all'size / 8);

      -- Items size
      DMA_controller.streams(stream).CR.PSIZE   := dma.TRANSFER_BYTE;
      DMA_controller.streams(stream).CR.MSIZE   := dma.TRANSFER_BYTE;
      DMA_controller.streams(stream).CR.PINC    := 1;
      DMA_controller.streams(stream).CR.MINC    := 1;
      DMA_controller.streams(stream).CR.PINCOS  := dma.INCREMENT_PSIZE;
      
      -- Select the DMA channel 
      DMA_controller.streams(stream).CR.CHSEL := 4; -- Channel 4

      -- Flow controler
      DMA_controller.streams(stream).CR.PFCTRL 
         := dma.DMA_FLOW_CONTROLLER;

      -- Priority
      DMA_controller.streams(stream).CR.PL   := dma.HIGH;

      -- DMA bursts
      DMA_controller.streams(stream).CR.PBURST  := dma.INCR_4_BEATS;
      DMA_controller.streams(stream).CR.MBURST  := dma.INCR_4_BEATS;

      -- FIFO mode
      DMA_controller.streams(stream).FCR.DMDIS  := 1;

      -- FIFO threshold
      DMA_controller.streams(stream).FCR.FTH    := dma.FIFO_FULL;

      -- FIFO error interrupt enable
      DMA_controller.streams(stream).FCR.FEIE   := 1;
      DMA_controller.streams(stream).CR.DMEIE   := 1;
      DMA_controller.streams(stream).CR.TEIE    := 1;
      DMA_controller.streams(stream).CR.HTIE    := 1;
      DMA_controller.streams(stream).CR.TCIE    := 1;

      declare
         irq : nvic.interrupt;
      begin
         if DMA_controller'address = periphs.DMA1'address then
            case stream is
               when 0 => irq := nvic.DMA1_Stream_0;
               when 1 => irq := nvic.DMA1_Stream_1;
               when 2 => irq := nvic.DMA1_Stream_2;
               when 3 => irq := nvic.DMA1_Stream_3;
               when 4 => irq := nvic.DMA1_Stream_4;
               when 5 => irq := nvic.DMA1_Stream_5;
               when 6 => irq := nvic.DMA1_Stream_6;
               when 7 => irq := nvic.DMA1_Stream_7;
            end case;
         elsif DMA_controller'address = periphs.DMA2'address then
            case stream is
               when 0 => irq := nvic.DMA2_Stream_0;
               when 1 => irq := nvic.DMA2_Stream_1;
               when 2 => irq := nvic.DMA2_Stream_2;
               when 3 => irq := nvic.DMA2_Stream_3;
               when 4 => irq := nvic.DMA2_Stream_4;
               when 5 => irq := nvic.DMA2_Stream_5;
               when 6 => irq := nvic.DMA2_Stream_6;
               when 7 => irq := nvic.DMA2_Stream_7;
            end case;
         else
            raise program_error;
         end if;

         periphs.NVIC.IPR(irq).priority   := 0;
         periphs.NVIC.ISER1.irq(irq)      := nvic.IRQ_ENABLED;
      end;

   end set_dma_transfer;


--      set_dma_transfer (DMA_controller, stream_mem_to_sdio,
--         dma.MEMORY_TO_PERIPHERAL, outbuf'access);
--
--      set_dma_transfer (DMA_controller, stream_sdio_to_mem,
--         dma.PERIPHERAL_TO_MEMORY, inbuf'access);

--      -- Get card status
--      serial.put_line ("CMD13"); 
--      send_command (CMD13, sd.to_sdio_arg (sd_card.rca), SHORT_RESPONSE,
--         sdio_status, success);
--      sd_card.card_status := sd.to_card_status (get_short_response);


end stm32f4.sdio;
