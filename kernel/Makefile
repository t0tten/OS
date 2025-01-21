ASM=nasm
BIN=bin

SRC=kernel.asm

TARGET=kernel
TARGET_BIN=$(TARGET).bin

all: $(BIN)/$(TARGET_BIN)

$(BIN)/$(TARGET_BIN):
	if [ ! -d ./$(BIN) ]; then mkdir ./$(BIN); fi
	$(ASM) $(SRC) -f bin -o ./$(BIN)/$(TARGET_BIN)

collect_subdir:
	cp ./kernel/$(BIN)/$(TARGET_BIN) ./$(BIN)
collect:

clean:
	rm -rf ./$(BIN)
