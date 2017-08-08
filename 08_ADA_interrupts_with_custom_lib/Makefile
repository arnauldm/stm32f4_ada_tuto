
GNATDIR = /opt/arm-gnat-2017/bin
export PATH := $(GNATDIR):$(PATH)

all:
	gprbuild -P main.gpr

clean:
	gprclean -P main.gpr
	rm build/*.su

flash:
	openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -f ocd.cfg

nucleo:
	openocd -f /usr/share/openocd/scripts/board/st_nucleo_f4.cfg -f ocd.cfg

