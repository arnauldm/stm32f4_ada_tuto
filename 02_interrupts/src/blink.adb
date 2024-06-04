------------------------------------------------------------------------------
-- Simple blinky example for stm32F4 Discovery that interact by pressing the
-- blue button.
------------------------------------------------------------------------------

-- The following packages describe some registers and peripherals common to
-- the stm32F4 socs.
-- Note:
--   1. The underlying hardware interface is included via the `blink.gpr`
--       file:
--
--          for Runtime ("Ada") use "light-tasking-stm32f4";
--
--   2. The files i-stm32-gpio.ads, i-stm32-rcc.ads and s-stm32.ads are packed
--      with the compiler. They can be found in:
--
--          gnat_arm_elf/arm-eabi/lib/gnat/light-tasking-stm32f4/gnat/
--
with interfaces.stm32.RCC;
with interfaces.stm32.GPIO;
with system.stm32;
with ada.real_time; use ada.real_time;

with blue_button;

procedure blink is

   LED_GREEN   : constant := 12; -- Green led is on pin 12 of GPIO port D
   LED_RED     : constant := 14; -- Red led is on pin 14 of GPIO port D
   led         : integer  := LED_GREEN;

   period      : constant ada.real_time.time_span := ada.real_time.milliseconds (200);

begin

   ------------------
   -- Set the LEDs --
   ------------------

   -- Enable GPIOD periph clock
   interfaces.stm32.rcc.RCC_Periph.AHB1ENR.GPIODEN := 1;

   -- Set GPIOD pins to output mode
   interfaces.stm32.gpio.GPIOD_periph.MODER.arr (LED_GREEN) := system.stm32.Mode_OUT;
   interfaces.stm32.gpio.GPIOD_periph.MODER.arr (LED_RED)   := system.stm32.Mode_OUT;

   -- Clear the leds
   interfaces.stm32.gpio.GPIOD_periph.ODR.odr.arr (LED_GREEN)  := 0;
   interfaces.stm32.gpio.GPIOD_periph.ODR.odr.arr (LED_RED)    := 0;

   ----------------------
   -- Init user button --
   ----------------------

   blue_button.initialize;

   ---------------
   -- Main loop --
   ---------------

   loop

      if blue_button.has_been_pressed then
         interfaces.stm32.gpio.GPIOD_Periph.ODR.odr.arr (led) := 0;
         led := (if led = LED_GREEN then LED_RED else LED_GREEN);
      end if;

      interfaces.stm32.gpio.GPIOD_Periph.ODR.odr.arr (led) := 1;
      delay until ada.real_time.clock + period;

      interfaces.stm32.gpio.GPIOD_Periph.ODR.odr.arr (led) := 0;
      delay until ada.real_time.clock + period;

   end loop;

end blink;
