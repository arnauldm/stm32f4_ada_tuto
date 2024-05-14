# stm32f4 - Ada bare metal programming tuto 

Simple examples to program STM32F407 board in Ada


- 01_blink_led, classical "blinky" example in C
- 02_interrupts, blue button usage in C
- 03_ADA_blink_led, classical "blinky" example in Ada
- 04_ADA_interrupt, blue button usage in Ada
- 05_ADA_interrupts_with_lib, "blinky" with `Ada_Drivers_Library`
- 06_USART, more complexe example, using USART. Also show how to use GDB, minicom and exceptions.
- 07_LIS3DSH
- 08_ADA_interrupts_with_custom_lib
- Ada_Drivers_Library
  Clone of https://github.com/AdaCore/Ada_Drivers_Library

For Ada examples, you need to add and initialise AdaCore drivers:

	git submodule init
	git submodule update

Install GNAT toolchain:

	cd /opt
	alr get arm_gnat_elf
	alr get gnatprove

To run each example, connect the stm32f407 discovery board, compile the firmware
and flash it with openocd:

	make
	make flash


