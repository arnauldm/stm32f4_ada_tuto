with ada.real_time; use ada.real_time;
with ada.interrupts.names;
with ada.unchecked_conversion;

with stm32f4;
with stm32f4.periphs;
with stm32f4.gpio;
with stm32f4.rcc;
with stm32f4.nvic;
with stm32f4.dma.interrupts;
--with serial;

package body stm32f4.sdio is

   DEBUG    : constant boolean := true;

   outbuf   : byte_array (1 .. 256) := (others => 0);
   inbuf    : byte_array (1 .. 256) := (others => 0);

   DMA_controller : dma.t_DMA_controller renames stm32f4.periphs.DMA2;

   ----------------
   -- Initialize --
   ----------------

   procedure initialize is
      clock_register : t_SDIO_CLKCR;
   begin

      --
      -- Enable the peripherals
      --

      rcc.enable_gpio_clock (periphs.GPIOB);
      rcc.enable_gpio_clock (periphs.GPIOC);
      rcc.enable_gpio_clock (periphs.GPIOD);
      periphs.RCC.APB2ENR.SDIOEN := 1;
      periphs.RCC.AHB1ENR.DMA2EN := 1;

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

      clock_register := periphs.SDIO_CARD.CLKCR;

      -- /!\ RM0090, p. 1025, 1064-1065
      -- . SDIO adapter clock (SDIOCLK) = 48 MHz
      -- . CLKDIV defines the divide factor between the input clock
      --   (SDIOCLK) and the output clock (SDIO_CK) : 
      --      SDIO_CK frequency = SDIOCLK / [CLKDIV + 2]
      -- . While the SD/SDIO card or MultiMediaCard is in identification
      --   mode, the SDIO_CK frequency must be less than 400 kHz.
      clock_register.CLKDIV   := 118;

      -- Default bus mode: SDIO_D0 used (1 bit bus width)
      clock_register.WIDBUS   := WIDBUS_1WIDE_MODE;

      -- The HW flow control functionality is used to avoid FIFO underrun
      -- and overrun errors 
      -- Errata sheet STM: glitches => DCRCFAIL asserted. Do not use.
      clock_register.HWFC_EN  := false;

      -- Errata sheet STM: NEGEDGE=1 (falling) should *not* be used
      clock_register.NEGEDGE  := RISING_EDGE;

      -- Writing params in the register
      periphs.SDIO_CARD.CLKCR := clock_register;
      delay until ada.real_time.clock + ada.real_time.microseconds (1);

      -- The data timeout period in card bus clock periods
      periphs.SDIO_CARD.DTIMER         := 16#FFFF_FFFF#;

      -- Power up the SDIO card
      periphs.SDIO_CARD.POWER.PWRCTRL  := POWER_ON;
      delay until ada.real_time.clock + ada.real_time.microseconds (1);

      -- SDIO_CK is enabled
      periphs.SDIO_CARD.CLKCR.CLKEN    := true;
      delay until ada.real_time.clock + ada.real_time.microseconds (1);

      --
      -- Setup IRQs 
      --

      periphs.SDIO_CARD.MASK :=
        (CCRCFAIL => true,
         DCRCFAIL => true,
         CTIMEOUT => true,
         DTIMEOUT => true,
         TXUNDERR => true,
         RXOVERR  => true,
         DATAEND  => true,
         DBCKEND  => true,
         STBITERR => true,
         RXFIFOHF => true,
         RXFIFOF  => true,
         others => false);

      nvic.enable_irq (nvic.SDIO);

   end initialize;


   procedure set_dma_transfer
     (DMA_controller : in out dma.t_DMA_controller;
      stream         : dma.t_DMA_stream_index;
      direction      : dma.t_data_transfer_dir;
      memory         : byte_array)
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
      dma.clear_interrupt_flags (DMA_controller, stream);

      -- Transfer direction 
      DMA_controller.streams(stream).CR.DIR  := direction;

      -- Peripheral FIFO address
      DMA_controller.streams(stream).PAR  := to_word
        (periphs.SDIO_CARD.FIFO'address);

      -- Memory address
      DMA_controller.streams(stream).M0AR := to_word (memory'address);

      -- Total number of items to be tranferred
      DMA_controller.streams(stream).NDTR.NDT := short (memory'size / 8);

      -- Items size
      DMA_controller.streams(stream).CR.PSIZE   := dma.TRANSFER_WORD;
      DMA_controller.streams(stream).CR.MSIZE   := dma.TRANSFER_WORD;
      DMA_controller.streams(stream).CR.PINC    := true;
      DMA_controller.streams(stream).CR.MINC    := true;
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
      DMA_controller.streams(stream).FCR.FIFO_ERROR            := true;
      DMA_controller.streams(stream).CR.DIRECT_MODE_ERROR      := true;
      DMA_controller.streams(stream).CR.TRANSFER_ERROR         := true;
      DMA_controller.streams(stream).CR.HALF_TRANSFER_COMPLETE := true;
      DMA_controller.streams(stream).CR.TRANSFER_COMPLETE      := true;

      declare
         irq : constant nvic.interrupt :=
            dma.get_irq_number (DMA_controller, stream);
      begin
         nvic.set_priority (irq, 0);
         nvic.enable_irq (irq);
      end;

   end set_dma_transfer;


end stm32f4.sdio;
