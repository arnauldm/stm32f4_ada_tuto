with stm32f4.usart.interfaces; use stm32f4.usart.interfaces;
with stm32f4.gpio;

package serial
   with spark_mode => on
is

   usart_id : stm32f4.usart.interfaces.t_usart_id;
   TX_pin   : stm32f4.gpio.t_gpio_point;
   RX_pin   : stm32f4.gpio.t_gpio_point;

   enabled : boolean := false;

   procedure init (usartid : in stm32f4.usart.interfaces.t_usart_id);

   procedure put (c : in character);
   procedure put (s : in string);
   procedure new_line;
   procedure put_line (s : in string);

end serial;
