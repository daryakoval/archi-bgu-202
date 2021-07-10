# All Targets
all: mypipeline

# Tool invocations
# Executable "myshell" depends on the files main.o numbers.o and add.o.
mypipeline: task3.o 
	gcc -m32 -g -Wall -o mypipeline task3.o 

# Depends on the source and header files
task3.o: task3.c
	gcc -m32 -g -Wall -c -o task3.o task3.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o mypipeline
