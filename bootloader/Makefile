ASM=nasm
BIN=bin

SRC=bootloader.asm

TARGET=bootloader
TARGET_BIN=$(TARGET).bin
TARGET_IMG=$(TARGET).img

all: $(BIN)/$(TARGET_IMG)

$(BIN)/$(TARGET_IMG):$(BIN)/$(TARGET_BIN)
	#dd if=/dev/zero of=./$(BIN)/$(TARGET_IMG) bs=512 count=2880 # Floppy disk 1,4MB
	#newfs_msdos -F 12 -v "NBOS" ./$(BIN)/$(TARGET_IMG)
	#mkfs.fat -F 12 -n "NBOS" ./$(BIN)/$(TARGET_IMG)
	cp ./backup/empty_floppy_fat12.img ./$(BIN)/$(TARGET_IMG)
	dd if=./$(BIN)/$(TARGET_BIN) of=./$(BIN)/$(TARGET_IMG)

$(BIN)/$(TARGET_BIN):
	if [ ! -d ./$(BIN) ]; then mkdir ./$(BIN); fi
	$(ASM) $(SRC) -f bin -o ./$(BIN)/$(TARGET_BIN)

run:
	qemu-system-i386 ./$(BIN)/$(TARGET_IMG)

collect:
	cp ./bootloader/$(BIN)/$(TARGET_IMG) ./$(BIN)

clean:
	rm -rf ./$(BIN)
