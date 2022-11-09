all:
	nasm -f bin ./boot.asm -o ./boot.bin
	# Add string from file to the second sector.
	dd if=./message.txt >> ./boot.bin
	# Add more 0 until it fills the second sector to be able to read it.
	dd if=/dev/zero bs=1 count=1 >> ./boot.bin