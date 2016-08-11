with ada.real_time; use ada.real_time;

with stm32f4.gpio; 
with stm32f4.periphs;

with buttons;

procedure main is

   green_led_pin  : stm32f4.gpio.GPIO_pin_index
      renames stm32f4.periphs.green_led_pin;

   red_led_pin    : stm32f4.gpio.GPIO_pin_index
      renames stm32f4.periphs.red_led_pin;

   led : stm32f4.gpio.GPIO_pin_index := green_led_pin;

   period : constant ada.real_time.time_span 
      := ada.real_time.milliseconds (500);

begin

   --
   -- Enable leds
   --

   -- The leds are on GPIOD pins. We have to enable GPIOD clock (see
   -- RM0090, p. 65,244)
   stm32f4.periphs.RCC.AHB1ENR.GPIODEN := 1;

   -- Set the pins to output mode
   stm32f4.periphs.GPIOD.MODER.pin (green_led_pin) := stm32f4.gpio.MODE_OUT; 
   stm32f4.periphs.GPIOD.MODER.pin (red_led_pin)   := stm32f4.gpio.MODE_OUT; 

   stm32f4.periphs.GPIOD.OTYPER.pin (green_led_pin) := stm32f4.gpio.PUSH_PULL;
   stm32f4.periphs.GPIOD.OTYPER.pin (red_led_pin) := stm32f4.gpio.PUSH_PULL;
   
   -- Led off
   stm32f4.periphs.GPIOD.ODR.pin (green_led_pin)  := 0;
   stm32f4.periphs.GPIOD.ODR.pin (red_led_pin)    := 0;

   -- 
   -- Init user button
   -- 

   buttons.initialize;

   loop
      if buttons.has_been_pressed then
         led := (if led = green_led_pin then red_led_pin else green_led_pin);
      end if;

      stm32f4.periphs.GPIOD.ODR.pin (led)  := 1;
      delay until ada.real_time.clock + period;
      stm32f4.periphs.GPIOD.ODR.pin (led)  := 0;
      delay until ada.real_time.clock + period;
   end loop;

end main;
