# All Targets
all: task0a

# Tool invocations
# Executable "task0a" depends on the file task0a.o
task0a: task0a.o
	gcc -g -m32 -Wall -o task0a task0a.o

# Depends on the source and header files
task0a.o: task0a.c
	gcc -g -m32 -Wall -c -o task0a.o task0a.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o task0a
