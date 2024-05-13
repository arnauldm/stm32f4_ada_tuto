with system;
with ada.real_time; use ada.real_time;
with last_chance_handler;  pragma unreferenced (last_chance_handler);

with stm32f4; use stm32f4;
with stm32f4.gpio;
with stm32f4.periphs;

with leds;
with serial;
with blue_button;


procedure main
   with spark_mode => off
is
   pragma priority (system.priority'first);

   period   : constant ada.real_time.time_span :=
      ada.real_time.milliseconds (50);

   subtype small is natural range 0 .. 1000;
   counter : small := 0;

   type led_index is mod 2;
   blink_led : constant array (led_index) of stm32f4.gpio.t_GPIO_pin :=
     (periphs.LED_GREEN, periphs.LED_RED);

   current : led_index := blink_led'first;

begin

   leds.initialize;
   blue_button.initialize;
   serial.initialize;

   serial.put ("-- Hello, world!");
   serial.new_line;

   gpio.turn_off (periphs.LED_RED);
   gpio.turn_off (periphs.LED_GREEN);

   loop
      delay until ada.real_time.clock + period;
      gpio.toggle (blink_led(current));

      if blue_button.has_been_pressed then
         gpio.turn_off (blink_led(current));
         current := current + 1;
         gpio.turn_on (blink_led(current));
      end if;

      -- Buggy! The counter will overflow
      serial.put ("small: " & integer'image(counter) & ASCII.CR);
      counter := counter + 1;
   end loop;

end main;
