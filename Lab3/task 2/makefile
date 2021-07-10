# All Targets
all: virusDetector

# Tool invocations
# Executable "virusDetector" depends on the file task2b.o
virusDetector: task2b.o
	gcc -g -m32 -Wall -o virusDetector task2b.o

# Depends on the source and header files
task2b.o: task2b.c
	gcc -g -m32 -Wall -c -o task2b.o task2b.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o virusDetector
