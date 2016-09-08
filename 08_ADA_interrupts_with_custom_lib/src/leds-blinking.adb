
package body leds.blinking is

   task body blinking_leds is

      led  : constant array (1 .. 4) of gpio.t_GPIO_pin :=
        (periphs.LED_GREEN, periphs.LED_ORANGE, periphs.LED_RED,
         periphs.LED_BLUE);

      index    : integer := 1;

      period   : constant ada.real_time.time_span := 
         ada.real_time.milliseconds (125);

   begin

      init;

      loop
         gpio.turn_off (led(index));
         if index = led'last then
               index := led'first;
         else
               index := index + 1;
         end if;
         gpio.turn_on (led(index));
         delay until ada.real_time.clock + period;
      end loop;

   end blinking_leds;

end leds.blinking;
