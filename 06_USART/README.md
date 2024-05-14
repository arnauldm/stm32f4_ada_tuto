
# Compile and flash the board

	make
	make flash

## Optionnal task

In `main.adb`, you can enable an Ada task by uncommenting the line below :

	with blink; pragma unreferenced (blink);

It will blinks the red led. Notice that the blinking frequency is not
the same as the green led's frequency, defined in `main.adb`.


# Minicom / Serial port setting

## Hardware settings

Connect USB/TTL like this:

	USB/TTL RX pin <-> PB6
	USB/TTL TX pin <-> PB7

## On a shell launch

	minicom -D /dev/ttyUSB0 -b 9600

Note: serial port should be set to `9600 8N1`.


# Debugging

For further informations: https://openocd.org/doc/html/GDB-and-OpenOCD.html

On Debian, install libncurses.so.5:

	apt install libncurses5

In a term, launch `openocd`:

	openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg

Then, launch the debugger in another term with the following commands:

	arm-eabi-gdb
	> target extended-remote 127.0.0.1:3333
	> mon reset halt
	> load build/main.elf
	> symbol-file build/main.elf
	> b _ada_main
	> c

## Testing Ada exception

In `main.adb`, change the `type small` to a lower range, for example:

	subtype small is natural range 0 .. 10;

Then, an exception will be raised. That exception, caught by the `last_chance_handler`,
blinks some leds and print a message on the USART:

	>>> exception at main.adb line 48

