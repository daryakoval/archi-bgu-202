# All Targets
all: Task0

# Tool invocations
# Executable "Task0" depends on the files main.o numbers.o and add.o.
Task0: myshell.o LineParser.o 
	gcc -m32 -g -Wall -o Task0 myshell.o LineParser.o

# Depends on the source and header files
myshell.o: myshell.c
	gcc -m32 -g -Wall -c -o myshell.o myshell.c

LineParser.o: LineParser.c
	gcc -m32 -g -Wall -c -o LineParser.o LineParser.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o Task0
