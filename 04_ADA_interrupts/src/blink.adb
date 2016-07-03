with Interfaces.STM32.RCC;
with Interfaces.STM32.GPIO; 
with System.STM32;
with Ada.Real_Time; use Ada.Real_Time;

with buttons;
with registers;

procedure blink is

   led_green   : constant := 12;
   led_blue    : constant := 15;
   led         : integer  := led_green;

   Period      : constant Ada.Real_Time.Time_Span 
      := Ada.Real_Time.Milliseconds (50);

begin

   --
   -- Set the LEDs
   --

   -- Enable GPIOD periph clock
   Interfaces.STM32.RCC.RCC_Periph.AHB1ENR.GPIODEN := 1;

   -- Set GPIOD pin to output mode
   Interfaces.STM32.GPIO.GPIOD_Periph.MODER.Arr (led_green)
      := System.STM32.Mode_OUT;

   Interfaces.STM32.GPIO.GPIOD_Periph.MODER.Arr (led_blue) :=
      System.STM32.Mode_OUT;

   -- Clear the leds
   Interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.Arr (led_green) := 0;
   Interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.Arr (led_blue) := 0;

   -- 
   -- Init user button
   -- 

   buttons.initialize;

   loop

      if buttons.has_been_pressed then
         Interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.Arr (led) := 0;
         led := (if led = led_green then led_blue else led_green);
      end if;

      Interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.Arr (led) := 1;
      delay until Ada.Real_Time.Clock + Period;

      Interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.Arr (led) := 0;
      delay until Ada.Real_Time.Clock + Period;

   end loop;

end blink;
