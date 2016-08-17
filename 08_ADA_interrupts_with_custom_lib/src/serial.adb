with System.STM32; -- System package
with interfaces; use interfaces;

with stm32f4; use stm32f4;
with stm32f4.periphs;
with stm32f4.usart;
with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_port_access;

package body serial is

   procedure initialize
   is
   begin

      ------------------------------------------------------------------
      -- USART6 is configured with PC6 (tx) and PC7 (rx) pins
      -- See STM32F407 User Manual, p. 20-23 for every possibilities
      ------------------------------------------------------------------

      --
      -- Enable clocks
      --

      periphs.RCC.AHB1ENR.GPIOCEN  := 1;
      periphs.RCC.APB2ENR.USART6EN := 1;
      
      --
      -- Configure TX and RX pins
      --
      gpio.configure
        (periphs.PC6,
         gpio.MODE_AF,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_UP);

      gpio.set_alternate_function
        (periphs.PC6,
         gpio.GPIO_AF_USART6);

      gpio.configure
        (periphs.PC7,
         gpio.MODE_AF,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_UP);

      gpio.set_alternate_function
        (periphs.PC7,
         gpio.GPIO_AF_USART6);

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

         periphs.USART6.BRR.DIV_Mantissa   := uint12 (mantissa);
         periphs.USART6.BRR.DIV_Fraction   := uint4  (fraction);

      end;

      periphs.USART6.CR1.UE     := 1;  -- USART enable
      periphs.USART6.CR1.M      := 1;  -- 1 start bit, 9 data bits
      periphs.USART6.CR2.STOP   := usart.STOP_1;
      periphs.USART6.CR1.TE     := 1; -- Transmitter enable

      -- Odd parity
      periphs.USART6.CR1.PCE    := 1; -- Parity control enable
      periphs.USART6.CR1.PS     := 1; -- Parity selection
                                              -- O: even, 1: odd

      -- No flow control
      periphs.USART6.CR3.RTSE := 0;
      periphs.USART6.CR3.CTSE := 0;

      ENABLED := true;

   end initialize;


   procedure put (c : character)
   is
   begin
      loop
         exit when periphs.USART6.SR.TC = 1;
      end loop;
      periphs.USART6.DR.data := character'pos (c);
   end put;


   procedure put (s : string) 
   is
   begin
      for i in s'range loop
         put (s(i));
      end loop;
   end put;


end serial;

