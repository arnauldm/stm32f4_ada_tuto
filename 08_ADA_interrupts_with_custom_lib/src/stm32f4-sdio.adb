with ada.unchecked_conversion;

with stm32f4;
with stm32f4.periphs;
with stm32f4.gpio;
with stm32f4.rcc;
with stm32f4.nvic;

package body stm32f4.sdio is

   ---------------------------------------
   -- Command path state machine (CPSM) --
   ---------------------------------------

   type t_CPSM is
     (CPSM_IDLE,
      CPSM_PEND,
      CPSM_SEND,
      CPSM_WAIT,
      CPSM_RECEIVE,
      CPSM_WAIT_CPL);

   CPSM : t_CPSM;

   ------------------------------------
   -- Data path state machine (DPSM) --
   ------------------------------------

   type t_DPSM is
     (DPSM_IDLE,
      DPSM_BUSY,
      DPSM_SEND,
      DPSM_WAIT_S,
      DPSM_WAIT_R,
      DPSM_RECEIVE,
      DPSM_READ_WAIT);

   DPSM : t_DPSM;

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
      periphs.RCC.APB2ENR.SDIOEN := 1;

      --
      -- Setup GPIO pins
      --

      -- SDIO_D0
      gpio.configure (periphs.SDIO_D0,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_VERY_HIGH, gpio.FLOATING);
      gpio.set_alternate_function (periphs.SDIO_D0, gpio.GPIO_AF_SDIO);

      -- SDIO_D1
      gpio.configure (periphs.SDIO_D1,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_VERY_HIGH, gpio.FLOATING);
      gpio.set_alternate_function (periphs.SDIO_D1, gpio.GPIO_AF_SDIO);

      -- SDIO_D2
      gpio.configure (periphs.SDIO_D2,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_VERY_HIGH, gpio.FLOATING);
      gpio.set_alternate_function (periphs.SDIO_D2, gpio.GPIO_AF_SDIO);

      -- SDIO_D3
      gpio.configure (periphs.SDIO_D3,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_VERY_HIGH, gpio.FLOATING);
      gpio.set_alternate_function (periphs.SDIO_D3, gpio.GPIO_AF_SDIO);

      -- SDIO_CK
      gpio.configure (periphs.SDIO_CK,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.FLOATING);
      gpio.set_alternate_function (periphs.SDIO_CK, gpio.GPIO_AF_SDIO);

      -- SDIO_CMD

      -- /!\ RM0090, p. 1025
      -- SDIO_CMD has two operational modes:
      --  . Open-drain for initialization (only for MMCV3.31 or previous)
      --  . Push-pull for command transfer (SD/SD I/O card MMC4.2 use
      --    push-pull drivers also for initialization)
      gpio.configure (periphs.SDIO_CMD,
         gpio.MODE_AF, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.FLOATING);

      gpio.set_alternate_function (periphs.SDIO_CMD, gpio.GPIO_AF_SDIO);

      -- 
      -- Data/Command path state machine
      -- 

      CPSM := CPSM_IDLE;
      DPSM := DPSM_IDLE;

      --
      -- SDIO clock
      --

      -- /!\ RM0090, p. 1025, 1064-1065
      -- . SDIO adapter clock (SDIOCLK = 48 MHz)
      -- . CLKDIV defines the divide factor between the input clock
      --   (SDIOCLK) and the output clock (SDIO_CK): 
      --      SDIO_CK frequency = SDIOCLK / [CLKDIV + 2]
      -- . While the SD/SDIO card or MultiMediaCard is in identification
      --   mode, the SDIO_CK frequency must be less than 400 kHz.
      periphs.SDIO_CARD.CLKCR.CLKDIV   := 118;

      -- Default bus mode: SDIO_D0 used
      periphs.SDIO_CARD.CLKCR.WIDBUS   := WIDBUS_1WIDE_MODE;

      -- The HW flow control functionality is used to avoid FIFO underrun
      -- and overrun errors 
      periphs.SDIO_CARD.CLKCR.HWFC_EN  := 1;

      -- Power-on: the card is clocked
      periphs.SDIO_CARD.POWER.PWRCTRL  := POWER_ON;

      -- SDIO_CK is enabled
      periphs.SDIO_CARD.CLKCR.CLKEN    := 1;

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

      stm32f4.periphs.NVIC.ISER0.irq(stm32f4.nvic.SDIO)
         := stm32f4.nvic.IRQ_ENABLED;

   end initialize;

end stm32f4.sdio;
