# All Targets
all: task

# Tool invocations
# Executable "menu" depends on the file task2b.o
task: addresses.o
	gcc -g -m32 -Wall -o task addresses.o

# Depends on the source and header files
addresses.o: addresses.c
	gcc -g -m32 -Wall -c -o addresses.o addresses.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o task
