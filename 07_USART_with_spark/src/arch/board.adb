with stm32.board;
with stm32.usarts;
with stm32.device;
with serial; 

package body board
   with spark_mode => off
is

   procedure init
      with spark_mode => off
   is
   begin

      serial.initialize_gpio
        (tx_pin => stm32.device.PB6,
         rx_pin => stm32.device.PB7,
         af     => stm32.device.gpio_af_usart1_7);

      serial.configure
        (device      => stm32.device.USART_1'access,
         baud_rate   => 9600,
         mode        => stm32.usarts.TX_MODE,
         parity      => stm32.usarts.NO_PARITY,
         data_bits   => stm32.usarts.WORD_LENGTH_8,
         end_bits    => stm32.usarts.STOPBITS_1,
         control     => stm32.usarts.NO_FLOW_CONTROL);

      stm32.board.initialize_leds;

   end init;


   procedure toggle_green_led
   is
   begin
      stm32.board.toggle (stm32.board.green_led);
   end toggle_green_led;


   procedure put (s : string)
   is
   begin
      serial.put(stm32.device.USART_1, s);
   end put;

end board;
