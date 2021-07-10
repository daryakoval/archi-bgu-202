# All Targets
all: myshell

# Tool invocations
# Executable "myshell" depends on the files main.o numbers.o and add.o.
myshell: task2.o LineParser.o 
	gcc -m32 -g -Wall -o myshell task2.o LineParser.o

# Depends on the source and header files
task2.o: task2.c
	gcc -m32 -g -Wall -c -o task2.o task2.c

LineParser.o: LineParser.c
	gcc -m32 -g -Wall -c -o LineParser.o LineParser.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o myshell
