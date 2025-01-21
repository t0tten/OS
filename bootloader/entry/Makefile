ASM=nasm
LD16?=/usr/bin/watcom/binl/wlink
CC16?=/usr/bin/watcom/binl/wcc

ASMFLAGS?=-f obj
CFLAGS?=-4 -d3 -s -wx -ms -zl -zq

ASM_SRC=$(wildcard *.asm)
C_SRC=$(wildcard *.c)

BINARIES=$(patsubst %.asm, %.bin, $(ASM_SRC))
ASM_OBJECTS=$(patsubst %.asm, %.obj, $(ASM_SRC))
C_OBJECTS=$(patsubst %.c, %.obj, $(C_SRC))

TARGET=entry
TARGET_BIN=$(TARGET).bin
BIN_FOLDER=bin

#all: entry.bin #$(BINARIES)

#%.bin:%.asm
#	if [ ! -d ./$(BIN_FOLDER) ]; then mkdir ./$(BIN_FOLDER); fi
#	$(ASM) $< -f bin -o ./$(BIN_FOLDER)/$@

build: $(TARGET_BIN)

$(TARGET_BIN): $(ASM_OBJECTS) $(C_OBJECTS)
	$(LD16) NAME $(BIN_FOLDER)/$(TARGET_BIN) FILE \{ $(ASM_OBJECTS) $(C_OBJECTS) \} OPTION MAP=$(BIN_FOLDER)/$(TARGET).map @linker.lnk

%.obj:%.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

%.obj:%.c
	$(CC16) $(CFLAGS) -fo=$@ $<

run:
	qemu-system-i386 ./$(BIN_FOLDER)/$(TARGET_BIN_FOLDER)

collect:
	cp ./entry/$(BIN_FOLDER)/*.bin ./$(BIN_FOLDER)

clean:
	rm -rf ./$(BIN_FOLDER)
	rm *.obj

print:
	echo "$(ASM_SRC)"
	echo "$(C_SRC)"
	echo "$(BINARIES)"
	echo "$(ASM_OBJECTS)"
	echo "$(C_OBJECTS)"
