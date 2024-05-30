# FAQs

## What if I do not have a STM32F4 Discovery but a Nucleo-XXX board?

The provided sources are only examples.

As such, the compiled firmware won't work properly on your board and
you'll certainly need to modify the sources. It can be seen as an
excellent practice.

Here is a non-exhaustive list of what you'll probably need to change:

1. Some board don't have 4 user leds and they are probably assigned to
   different GPIOs.

2. Usarts, leds, and peripherals in general are not assigned to the same GPIOs.

3. Examples 03, 04 and 05 make uses of specific Ada_Driver_Library GPR files
   (head of main.gpr file). You'll have to change the included library.

4. Openocd support a whole bunch of different boards. You'll have to use the
   proper configuration file.

