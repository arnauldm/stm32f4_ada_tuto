
# 1. Description

This example is almost for testing purpose. To compile the
firmware:

	make

To flash the board:

	make flash

The command above just call `openocd` with the following parameters:

	openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -f ocd.cfg

# 2. Compilation

## 2.1 Requirements

That example requires `arm-none-eabi-gcc` compiler. 

## 2.2 Flags

This example needs some architecture-specific flags to compile the source code
for STM32F4 board:

	AFLAGS  = -mlittle-endian -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16

