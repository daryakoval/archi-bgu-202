
all: encoder
# Tool invocations
# Executable "encoder" depends on the files start.o and main.0 util.o
encoder: start.o task1b.o util.o
	ld -m elf_i386 start.o task1b.o util.o -o encoder

# Depends on the source and header files
task1b.o: task1b.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector task1b.c -o task1b.o

util.o: util.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector util.c -o util.o
 
start.o: start.s
	nasm -f elf32 start.s -o start.o

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o encoder
