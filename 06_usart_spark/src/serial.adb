with stm32f4; use stm32f4;
with stm32f4.usart; use stm32f4.usart;
with stm32f4.rcc;
with stm32f4.periphs;

package body serial
   with spark_mode => on
is

   procedure init
     (usartid : in stm32f4.usart.interfaces.t_usart_id)
   is
   begin

      usart_id := usartid;


      --
      -- Enable clocks
      --

      case usart_id is
         when ID_USART1 =>
            TX_pin := stm32f4.periphs.USART1_TX;
            RX_pin := stm32f4.periphs.USART1_RX;

         when ID_USART3 =>
            TX_pin := stm32f4.periphs.USART3_TX;
            RX_pin := stm32f4.periphs.USART3_RX;

         when ID_USART6 =>
            TX_pin := stm32f4.periphs.USART6_TX;
            RX_pin := stm32f4.periphs.USART6_RX;
      end case;

      rcc.enable_gpio_clock (TX_pin.port);
      rcc.enable_gpio_clock (RX_pin.port);

      -- USART
      case usart_id is
         when ID_USART1 => periphs.RCC.APB2ENR.USART1EN  := true;
         when ID_USART3 => periphs.RCC.APB1ENR.USART3EN  := true;
         when ID_USART6 => periphs.RCC.APB2ENR.USART6EN  := true;
      end case;

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
      case usart_id is
         when ID_USART1 =>
            gpio.set_af (TX_pin, stm32f4.gpio.GPIO_AF_USART1);
            gpio.set_af (RX_pin, stm32f4.gpio.GPIO_AF_USART1);
         when ID_USART3 =>
            gpio.set_af (TX_pin, stm32f4.gpio.GPIO_AF_USART3);
            gpio.set_af (RX_pin, stm32f4.gpio.GPIO_AF_USART3);
         when ID_USART6 =>
            gpio.set_af (TX_pin, stm32f4.gpio.GPIO_AF_USART6);
            gpio.set_af (RX_pin, stm32f4.gpio.GPIO_AF_USART6);
      end case;

      --
      -- Configure USART
      --
      usart.interfaces.configure
        (usart_id, 9600, DATA_9BITS, PARITY_ODD, STOP_1, enabled);

   end init;


   procedure put (c : character)
   is
   begin
      usart.interfaces.transmit (usart_id, character'pos (c));
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

