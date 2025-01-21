ASM=nasm
BIN=bin

SRC=$(wildcard *.asm)
TARGETS=$(patsubst %.asm, %.bin, $(SRC))

TARGET=bootloader
TARGET_BIN=$(TARGET).bin

#all: $(BIN)/$(TARGET_BIN)

#$(BIN)/$(TARGET_BIN):
#	if [ ! -d ./$(BIN) ]; then mkdir ./$(BIN); fi
#	$(ASM) $(SRC) -f bin -o ./$(BIN)/$(TARGET_BIN)

all: $(TARGETS)

%.bin:%.asm
	if [ ! -d ./$(BIN) ]; then mkdir ./$(BIN); fi
	$(ASM) $< -f bin -o ./$(BIN)/$@

run:
	qemu-system-i386 ./$(BIN)/$(TARGET_BIN)

collect:
	cp ./bootloader/$(BIN)/*.bin ./$(BIN)

clean:
	rm -rf ./$(BIN)

print:
	echo "$(SRC)"
	echo "$(TARGETS)"
