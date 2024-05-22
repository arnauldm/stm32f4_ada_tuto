
# 1. Description

That code enables the USART_1 serial line to provide an output. It will allow
the embedded binary to write anything on the console.

The Ada exception handler will be able to write a message on the console,
to give us some very important insight about bugs.


# 2. Compile and flash the board

As usual, to compile and flash the firmware:

	make
	make flash

## 2.1 Optionnal task

In `main.adb`, you can enable an Ada task by uncommenting the line below :

	with blink; pragma unreferenced (blink);

It will blinks the red led. Notice that the blinking frequency is not
the same as the green led's frequency, defined in `main.adb`.


# 3. Minicom / Serial port setting

Connect USB/TTL like this:

	USB/TTL RX pin <-> PB6
	USB/TTL TX pin <-> PB7

And then, on a shell launch:

	minicom -D /dev/ttyUSB0 -b 9600

Note: serial port should be set to `9600 8N1`.


# 4. Debugging

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

## 4.1 Testing Ada exception

In `main.adb`, change the `type small` to a lower range, for example:

	subtype small is natural range 0 .. 10;

Then, an exception will be raised. That exception, caught by the `last_chance_handler`,
blinks some leds and print a message on the USART:

	>>> exception at main.adb line 48

