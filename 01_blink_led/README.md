
This example is almost for testing purpose. To compile the
firmware:

	make

To flash the board:

	make flash

The command above just call `openocd` with the following parameters:

	openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -f ocd.cfg

