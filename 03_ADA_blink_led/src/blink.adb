with Interfaces.STM32.RCC;
with Interfaces.STM32.GPIO; use Interfaces.STM32.GPIO;
with System.STM32;
with Ada.Real_Time; use Ada.Real_Time;

procedure blink is
   Green_Led   : constant := 12;
   Period      : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (500);
begin

   -- Enable GPIOD periph clock
   Interfaces.STM32.RCC.RCC_Periph.AHB1ENR.GPIODEN := 1;

   -- Set GPIOD pin to output mode
   Interfaces.STM32.GPIO.GPIOD_Periph.MODER.Arr (Green_Led)
      := System.STM32.Mode_OUT;
   
   loop
      -- led on
      Interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.Arr (Green_Led) := 1;

      delay until Ada.Real_Time.Clock + Period;

      -- led off
      Interfaces.STM32.GPIO.GPIOD_Periph.ODR.ODR.Arr (Green_Led) := 0;

      delay until Ada.Real_Time.Clock + Period;

   end loop;

end blink;
