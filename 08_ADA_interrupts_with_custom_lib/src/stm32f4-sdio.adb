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

   ----------------
   -- Initialize --
   ----------------

   procedure initialize is
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

   end initialize;


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


end stm32f4.sdio;
