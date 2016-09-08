with ada.real_time; use ada.real_time;

with stm32f4;
with stm32f4.periphs;
with stm32f4.gpio;
with stm32f4.rcc;
with stm32f4.nvic;
with serial;

package body stm32f4.sdio is

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
      periphs.RCC.APB2ENR.SDIOEN := true;
      periphs.RCC.AHB1ENR.DMA2EN := true;

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

      nvic.set_priority (nvic.SDIO, 0);
      nvic.enable_irq (nvic.SDIO);

   end initialize;


   procedure set_dma_transfer
     (dma_controller : in out dma.t_dma_controller;
      stream         : dma.t_dma_stream_index;
      direction      : dma.t_transfer_dir;
      memory         : byte_array)
   is
   begin

      -- Aligment should be on word * burst size bytes
      if to_word (memory(memory'first)'address) mod 16 /= 0 then
         serial.put_line ("set_dma_transfer: unaligned buffer");
         raise program_error;
      end if;

      -- Reset the stream
      if dma_controller.streams(stream).CR.EN  then
         dma_controller.streams(stream).CR.EN := false;
         loop
            exit when dma_controller.streams(stream).CR.EN = false;
         end loop;
      end if;

      -- Clear interrupts flags
      dma.clear_interrupt_flags (dma_controller, stream);

      -- Transfer direction 
      dma_controller.streams(stream).CR.DIR  := direction;

      -- Peripheral FIFO address
      dma_controller.streams(stream).PAR  := to_word
        (periphs.SDIO_CARD.FIFO'address);

      -- Memory address
      dma_controller.streams(stream).M0AR := to_word (memory'address);

      -- Total number of items (words) to be tranferred
      dma_controller.streams(stream).NDTR.NDT := short (memory'size / 8) / 4;

      -- Select the DMA channel 
      dma_controller.streams(stream).CR.CHSEL := 4; -- Channel 4

      -- Flow controler
      dma_controller.streams(stream).CR.PFCTRL 
         := dma.PERIPH_FLOW_CONTROLLER;

      -- Priority
      dma_controller.streams(stream).CR.PL   := dma.HIGH;

      -- Items size
      dma_controller.streams(stream).CR.MSIZE   := dma.TRANSFER_WORD;
      dma_controller.streams(stream).CR.PSIZE   := dma.TRANSFER_WORD;
      dma_controller.streams(stream).CR.MINC    := true;

      -- Disabling the Increment mode useful because the peripheral source
      -- is accessed through a single register.
      dma_controller.streams(stream).CR.PINC    := false;

      dma_controller.streams(stream).CR.PINCOS  := dma.INCREMENT_PSIZE;
      
      -- DMA bursts
      dma_controller.streams(stream).CR.PBURST  := dma.INCR_4_BEATS;
      dma_controller.streams(stream).CR.MBURST  := dma.INCR_4_BEATS;

      -- FIFO mode
      dma_controller.streams(stream).FCR.DMDIS  := 1;

      -- FIFO threshold
      dma_controller.streams(stream).FCR.FTH    := dma.FIFO_FULL;

      -- FIFO error interrupt enable
      dma_controller.streams(stream).FCR.FIFO_ERROR            := true;
      dma_controller.streams(stream).CR.DIRECT_MODE_ERROR      := true;
      dma_controller.streams(stream).CR.TRANSFER_ERROR         := true;
      dma_controller.streams(stream).CR.HALF_TRANSFER_COMPLETE := false;
      dma_controller.streams(stream).CR.TRANSFER_COMPLETE      := true;

      declare
         irq : constant nvic.interrupt :=
            dma.get_irq_number (dma_controller, stream);
      begin
         nvic.set_priority (irq, 0);
         nvic.enable_irq (irq);
      end;

   end set_dma_transfer;


end stm32f4.sdio;
