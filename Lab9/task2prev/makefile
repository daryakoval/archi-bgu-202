
all: task2

task2: task2.o 
	ld -m elf_i386 task2.o -o task2


task2.o: task2.s
	nasm -f elf task2.s -o task2.o
 
.PHONY: clean

clean: 
	rm -f *.o task2
