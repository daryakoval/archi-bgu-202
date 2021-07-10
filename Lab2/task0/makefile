# All Targets
all: count

# Tool invocations
# Executable "encoder" depends on the file encoder.o
count: count-words.o
	gcc -g -m32 -Wall -o count count-words.o

# Depends on the source and header files
count-words.o: count-words.c
	gcc -g -m32 -Wall -c -o count-words.o count-words.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o count
