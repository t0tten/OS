ASM=nasm
BIN=bin

SRC=bootloader.asm

TARGET=bootloader
TARGET_BIN=$(TARGET).bin

all: $(BIN)/$(TARGET_BIN)

$(BIN)/$(TARGET_BIN):
	if [ ! -d ./$(BIN) ]; then mkdir ./$(BIN); fi
	$(ASM) $(SRC) -f bin -o ./$(BIN)/$(TARGET_BIN)

run:
	qemu-system-i386 ./$(BIN)/$(TARGET_BIN)

collect:
	cp ./bootloader/$(BIN)/$(TARGET_BIN) ./$(BIN)

clean:
	rm -rf ./$(BIN)
