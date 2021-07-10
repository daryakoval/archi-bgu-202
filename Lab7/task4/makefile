# All Targets
all: task4

# Tool invocations
# Executable "task4" depends on the file task4.o
task4: task4.o
	gcc -g -m32 -Wall -fno-pie -o task4 task4.o

# Depends on the source and header files
task4.o: task4.c
	gcc -g -m32 -Wall -fno-pie -c -o task4.o task4.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o task4
