BIN=./bin

MODULES=bootloader kernel

all: build_modules collect_binaries

build_modules:
	$(foreach MODULE, $(MODULES), cd $(MODULE) && make -f Makefile; cd ..;)

collect_binaries:
	if [ ! -d ./$(BIN) ]; then mkdir ./$(BIN); fi
	$(foreach MODULE, $(MODULES), make collect -f ./$(MODULE)/Makefile;)

run:
	qemu-system-i386 -fda $(wildcard $(BIN)/*.img)

clean:
	rm -rf ./$(BIN)
	$(foreach MODULE, $(MODULES), cd $(MODULE) && make clean -f Makefile; cd ..;)
