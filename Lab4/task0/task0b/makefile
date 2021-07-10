
all: patch
# Tool invocations
# Executable "patch" depends on the files start.o and main.0 util.o
patch: start.o main.o util.o
	ld -m elf_i386 start.o main.o util.o -o patch

# Depends on the source and header files
main.o: main.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector main.c -o main.o

util.o: util.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector util.c -o util.o
 
start.o: start.s
	nasm -f elf32 start.s -o start.o

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o patch
