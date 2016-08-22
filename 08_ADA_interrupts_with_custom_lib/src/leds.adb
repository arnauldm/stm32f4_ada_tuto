with ada.real_time; use ada.real_time;

with stm32f4; use stm32f4;
with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_pin;
with stm32f4.periphs;

with buttons;  -- button that interact with those leds

package body leds is

   procedure init is
   begin
      -- The leds are on GPIOD pins. We have to enable GPIOD clock (see
      -- RM0090, p. 65,244)
      periphs.RCC.AHB1ENR.GPIODEN := 1;

      -- Set the leds pins to output mode
      -- (see RM0090, p. 270)
      gpio.configure
        (periphs.LED_GREEN,
         gpio.MODE_OUT,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_DOWN);
   
      gpio.configure
        (periphs.LED_RED,
         gpio.MODE_OUT,
         gpio.PUSH_PULL,
         gpio.SPEED_HIGH,
         gpio.PULL_DOWN);
   
      -- Led off
      gpio.turn_off (periphs.LED_GREEN);
      gpio.turn_off (periphs.LED_RED);

      -- Init user button
      buttons.initialize;
   end init;

   task body blinking_leds is
      led      : gpio.t_GPIO_pin := periphs.LED_GREEN;
      period   : constant ada.real_time.time_span := 
         ada.real_time.milliseconds (500);
   begin
      init;
      loop
         if buttons.has_been_pressed then
            gpio.turn_off (led);
            led :=  (if led = periphs.LED_GREEN then
                        periphs.LED_RED
                     else
                        periphs.LED_GREEN);
         end if;
         gpio.toggle (led);
         delay until ada.real_time.clock + period;
      end loop;
   end blinking_leds;

end leds;
