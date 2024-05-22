
# 1. Install the Ada/SPARK toolchain

Be sur that gnat for ARM architecture is installed and that the binaries are in
your PATH. Read the main `Readme.md` file for some more informations.

# 2. Compile and flash the board

	make
	make flash

You should see the led blinking (which is not very much impressive, btw).


## 2.1 Notes

Those Ada *packages* used by `blink.adb` are provided by the GNAT compiler:

	with interfaces.stm32.gpio; use interfaces.stm32.gpio;
	with interfaces.stm32.rcc;
	with system.stm32;

Their content is available in `gnat_arm_elf/arm-eabi/lib/gnat` directory.
For example, `system.stm32` package is in
`gnat_arm_elf/arm-eabi/lib/gnat/embedded-stm32f4/gnat/s-stm32.ad{s,b}`.

File `blink.gpr` uses *embedded-stm32f4* runtime, which includes about 844
packages.


# 3. To debug the program

For further informations: https://openocd.org/doc/html/GDB-and-OpenOCD.html

On Debian, install libncurses.so.5:

	apt install libncurses5

In a terminal, launch `openocd`:

	openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg

Then, launch the debugger in another terminal with the following commands:

	arm-eabi-gdb
	> target extended-remote 127.0.0.1:3333
	> mon reset halt
	> load build/main.elf
	> symbol-file build/main.elf
	> b _ada_main
	> c

Then, you can use gdb as usual!

