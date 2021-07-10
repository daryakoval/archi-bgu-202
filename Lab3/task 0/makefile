# All Targets
all: bubblesort

# Tool invocations
# Executable "bubblesort" depends on the file bubblesort.o
bubblesort: bubblesort.o
	gcc -g -m32 -Wall -o bubblesort bubblesort.o

# Depends on the source and header files
bubblesort.o: bubblesort.c
	gcc -g -m32 -Wall -c -o bubblesort.o bubblesort.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o bubblesort
