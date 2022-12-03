all:
	nasm -f bin ./boot.asm -o ./boot.bin
	# Append bytes from the text file to our bootloader, this will go into
	# the second section.
	dd if=./text.txt >> ./boot.bin
	# read and write up to BYTES bytes at a time (default: 512);
	# overrides ibs and obs. Fill the rest of the second section with
	# zeros, check the content by bless utility.
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin

