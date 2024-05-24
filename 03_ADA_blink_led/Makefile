
all:
	gprbuild -P blink.gpr

clean:
	gprclean -P blink.gpr
	rm -rf build/

flash:
	openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -f ocd.cfg

nucleo:
	openocd -f /usr/share/openocd/scripts/board/st_nucleo_f4.cfg -f ocd.cfg

