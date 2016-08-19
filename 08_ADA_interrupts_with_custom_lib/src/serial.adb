with System.STM32; -- System package

with stm32f4; use stm32f4;
with stm32f4.periphs;
with stm32f4.usart;
with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_port_access;

------------------------------------------------------------------
-- USART1 is configured with PB6 (tx) and PB7 (rx) pins
-- See STM32F407 User Manual, p. 20-23 for every possibilities
------------------------------------------------------------------

-- /!\ Important: gnat zfp and ravenscar profiles already initialize the serial
-- /!\ USART1 on pins PB6 (tx) and PB7 (rx)

package body serial is

   USARTx   : stm32f4.usart.t_USART_periph renames periphs.USART1;
   TX_PIN   : stm32f4.gpio.t_GPIO_pin renames periphs.PB6;
   RX_PIN   : stm32f4.gpio.t_GPIO_pin renames periphs.PB7;

   procedure initialize
   is
   begin

      --
      -- Enable clocks
      --
      periphs.RCC.AHB1ENR.GPIOBEN  := 1;   -- /!\ FIXME
      periphs.RCC.APB2ENR.USART1EN := 1;   -- /!\ FIXME
      
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
         gpio.GPIO_AF_USART1);   -- /!\ FIXME

      gpio.configure
        (RX_PIN,
         gpio.MODE_AF,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_UP);

      gpio.set_alternate_function
        (RX_PIN,
         gpio.GPIO_AF_USART1);   -- /!\ FIXME

      --
      -- Configure USART
      --
      declare
         use stm32f4.usart;
      begin
         usart.configure
           (USARTx'access, 115_200, DATA_9BITS, PARITY_ODD, STOP_1);
      end;

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

