ASM=nasm
BIN=bin

SRC=bootloader.asm

TARGET=bootloader
TARGET_BIN=$(TARGET).bin
TARGET_IMG=$(TARGET).img

all: $(BIN)/$(TARGET_IMG)

$(BIN)/$(TARGET_IMG):$(BIN)/$(TARGET_BIN)
	cp ./$(BIN)/$(TARGET_BIN) ./$(BIN)/$(TARGET_IMG)
	truncate -s 1440k ./$(BIN)/$(TARGET_IMG)

$(BIN)/$(TARGET_BIN):
	if [ ! -d ./$(BIN) ]; then mkdir ./$(BIN); fi
	$(ASM) $(SRC) -f bin -o ./$(BIN)/$(TARGET_BIN)

run:
	qemu-system-i386 ./$(BIN)/$(TARGET_IMG)

collect:
	cp ./bootloader/$(BIN)/$(TARGET_IMG) ./$(BIN)

clean:
	rm -rf ./$(BIN)
