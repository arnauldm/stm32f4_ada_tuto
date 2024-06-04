
------------------------------------------------------------------------------
-- Simple blinky example for STM32F4 Discovery. Read the Readme.md file for
-- instructions.
------------------------------------------------------------------------------


-- The following packages describe some registers and peripherals common to
-- the STM32F4 socs.
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
with interfaces.stm32.gpio;
with interfaces.stm32.rcc;
with system.stm32;

with ada.real_time; use ada.real_time;

procedure blink is
   GREEN_LED   : constant := 12; -- Green led is on pin 12 of GPIO port D
   RED_LED     : constant := 14; -- Red led is on pin 14 of GPIO port D
   period      : constant ada.real_time.time_span := ada.real_time.milliseconds (500);
begin

   -- Enable gpiod periph clock

   interfaces.stm32.rcc.rcc_periph.ahb1enr.gpioden := 1;

   -- Set GPIOD pins to output mode

   interfaces.stm32.gpio.gpiod_periph.moder.arr (GREEN_LED) := system.stm32.mode_out;
   interfaces.stm32.gpio.gpiod_periph.moder.arr (RED_LED)   := system.stm32.mode_out;

   loop
      -- Led on / off
      interfaces.stm32.gpio.gpiod_periph.odr.odr.arr (GREEN_LED)  := 1;
      interfaces.stm32.gpio.gpiod_periph.odr.odr.arr (RED_LED)    := 0;

      delay until ada.real_time.clock + period;

      -- Led on / off
      interfaces.stm32.gpio.gpiod_periph.odr.odr.arr (GREEN_LED)  := 0;
      interfaces.stm32.gpio.gpiod_periph.odr.odr.arr (RED_LED)    := 1;

      delay until ada.real_time.clock + period;

   end loop;

end blink;
