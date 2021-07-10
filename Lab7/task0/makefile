# All Targets
all: hexeditplus

# Tool invocations
# Executable "hexeditplus" depends on the file task0.o
hexeditplus: task0.o
	gcc -g -m32 -Wall -o hexeditplus task0.o

# Depends on the source and header files
task0.o: task0.c
	gcc -g -m32 -Wall -c -o task0.o task0.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o hexeditplus
