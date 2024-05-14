
# Install the Ada/SPARK toolchain

Be sur that gnat for ARM architecture is installed and that the binaries are in
your PATH. Read the main `Readme.md` file for some more informations.

# Compile and flash the board

	make
	make flash

You should see the led blinking (which is not very much impressive, btw).


# Notes

The Ada *packages* used by `blink.adb` are the one that are embedded with the
GNAT compiler. For example, `system.stm32` package is in
`gnat_arm_elf/arm-eabi/lib/gnat/embedded-stm32f4/gnat/s-stm32.ad{s,b}`.

File `blink.gpr` defines a *Runtime*, which is more or less the packages
used by the compiler. The `embedded-stm32f4` includes about 844 packages
although the `light-stm32f4` includes only 405 packages.


# To debug the program

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

