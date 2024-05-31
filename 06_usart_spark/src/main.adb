with last_chance_handler;  pragma unreferenced (last_chance_handler);

with stm32f4; use stm32f4;
with stm32f4.gpio;
with stm32f4.periphs;
with stm32f4.usart.interfaces;

with leds;
with serial;
with blue_button;
with timer;


procedure main
   with spark_mode => on
is

   counter : natural := 0; -- Could have written "natural'first" instead of 0

   type led_index is mod 2;
   blink_led : constant array (led_index) of stm32f4.gpio.t_gpio_point :=
     (periphs.LED_GREEN, periphs.LED_RED);

   current_led : led_index := blink_led'first;

begin

   leds.init;
   pragma Annotate (GNATprove, False_Positive,
      "memory accessed through objects of access type* might not be initialized after elaboration of main program",
      "leds.init uses GPIOs whose MMIO accesses don't need to be initialized");

   blue_button.init;
   serial.init (stm32f4.usart.interfaces.ID_USART1);

   serial.put ("-- Hello, world!");
   serial.new_line;

   gpio.turn_off (periphs.LED_RED);
   gpio.turn_off (periphs.LED_GREEN);

   loop
      timer.wait (50);
      gpio.toggle (blink_led (current_led));

      if blue_button.has_been_pressed then
         gpio.turn_off (blink_led (current_led));
         current_led := current_led + 1; -- Blink next led
         gpio.turn_on (blink_led (current_led));
      end if;

      serial.put ("counter: " & integer'image(counter) & ASCII.CR);
      if counter < natural'last then
         counter := counter + 1;
      else
         serial.put ("One turn!" & ASCII.CR);
         counter := natural'first;
      end if;
   end loop;

end main;

