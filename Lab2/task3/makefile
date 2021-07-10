# All Targets
all: menu

# Tool invocations
# Executable "menu" depends on the file task2b.o
menu: menu_map.o
	gcc -g -m32 -Wall -o menu menu_map.o

# Depends on the source and header files
menu_map.o: menu_map.c
	gcc -g -m32 -Wall -c -o menu_map.o menu_map.c

#tell make that "clean" is not a file name!
.PHONY: clean

#Clean the build directory
clean: 
	rm -f *.o menu
