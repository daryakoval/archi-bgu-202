# All Targets
all: hexeditplus

# Tool invocations
# Executable "hexeditplus" depends on the file task1.o
hexeditplus: task1.o
	gcc -g -m32 -Wall -o hexeditplus task1.o

# Depends on the source and header files
task1.o: task1.c
	gcc -g -m32 -Wall -c -o task1.o task1.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o hexeditplus
