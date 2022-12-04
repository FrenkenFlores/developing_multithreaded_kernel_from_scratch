SRC = ${PWD}/src
BIN = ${PWD}/bin
BUILD = ${PWD}/build
all:
	nasm -f bin ${SRC}/boot.asm -o ${BIN}/boot.bin
test:
	qemu-system-x86_64 -hda ${BIN}/boot.bin
clean:
	rm -rf ${BIN}/*
