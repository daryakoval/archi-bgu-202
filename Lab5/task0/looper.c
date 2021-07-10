#include <stdio.h>
#include <unistd.h>
#include <string.h>

#define SIGTSTP 20
#define SIGINT 2
#define SIGCONT 18

char * signalName;

int main(int argc, char **argv){ 

	printf("Starting the program\n");

	while(1) {
		signalName = strsignal();

		sleep(2);
	}

	return 0;
}