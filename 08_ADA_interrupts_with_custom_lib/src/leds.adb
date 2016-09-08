with stm32f4; use stm32f4;
with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_pin;
with stm32f4.periphs;

package body leds is

   procedure initialize is
   begin
      -- The leds are on GPIOD pins. We have to enable GPIOD clock (see
      -- RM0090, p. 65,244)
      periphs.RCC.AHB1ENR.GPIODEN := true;

      -- Set the leds pins to output mode
      -- (see RM0090, p. 270)
      gpio.configure (periphs.LED_GREEN,
         gpio.MODE_OUT, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.PULL_DOWN);
   
      gpio.configure (periphs.LED_RED,
         gpio.MODE_OUT, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.PULL_DOWN);
   
      gpio.configure (periphs.LED_ORANGE,
         gpio.MODE_OUT, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.PULL_DOWN);
   
      gpio.configure (periphs.LED_BLUE,
         gpio.MODE_OUT, gpio.PUSH_PULL, gpio.SPEED_HIGH, gpio.PULL_DOWN);
   
      -- Led off
      gpio.turn_off (periphs.LED_GREEN);
      gpio.turn_off (periphs.LED_RED);
      gpio.turn_off (periphs.LED_ORANGE);
      gpio.turn_off (periphs.LED_BLUE);
   end initialize;

end leds;
