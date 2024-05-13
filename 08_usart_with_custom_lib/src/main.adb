with system;
with ada.real_time; use ada.real_time;
with last_chance_handler;  pragma unreferenced (last_chance_handler);

with stm32f4; use stm32f4;
with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_pin;
with stm32f4.periphs;

with leds;
with serial;


procedure main is
   pragma priority (system.priority'first);

   period   : constant ada.real_time.time_span :=
      ada.real_time.milliseconds (50);

   subtype small is natural range 0 .. 1000;
   counter : small := 0;
begin

   leds.initialize;
   serial.initialize;

   serial.put ("-- Hello, world!");
   serial.new_line;

   gpio.turn_on (periphs.LED_RED);
   gpio.turn_off (periphs.LED_GREEN);

   loop
      delay until ada.real_time.clock + period;
      gpio.toggle (periphs.LED_RED);
      gpio.toggle (periphs.LED_GREEN);

      -- Buggy! The counter will overflow
      serial.put ("small: " & integer'image(counter) & ASCII.CR);
      counter := counter + 1;
   end loop;

end main;
