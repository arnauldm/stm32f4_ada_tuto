# stm32f4xx - Ada/SPARK bare metal programming tutorial


## Description

Simple examples to program STM32F407 board in Ada and prove some code with
SPARK tool.

- 01_blinky/, classical "blinky" example in Ada
- 02_interrupts/, blinky and blue button
- 03_interrupts_with_lib/, blinky and blue button with `Ada_Drivers_Library`
- 04_usart/, more complexe example, using the USART. Also explains how to use
  GDB and minicom.
- 05_first_step_with_spark/, same as previous with some code proved with SPARK
  and gnatprove
- 06_usart_spark/, code almost fully proved with SPARK


## Who this tutorial is for?

The examples provided here are for everyone who wants to do bare-metal
programming while taking advantage of the guarantees provided by Ada/SPARK.


## What if I do not know Ada/SPARK?

Ada is heavily used in embedded real-time systems, many of which are
safety critical. Ada really shines in low-level applications:

- Embedded systems with low memory requirements (no garbage collector allowed)
- Direct interfacing with hardware
- Soft or hard real-time systems
- Low-level systems programming

That project is not a full Ada/SPARK tutorial. It provides only some short
examples. However, a lot of useful resources exist to learn Ada/SPARK. Some of
my favorites:

- https://learn.adacore.com/
- http://www.pchapin.org/Ada/AdaCrash.pdf
- https://en.wikibooks.org/wiki/Ada_Programming
- https://github.com/ohenley/awesome-ada


## STM32F4 Discovery

For informations about how to program that board, you might need to read the
datasheets and the manuals provided by ST micro:
https://www.st.com/en/microcontrollers-microprocessors/stm32f4-series/documentation.html

The main reference manual for stm32f407 MCU can be found on ST Micro website:
https://www.st.com/resource/en/reference_manual/dm00031020-stm32f405-415-stm32f407-417-stm32f427-437-and-stm32f429-439-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf


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

