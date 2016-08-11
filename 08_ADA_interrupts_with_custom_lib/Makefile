
GNATDIR = /opt/arm-gnat-2016/bin
OCDDIR  = /opt/openocd-0.9.0
export PATH := $(GNATDIR):$(PATH)

all:
	gprbuild -P main.gpr

clean:
	gprclean -P main.gpr
	rm build/*.su

flash:
	$(OCDDIR)/bin/openocd -f $(OCDDIR)/share/openocd/scripts/board/st_nucleo_f4.cfg -f ocd.cfg
