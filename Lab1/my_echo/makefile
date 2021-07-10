# All Targets
all: my_echo

# Tool invocations
# Executable "my_echo" depends on the file My_Echo.o
my_echo: My_Echo.o
	gcc -g -m32 -Wall -o my_echo My_Echo.o

# Depends on the source and header files
My_Echo.o: My_Echo.c
	gcc -g -m32 -Wall -c -o My_Echo.o My_Echo.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o my_echo
