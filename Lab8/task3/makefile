# All Targets
all: myELF

# Tool invocations
# Executable "myELF" depends on the file task3.o
myELF: task3.o
	gcc -g -m32 -Wall -o myELF task3.o

# Depends on the source and header files
task3.o: task3.c
	gcc -g -m32 -Wall -c -o task3.o task3.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o myELF
