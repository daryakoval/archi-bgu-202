# All Targets
all: encoder

# Tool invocations
# Executable "encoder" depends on the file encoder.o
encoder: encoder.o
	gcc -g -m32 -Wall -o encoder encoder.o

# Depends on the source and header files
encoder.o: encoder.c
	gcc -g -m32 -Wall -c -o encoder.o encoder.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o encoder
