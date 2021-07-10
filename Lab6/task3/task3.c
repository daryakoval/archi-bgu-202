#include <linux/limits.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#define MAX_LEN 2048

char cwd[PATH_MAX];
char buff[MAX_LEN];
int debug=0;

void checkArguments(int argc, char** argv){
  if(argc>1) {
      int i=0;
        for (i = 1; i < argc; i++) {
            if (strcmp(argv[i], "-d") == 0) {/*debug mode*/
                debug = 1;
            }else {
              printf("invalid parameter\n");
              _exit(1);
            }
        }
    }
}

int main (int argc , char* argv[]){
    int status;
    int pipefd[2];
    int child1Pid=-1;
    int child2Pid=-1;
    int writeEndDup;
    int readEndDup;
    char * ls[] ={"ls","-l",NULL};
    char * tail[] ={"tail","-n","2",NULL};

    checkArguments(argc,argv);

    if (pipe(pipefd) == -1) { /*create pipe*/
        perror("pipe()");
        exit(1);
    }

    if(debug) fprintf(stderr,"parent_process>forking…\n");
    if ((child1Pid = fork()) == -1) {/*create child 1*/
        perror("fork()");
        exit(1);
    }
    if(debug && child1Pid!=0) fprintf(stderr,"parent_process>created process with id: %d\n",child1Pid);

    if(child1Pid==0){
        if(debug) fprintf(stderr,"child1>redirecting stdout to the write end of the pipe…\n");
        fclose(stdout);     /*close standart output*/
        writeEndDup= dup(pipefd[1]);   /*duplicate the write-end of the pipe using dup*/
        close(pipefd[1]);          /*Close the file descriptor that was duplicated.*/
        if(debug) fprintf(stderr,"child1>going to execute cmd: …\n");
        execvp(ls[0],ls);                            /*Execute "ls -l"*/
    }else{
        if(debug) fprintf(stderr,"parent_process>closing the write end of the pipe…\n");
        close(pipefd[1]); /*Close the write end of the pipe*/
    }

    if(debug) fprintf(stderr,"parent_process>forking…\n");
    if (child1Pid !=0 && (child2Pid = fork()) == -1) {/*create child 2*/
        perror("fork()");
        exit(1);
    }
    if(debug && child2Pid !=0) fprintf(stderr,"parent_process>created process with id: %d\n",child2Pid);

    if(child2Pid==0){
        if(debug) fprintf(stderr,"child2>redirecting stdin to the read end of the pipe…\n");
        fclose(stdin);             /*close standart intput*/
        readEndDup= dup(pipefd[0]);     /*duplicate the read-end of the pipe using dup*/
        close(pipefd[0]);                /*Close the file descriptor that was duplicated.*/
        if(debug) fprintf(stderr,"child2>going to execute cmd: …\n");
        execvp(tail[0],tail);               /*Execute "tail -n 2"*/
    }else if(child2Pid!=0 && child1Pid!=0){
        if(debug) fprintf(stderr,"parent_process>closing the read end of the pipe…\n");
        close(pipefd[0]); /*Close the read end of the pipe*/
    }

    if(debug) fprintf(stderr,"parent_process>waiting for child processes to terminate…\n");
    waitpid(child1Pid,&status,0);
    waitpid(child2Pid,&status,0);

    if(debug) fprintf(stderr,"parent_process>exitin…\n");
    return 0;
}