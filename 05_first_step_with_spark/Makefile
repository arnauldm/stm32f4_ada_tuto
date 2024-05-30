
all:
	gprbuild -P main.gpr

clean:
	gprclean -P main.gpr
	rm -rf build/

prove:
	gnatprove -P main.gpr

flash:
	openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -f ocd.cfg

