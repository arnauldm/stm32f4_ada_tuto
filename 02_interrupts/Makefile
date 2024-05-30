
all:
	gprbuild -P blink.gpr

clean:
	gprclean -P blink.gpr
	rm -rf build/

flash:
	openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -f ocd.cfg

