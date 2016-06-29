# Binaries will be generated with this name (.elf, .bin, .hex, etc)
PROJ_NAME=blinky

STFLASH=st-flash
STUTIL=st-util
RUSTC=rustc
CC=arm-none-eabi-gcc
AR=arm-none-eabi-ar
OBJCOPY=arm-none-eabi-objcopy
GDB=arm-none-eabi-gdb
MKDIR=mkdir -p

AFLAGS  = -mlittle-endian -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS  = -g -O0 -Wall
CFLAGS += $(AFLAGS)
CFLAGS += -Isrc/ -I./src/include/ 
LDFLAGS = -Tstm32_flash.ld $(AFLAGS)

TARGET=thumbv7em-none-eabihf
RUSTBUILD=$(shell rustc --version |sed -n 's/^rustc [^ ]* (\([^ ]*\) .*)$$/\1/p')
LIBCORE_PATH=rust/libcore/$(TARGET)/$(RUSTBUILD)
RUSTCOREURL=https://github.com/rust-lang/rust/tarball/$(RUSTBUILD)
BUILDDIR=build

#Souces files
#C sources files
CSRCDIR=src
SRC = $(wildcard $(CSRCDIR)/*.c)
OBJ = $(patsubst %.c,$(BUILDDIR)/%.o,$(notdir $(SRC)))

#ASM sources files
SSRC = $(CSRCDIR)/startup_stm32f4xx.s
SOBJ = $(patsubst %.s,$(BUILDDIR)/%.o,$(notdir $(SSRC)))

#Rust sources files
RSSRCDIR=rust/src
RSRC= $(wildcard $(RSRCDIR)/*.rs)
ROBJ = $(patsubst %.rs,$(BUILDDIR)/%.o,$(notdir $(RSRC)))

#ada sources files
ASRCDIR=ada/src
ASRC= $(wildcard $(ASRCDIR)/*.adb)
AOBJ = $(patsubst %.adb,$(BUILDDIR)/%.o,$(notdir $(ASRC)))

.PHONY: proj

all: proj

show:
	@echo "ASM sources files:"
	@echo "\t" $(SSRC)
	@echo "\t\t=> " $(SOBJ)
	@echo "C sources files:"
	@echo "\t" $(SRC)
	@echo "\t\t=> " $(OBJ)
	@echo "Rust sources files:"
	@echo "\t" $(RSRC)
	@echo "\t\t=> " $(ROBJ)

proj: $(PROJ_NAME).hex 

$(SOBJ):$(SSRC)
	$(CC) $< -c $(CFLAGS) -o $@

$(BUILDDIR):
	$(MKDIR) $@

$(BUILDDIR)/%.o: $(CSRCDIR)/%.c | $(BUILDDIR)
	$(CC) $< -c $(CFLAGS) -o $@

$(ROBJ): $(RSRC)
	$(BUILDDIR)/%.o: $(RSRCDIR)/%.rs
	$(RUSTC) $< --emit obj --target $(TARGET) -L $(LIBCORE_PATH) -o $@

$(PROJ_NAME).elf: $(ROBJ) $(OBJ) $(SOBJ)
	$(CC) $(LDFLAGS) -o $(PROJ_NAME).elf $(ROBJ) $(SOBJ) $(OBJ)


$(PROJ_NAME).hex: $(PROJ_NAME).elf
	$(OBJCOPY) -O ihex $(PROJ_NAME).elf $(PROJ_NAME).hex

cleanlibcore:
	rm $(LIBCORE_PATH)/libcore.rlib

clean:
	rm -f $(OBJ) $(ROBJ) $(SOBJ) $(ABOJ) $(PROJ_NAME).elf $(PROJ_NAME).hex $(PROJ_NAME).bin

flash: 
	openocd -f /usr/share/openocd/scripts/board/stm32f4discovery.cfg -f ocd.cfg

