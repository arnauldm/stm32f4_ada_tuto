
all:
	gprbuild -P main.gpr

clean:
	gprclean -P main.gpr
	rm build/*.su

flash:
	openocd -f stm32f4disco1.cfg -f ocd.cfg

nucleo:
	openocd -f /usr/share/openocd/scripts/board/st_nucleo_f4.cfg -f ocd.cfg

