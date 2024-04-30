with interfaces.STM32.RCC;
with interfaces.STM32.GPIO; 
with system.STM32;
with ada.real_time; use ada.real_time;

with blue_button;

procedure blink is

   LED_GREEN   : constant := 12;
   LED_RED     : constant := 14;
   led         : integer  := LED_GREEN;

   period      : constant ada.real_time.time_span := ada.real_time.milliseconds (200);

begin

   ------------------
   -- Set the LEDs --
   ------------------

   -- Enable GPIOD periph clock
   interfaces.STM32.RCC.RCC_Periph.AHB1ENR.GPIODEN := 1;

   -- Set GPIOD pins to output mode
   interfaces.STM32.GPIO.GPIOD_Periph.MODER.arr (LED_GREEN)
      := System.STM32.Mode_OUT;

   interfaces.STM32.GPIO.GPIOD_Periph.MODER.arr (LED_RED) :=
      System.STM32.Mode_OUT;

   -- Clear the leds
   interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.arr (LED_GREEN) := 0;
   interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.arr (LED_RED) := 0;

   ---------------------- 
   -- Init user button --
   ---------------------- 

   blue_button.initialize;

   ---------------
   -- Main loop --
   ---------------

   loop

      if blue_button.has_been_pressed then
         interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.arr (led) := 0;
         led := (if led = LED_GREEN then LED_RED else LED_GREEN);
      end if;

      interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.arr (led) := 1;
      delay until ada.real_time.clock + period;

      interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.arr (led) := 0;
      delay until ada.real_time.clock + period;

   end loop;

end blink;
