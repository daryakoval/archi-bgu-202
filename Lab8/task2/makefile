# All Targets
all: myELF

# Tool invocations
# Executable "myELF" depends on the file task2.o
myELF: task2.o
	gcc -g -m32 -Wall -o myELF task2.o

# Depends on the source and header files
task2.o: task2.c
	gcc -g -m32 -Wall -c -o task2.o task2.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o myELF
