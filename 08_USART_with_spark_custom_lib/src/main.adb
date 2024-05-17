with last_chance_handler;  pragma unreferenced (last_chance_handler);

with stm32f4; use stm32f4;
with stm32f4.gpio;
with stm32f4.periphs;

with leds;
with serial;
with blue_button;
with timer;


procedure main
   with spark_mode => on
is

   subtype small is natural range 0 .. 1000;
   counter : small := 0;

   type led_index is mod 2;
   blink_led : constant array (led_index) of stm32f4.gpio.t_gpio_point :=
     (periphs.LED_GREEN, periphs.LED_RED);

   current : led_index := blink_led'first;

begin

   leds.init;
   blue_button.init;
   serial.init;

   serial.put ("-- Hello, world!");
   serial.new_line;

   gpio.turn_off (periphs.LED_RED);
   gpio.turn_off (periphs.LED_GREEN);

   loop
      timer.wait (50);
      gpio.toggle (blink_led(current));

      if blue_button.has_been_pressed then
         gpio.turn_off (blink_led(current));
         current := current + 1; -- The counter will overflow!
         gpio.turn_on (blink_led(current));
      end if;

      serial.put ("small: " & integer'image(counter) & ASCII.CR);
      counter := counter + 1;
   end loop;

end main;
