# stm32f4 - Ada bare metal programming tuto 

Simple examples to program STM32F407 board in Ada


- `01_blink_led`, classical "blinky" example in C
- `02_interrupts`, blue button usage in C
- `03_ADA_blink_led`, classical "blinky" example in Ada
- `04_ADA_interrupt`, blue button usage in Ada
- `05_ADA_interrupts_with_lib`, "blinky" with `Ada_Drivers_Library`
- `06_USART`, more complexe example, using USART. Also show how to use GDB,
  minicom and exceptions.
- `07_USART_with_spark`, same as previous with some code proved with SPARK and
  gnatprove
- `08_USART_with_spark_custom_lib/`, code almost fully proved with SPARK
- `Ada_Drivers_Library`, clone of
  `https://github.com/AdaCore/Ada_Drivers_Library`

For Ada examples, you need to add and initialise AdaCore drivers:

	git submodule init
	git submodule update

Install GNAT toolchain:

	cd /opt
	alr get arm_gnat_elf
	alr get gnatprove

If you want to search / install a specific arm_gnat_elf or gnatprove version,
you might try these:

	alr search --full arm_gnat_elf
	alr get arm_gnat_elf={version}

You will need to adjust your PATH:

	export PATH=/opt/arm_gnat_elf_{version}/bin:/opt/gnatprove_{version}/bin:$PATH

To run each example, connect the stm32f407 discovery board, compile the firmware
and flash it with openocd:

	make
	make flash

For further informations about how to program that board, you might need to read the
datasheets and the manuals provided by ST micro:

	https://www.st.com/en/microcontrollers-microprocessors/stm32f4-series/documentation.html

The main reference manual for stm32f407 MCU can be found here:

	https://www.st.com/resource/en/reference_manual/dm00031020-stm32f405-415-stm32f407-417-stm32f427-437-and-stm32f429-439-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf


