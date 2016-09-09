with system; use system;
with stm32f4; use stm32f4;
with stm32f4.periphs;
with stm32f4.usart;
with stm32f4.rcc;
with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_port_access;

------------------------------------------------------------------
-- USART1 is configured with PB6 (tx) and PB7 (rx) pins
-- See STM32F407 User Manual, p. 20-23 for every possibilities
------------------------------------------------------------------

-- /!\ Important: gnat zfp and ravenscar profiles already initialize the serial
-- /!\ USART1 on pins PB6 (tx) and PB7 (rx)

package body serial is

   USARTx   : stm32f4.usart.t_USART_periph renames periphs.USART3;
   TX_pin   : stm32f4.gpio.t_GPIO_pin      renames periphs.USART3_TX;
   RX_pin   : stm32f4.gpio.t_GPIO_pin      renames periphs.USART3_RX;

   procedure initialize
   is
      alternate_function : gpio.t_AF;
   begin

      --
      -- Enable clocks
      --

      rcc.enable_gpio_clock (TX_pin);
      rcc.enable_gpio_clock (RX_pin);

      if USARTx'address = periphs.USART1_base then
         periphs.RCC.APB2ENR.USART1EN  := true;
      elsif USARTx'address = periphs.USART2_base then
         periphs.RCC.APB1ENR.USART2EN  := true;
      elsif USARTx'address = periphs.USART3_base then
         periphs.RCC.APB1ENR.USART3EN  := true;
      elsif USARTx'address = periphs.UART4_base then
         periphs.RCC.APB1ENR.UART4EN   := true;
      elsif USARTx'address = periphs.UART5_base then
         periphs.RCC.APB1ENR.UART5EN   := true;
      elsif USARTx'address = periphs.USART6_base then
         periphs.RCC.APB2ENR.USART6EN  := true; 
      else
         raise program_error;
      end if;

      
      --
      -- Configure TX and RX pins
      --
      gpio.configure
        (TX_pin,
         gpio.MODE_AF,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_UP);

      gpio.configure
        (RX_pin,
         gpio.MODE_AF,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_UP);

      if USARTx'address = periphs.USART1_base then
         alternate_function := gpio.GPIO_AF_USART1;
      elsif USARTx'address = periphs.USART2_base then
         alternate_function := gpio.GPIO_AF_USART2;
      elsif USARTx'address = periphs.USART3_base then
         alternate_function := gpio.GPIO_AF_USART3;
      elsif USARTx'address = periphs.UART4_base then
         alternate_function := gpio.GPIO_AF_UART4;
      elsif USARTx'address = periphs.UART5_base then
         alternate_function := gpio.GPIO_AF_UART5;
      elsif USARTx'address = periphs.USART6_base then
         alternate_function := gpio.GPIO_AF_USART6;
      else
         raise program_error;
      end if;

      gpio.set_alternate_function (TX_pin, alternate_function);
      gpio.set_alternate_function (RX_pin, alternate_function);

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


   procedure put_line (s : string)
   is
   begin
      put (s);
      new_line;
   end put_line;

end serial;

