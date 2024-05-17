with stm32f4.usart.interfaces; use stm32f4.usart.interfaces;
with stm32f4.gpio;
with stm32f4.periphs;

package serial
   with spark_mode => on
is

   usart_id : constant stm32f4.usart.interfaces.t_usart_id := ID_USART1;
   TX_pin   : constant stm32f4.gpio.t_gpio_point := stm32f4.periphs.USART1_TX;
   RX_pin   : constant stm32f4.gpio.t_gpio_point := stm32f4.periphs.USART1_RX;

   enabled : boolean := false;

   procedure init;
   procedure put (c : character);
   procedure put (s : string);
   procedure new_line;
   procedure put_line (s : string);

end serial;
