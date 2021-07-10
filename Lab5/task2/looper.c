#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>

char * signalName;

void SIGCONTHandler(int sigmun);

void SIGINTHandler(int sigmun){
	signalName = strsignal(sigmun);
	printf("Looper handling %s\n",signalName);
	signal(SIGINT, SIG_DFL);
	raise(SIGINT);
}

void SIGTSTPHandler(int sigmun){
	signalName = strsignal(sigmun);
	printf("Looper handling %s\n",signalName);
	signal(SIGTSTP, SIG_DFL);
	raise(SIGTSTP);
	signal(SIGCONT, SIGCONTHandler);
}

void SIGCONTHandler(int sigmun){
	signalName = strsignal(sigmun);
	printf("Looper handling %s\n",signalName);
	signal(SIGCONT, SIG_DFL);
	raise(SIGCONT);
	signal(SIGTSTP, SIGTSTPHandler);
}

int main(int argc, char **argv){ 

	printf("Starting the program\n");
	signal(SIGINT, SIGINTHandler);
	
	signal(SIGTSTP, SIGTSTPHandler);

	signal(SIGCONT, SIGCONTHandler);


	while(1) {
		sleep(2);
	}

	return 0;
}
