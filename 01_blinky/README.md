
# 1. Install the Ada/SPARK toolchain

Be sur that gnat for ARM architecture is installed and that the binaries are in
your PATH. Read the main `Readme.md` file for some more informations.

# 2. Compile and flash the board

	make
	make flash

You should see the led blinking (which is not very much impressive, btw).

## 2.1 Note about Ada packages

Those Ada *packages* used by `blink.adb` are provided by the GNAT compiler:

	with interfaces.stm32.gpio; use interfaces.stm32.gpio;
	with interfaces.stm32.rcc;
	with system.stm32;

Their content is available in `gnat_arm_elf/arm-eabi/lib/gnat` directory.
For example, `system.stm32` package is in
`gnat_arm_elf/arm-eabi/lib/gnat/light-tasking-stm32f4/gnat/s-stm32.ad{s,b}`.

File `blink.gpr` uses *light-tasking-stm32f4* runtime, which includes about 400
packages.

## 2.2 Coding style

Ada legit coding style is to use Camel case. I don't use it because I find that programs 
with such a casing are hardely readables!


# 3. Exercise

The current binary blinks 2 leds. Modify the main procedure so that it
blinks the 4 leds one after the other.

Hint: The leds specification is defined on the stm32f407vg datasheet, available here:

	https://www.st.com/resource/en/user_manual/um1472-discovery-kit-with-stm32f407vg-mcu-stmicroelectronics.pdf


# 4. To debug the program

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

