SRC = ${PWD}/src
UTILITIES = ${PWD}/utilities
BIN = ${PWD}/bin
BUILD = ${PWD}/build
SHELL := /bin/bash
FLAGS = -std=gnu99 -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

all: ${BIN}/boot.bin ${BIN}/kernel.bin
	rm -rf ${BIN}/os.bin
	dd if=${BIN}/boot.bin >> ${BIN}/os.bin
	dd if=${BIN}/kernel.bin >> ${BIN}/os.bin
	dd if=/dev/zero bs=512 count=100 >> ${BIN}/os.bin

${BIN}/kernel.bin:  ${BUILD}/kernel.o ${BUILD}/kernel_main.o
	# Link all object files together in one file.
	${TARGET}-ld -g -relocatable ${BUILD}/kernel.o ${BUILD}/kernel_main.o -o ${BUILD}/kernelfull.o
	# Take the object file and create an executable binary file.
	${TARGET}-gcc $(FLAGS) -T ${SRC}/linker.ld -o ${BIN}/kernel.bin ${BUILD}/kernelfull.o

${BUILD}/kernel.o: ${SRC}/kernel.asm
	nasm -i ${SRC}/ -f elf ${SRC}/kernel.asm -g -o ${BUILD}/kernel.o

${BUILD}/kernel_main.o: ${SRC}/kernel.c
	${TARGET}-gcc -I ${SRC} $(FLAGS) -c ${SRC}/kernel.c -o ${BUILD}/kernel_main.o

${BIN}/boot.bin: ${SRC}/boot.asm
	nasm -i ${SRC}/ -f bin ${SRC}/boot.asm -g -o ${BIN}/boot.bin

# This command will install GCC-Cross compiler.
# If it's already installed then it will add tools path to PATH
# environment variable. Execute this command before excuting make.
gcc_init:
	source ${UTILITIES}/gcc_cross_compiler.sh
test:
	qemu-system-x86_64 -hda ${BIN}/os.bin
clean:
	rm -rf ${BIN}/*
	rm -rf ${BUILD}/*
