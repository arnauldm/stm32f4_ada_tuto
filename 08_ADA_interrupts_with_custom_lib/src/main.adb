with ada.real_time; use ada.real_time;
with last_chance_handler;  pragma unreferenced (last_chance_handler);

with stm32f4; use stm32f4;
with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_pin;

with serial;
with leds; pragma unreferenced (leds); -- task blinking_leds
with tests;

-- DEBUG (TO REMOVE)
with stm32f4.sdio; pragma unreferenced (stm32f4.sdio);

procedure main is
   counter  : integer         := 0;
   period   : constant ada.real_time.time_span := 
      ada.real_time.milliseconds (1000);
begin

   -- Initialize USART 
   serial.initialize;

   tests.test_dma_mem_to_mem;

   loop
      serial.put ("counter: " & integer'image (counter));
      serial.new_line;
      counter := counter + 1;
      delay until ada.real_time.clock + period;
   end loop;

end main;
