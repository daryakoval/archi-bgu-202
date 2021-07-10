
all: task0

task0: task0.o 
	ld -m elf_i386 task0.o -o task0


task0.o: task0.s
	nasm -f elf task0.s -o task0.o
 
.PHONY: clean

clean: 
	rm -f *.o task0
