
all: flame2
# Tool invocations
# Executable "flame2" depends on the files start.o and task2c.0 util.o
flame2: start.o task2c.o util.o
	ld -m elf_i386 start.o task2c.o util.o -o flame2

# Depends on the source and header files
task2c.o: task2c.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector task2c.c -o task2c.o

util.o: util.c
	gcc -m32 -Wall -ansi -c -nostdlib -fno-stack-protector util.c -o util.o
 
start.o: start.s
	nasm -f elf32 start.s -o start.o

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o flame2
