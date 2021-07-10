#format is target-name: target dependencies
#{-tab-}actions

# All Targets
all: Task0

# Tool invocations
# Executable "Task0" depends on the files main.o numbers.o and add.o.
Task0: main.o numbers.o add.o
	gcc -m32 -g -Wall -o Task0 main.o numbers.o add.o

# Depends on the source and header files
main.o: main.c
	gcc -m32 -g -Wall -c -o main.o main.c

numbers.o: numbers.c
	gcc -m32 -g -Wall -c -o numbers.o numbers.c

add.o: add.s
	nasm -g -f elf -w+all -o add.o add.s


#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o Task0

