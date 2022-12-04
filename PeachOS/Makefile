SRC = ${PWD}/src
UTILITIES = ${PWD}/utilities
BIN = ${PWD}/bin
BUILD = ${PWD}/build
all:
	nasm -f bin ${SRC}/boot.asm -o ${BIN}/boot.bin
# This command will install GCC-Cross compiler.
# If it's already installed then it will add tools path to PATH
# environment variable.
gcc_init:
	source ${UTILITIES}/gcc_cross_compiler.sh
test:
	qemu-system-x86_64 -hda ${BIN}/boot.bin
clean:
	rm -rf ${BIN}/*
