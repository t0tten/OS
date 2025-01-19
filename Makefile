BIN=./bin

MODULES=bootloader kernel
TARGET=operating-system

all: build_floppy_image

build_modules:
	$(foreach MODULE, $(MODULES), cd $(MODULE) && make -f Makefile; cd ..;)

build_floppy_image: collect_binaries
	# LINUX - Comment out
	#dd if=/dev/zero of=$(BIN)/$(TARGET).img bs=512 count=2880 # Empty floppy disk
	#mkfs.fat -F 12 -n "NBOS" $(BIN)/$(TARGET).img
	# MACOS - Comment out
	cp ./bootloader/backup/empty_floppy_fat12.img $(BIN)/$(TARGET).img

	cat $(BIN)/*.bin > $(BIN)/$(TARGET).bin
	dd if=$(BIN)/$(TARGET).bin of=$(BIN)/$(TARGET).img conv=notrunc

collect_binaries: build_modules
	if [ ! -d ./$(BIN) ]; then mkdir ./$(BIN); fi
	$(foreach MODULE, $(MODULES), make collect -f ./$(MODULE)/Makefile;)

run:
	qemu-system-i386 -fda $(wildcard $(BIN)/*.img)

clean:
	rm -rf ./$(BIN)
	$(foreach MODULE, $(MODULES), cd $(MODULE) && make clean -f Makefile; cd ..;)

dependencies_arch:
	sudo pacman -S $(shell cat dependencies.txt)
