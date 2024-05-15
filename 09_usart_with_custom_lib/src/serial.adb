with stm32f4; use stm32f4;
with stm32f4.periphs;
with stm32f4.usart;
with stm32f4.rcc;
with stm32f4.gpio;

package body serial
   with spark_mode => off
is

   USARTx   : stm32f4.usart.t_USART_periph renames periphs.USART1;
   TX_pin   : constant stm32f4.gpio.t_gpio_point := periphs.USART1_TX;
   RX_pin   : constant stm32f4.gpio.t_gpio_point := periphs.USART1_RX;

   procedure initialize
   is
   begin

      --
      -- Enable clocks
      --

      rcc.enable_gpio_clock (TX_pin.port);
      rcc.enable_gpio_clock (RX_pin.port);

      -- USART 1
      periphs.RCC.APB2ENR.USART1EN  := true;

      -- Configure TX pin
      gpio.configure
        (TX_pin,
         gpio.MODE_AF,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_UP);

      -- Configure RX pin
      gpio.configure
        (RX_pin,
         gpio.MODE_AF,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_UP);

      -- Set 'alternate function'
      gpio.set_af (TX_pin.port, TX_pin.pin, stm32f4.gpio.GPIO_AF_USART1);
      gpio.set_af (RX_pin.port, TX_pin.pin, stm32f4.gpio.GPIO_AF_USART1);

      --
      -- Configure USART
      --
      declare
         use stm32f4.usart;
      begin
         usart.configure
           (USARTx'access, 9600, DATA_9BITS, PARITY_ODD, STOP_1);
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

