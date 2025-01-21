SUB_DIRS=bootloader entry

all: build_modules

build_modules:
	$(foreach SUB_DIR, $(SUB_DIRS), cd $(SUB_DIR) && make -f Makefile; cd ..;)

collect: build_modules
	if [ ! -d ./bin ]; then mkdir ./bin; fi
	$(foreach SUB_DIR, $(SUB_DIRS), make collect -f ./$(SUB_DIR)/Makefile;)

clean:
	$(foreach SUB_DIR, $(SUB_DIRS), cd $(SUB_DIR) && make clean -f Makefile; cd ..;)
	rm -rf ./bin
