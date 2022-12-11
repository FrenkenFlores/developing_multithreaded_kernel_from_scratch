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

${BIN}/kernel.bin:  ${BUILD}/kernel.asm.o ${BUILD}/kernel.o
	# Link all object files together in one file.
	${TARGET}-ld -g -relocatable ${BUILD}/kernel.asm.o ${BUILD}/kernel.o -o ${BUILD}/kernelfull.o
	# Take the object file and create an executable binary file.
	${TARGET}-gcc $(FLAGS) -T ${SRC}/linker.ld -o ${BIN}/kernel.bin ${BUILD}/kernelfull.o

${BUILD}/kernel.asm.o: ${SRC}/kernel/kernel.asm
	nasm -i ${SRC}/kernel -f elf ${SRC}/kernel/kernel.asm -g -o ${BUILD}/kernel.asm.o

${BUILD}/kernel.o: ${SRC}/kernel/kernel.c
	${TARGET}-gcc -I ${SRC}/kernel $(FLAGS) -c ${SRC}/kernel/kernel.c -o ${BUILD}/kernel.o

${BIN}/boot.bin: ${SRC}/boot/boot.asm
	nasm -i ${SRC}/boot/ -f bin ${SRC}/boot/boot.asm -g -o ${BIN}/boot.bin

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
