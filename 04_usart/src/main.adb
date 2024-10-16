with system;
with last_chance_handler;  pragma unreferenced (last_chance_handler);
with ada.real_time;  use ada.real_time;

with stm32.device;
with stm32.usarts;
with stm32.board;

with serial;

-- Task blinking the RED led
--with blink; pragma unreferenced (blink);


procedure main is
   pragma priority (system.priority'first);

   subtype small is natural range 0 .. 10;
   counter : small := 0;
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

   loop

      delay until clock + milliseconds (200);

      stm32.board.toggle (stm32.board.green_led);

      serial.put (stm32.device.USART_1,
         "[" & integer'image(counter) & "]  hello, world!" & ASCII.CR);

      -- Buggy! The counter will overflow
      counter := counter + 1;

   end loop;

end main;
