with System.STM32; -- System package
with interfaces; use interfaces;

with stm32f4; use stm32f4;
with stm32f4.periphs;
with stm32f4.usart;
with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_port_access;

package body serial is

   USARTx   : stm32f4.usart.t_USART_periph renames periphs.USART1;
   TX_PIN   : stm32f4.gpio.t_GPIO_pin renames periphs.PB6;
   RX_PIN   : stm32f4.gpio.t_GPIO_pin renames periphs.PB7;

   procedure initialize
   is
   begin

      ------------------------------------------------------------------
      -- USART1 is configured with PB6 (tx) and PB7 (rx) pins
      -- See STM32F407 User Manual, p. 20-23 for every possibilities
      ------------------------------------------------------------------

      --
      -- Enable clocks
      --

      periphs.RCC.AHB1ENR.GPIOBEN  := 1;
      periphs.RCC.APB2ENR.USART1EN := 1;
      
      --
      -- Configure TX and RX pins
      --
      gpio.configure
        (TX_PIN,
         gpio.MODE_AF,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_UP);

      gpio.set_alternate_function
        (TX_PIN,
         gpio.GPIO_AF_USART1);   -- /!\

      gpio.configure
        (RX_PIN,
         gpio.MODE_AF,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_UP);

      gpio.set_alternate_function
        (RX_PIN,
         gpio.GPIO_AF_USART1);   -- /!\

      --
      -- Configure USART
      --

      -- Configuring the baud rate is a tricky part. See RM0090 p. 982-983
      -- for further informations
      declare
         APB2_clock  : unsigned_32;
         baudrate    : constant := 115_200;
         mantissa    : unsigned_32;
         fraction    : unsigned_32;
      begin

         APB2_clock  := System.STM32.System_Clocks.PCLK2;
         mantissa    := APB2_clock / (16 * baudrate);
         fraction    := ((APB2_clock * 25) / (4 * baudrate)) - mantissa * 100;
         fraction    := (fraction * 16) / 100;

         USARTx.BRR.DIV_Mantissa   := uint12 (mantissa);
         USARTx.BRR.DIV_Fraction   := uint4  (fraction);

      end;

      USARTx.CR1.UE     := 1;  -- USART enable
      USARTx.CR1.M      := 1;  -- 1 start bit, 9 data bits
      USARTx.CR2.STOP   := usart.STOP_1;
      USARTx.CR1.TE     := 1; -- Transmitter enable

      -- Odd parity
      USARTx.CR1.PCE    := 1; -- Parity control enable
      USARTx.CR1.PS     := 1; -- Parity selection
                                              -- O: even, 1: odd

      -- No flow control
      USARTx.CR3.RTSE := 0;
      USARTx.CR3.CTSE := 0;

      ENABLED := true;

   end initialize;


   procedure put (c : character)
   is
   begin
      loop
         exit when USARTx.SR.TC = 1;
      end loop;
      USARTx.DR.data := character'pos (c);
   end put;


   procedure put (s : string) 
   is
   begin
      for i in s'range loop
         put (s(i));
      end loop;
   end put;


   procedure new_line
   is
   begin
      put (ASCII.CR & ASCII.LF);
   end new_line;

end serial;

