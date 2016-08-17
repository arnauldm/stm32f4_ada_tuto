with last_chance_handler;  pragma unreferenced (last_chance_handler);
with ada.real_time; use ada.real_time;

with stm32f4; use stm32f4;

with stm32f4.gpio; use type stm32f4.gpio.t_GPIO_pin;
with stm32f4.periphs;

with serial;
with buttons;

procedure main is
   counter  : integer         := 0;
   led      : gpio.t_GPIO_pin := periphs.LED_GREEN;
   period   : constant ada.real_time.time_span := 
      ada.real_time.milliseconds (500);
begin

   --
   -- Initialize USART (for logging purpose)
   --

   serial.initialize;
   serial.put ("Hello, world!");
   serial.put (ASCII.CR);

   --
   -- Enable leds
   --

   -- The leds are on GPIOD pins. We have to enable GPIOD clock (see
   -- RM0090, p. 65,244)
   periphs.RCC.AHB1ENR.GPIODEN := 1;

   -- Set the pins to output mode
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

   -- 
   -- Init user button
   -- 

   buttons.initialize;

   loop
      if buttons.has_been_pressed then
         led :=  (if led = periphs.LED_GREEN then
                     periphs.LED_RED
                  else
                     periphs.LED_GREEN);
      end if;

      gpio.turn_on (led);
      delay until ada.real_time.clock + period;

      gpio.turn_off (led);
      delay until ada.real_time.clock + period;

      serial.put
        ("counter: " & integer'image (counter) & ASCII.CR &
         ASCII.LF);

      counter := counter + 1;
   end loop;

end main;
