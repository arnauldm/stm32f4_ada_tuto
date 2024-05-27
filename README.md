# stm32f4xx - Ada/SPARK bare metal programming tutorial


## Description

Simple examples to program STM32F407 board in Ada/SPARK

- 01_blinky/, classical "blinky" example in Ada
- 02_interrupts/, blinky and blue button
- 03_interrupts_with_lib/, blinky and blue button with `Ada_Drivers_Library`
- 04_usart/, more complexe example, using the USART. Also explains how to use
  GDB and minicom.
- 05_first_step_with_spark/, same as previous with some code proved with SPARK
  and gnatprove
- 06_usart_spark/, code almost fully proved with SPARK


## Installation

### Ada drivers library

You'll need to add and initialise AdaCore drivers in `Ada_Drivers_Library` directory:

	git submodule init
	git submodule update

Note: the project repository is there: https://github.com/AdaCore/Ada_Drivers_Library 


### Alire, the Ada package manager

On Linux Debian, you can install it directly with:

	apt install alire

You can also get 'Alire' binary on https://alire.ada.dev/.


### GNAT toolchain for ARM

Install GNAT toolchain with `alr`, the Alire binary:

	cd /opt
	alr get arm_gnat_elf
	alr get gnatprove

If you want to search / install a specific `arm_gnat_elf` or `gnatprove` version,
you might try these:

	alr search --full arm_gnat_elf
	alr get arm_gnat_elf={version}

Note that you'll probably have to adjust your PATH:

	export PATH=/opt/arm_gnat_elf_{version}/bin:/opt/gnatprove_{version}/bin:$PATH

## Compile

To run each example, connect the stm32f407 discovery board, compile the firmware
and flash it with openocd:

	make
	make flash

## See also

For further informations about how to program that board, you might need to read the
datasheets and the manuals provided by ST micro:

	https://www.st.com/en/microcontrollers-microprocessors/stm32f4-series/documentation.html

The main reference manual for stm32f407 MCU can be found here:

	https://www.st.com/resource/en/reference_manual/dm00031020-stm32f405-415-stm32f407-417-stm32f427-437-and-stm32f429-439-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf


