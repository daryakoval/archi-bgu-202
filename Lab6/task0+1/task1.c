#include <linux/limits.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include "LineParser.h"
#define MAX_LEN 2048

typedef struct Link{
    char* name; 
    char* value; 
    struct Link *next;	 /* next link in chain */
} Link;

char cwd[PATH_MAX];
char buff[MAX_LEN];
struct cmdLine *cmdL;
int debug=0;
int childPid=-1;
int status;
struct Link *head = NULL;


void execute(cmdLine *pCmdLine){
    if(debug) fprintf(stderr,"PID is : %d\n",getpid());
    if(debug) fprintf(stderr,"Executing: %s\n",pCmdLine->arguments[0]);
    if(pCmdLine->inputRedirect!=NULL){
        if(debug) fprintf(stderr,"Input Redirect...\n");
        fclose(stdin);
        fopen(pCmdLine->inputRedirect,"r");
    }
    if(pCmdLine->outputRedirect!=NULL){
        if(debug) fprintf(stderr,"Output Redirect...\n");
        fclose(stdout);
        fopen(pCmdLine->outputRedirect,"w+");
    }
    if(execvp(pCmdLine->arguments[0],pCmdLine->arguments)<0){
        perror("Error at execute()");
        freeCmdLines(pCmdLine);
        _exit(1);
    }
}

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

void handleChangeDirectory(){
    if(debug) fprintf(stderr,"Changing Directory...\n");
    if(chdir(cmdL->arguments[1])<0){
        perror("Error at ChangeDirectory()");
        freeCmdLines(cmdL);
        _exit(1);
    }
}

int main (int argc , char* argv[]){

    checkArguments(argc,argv);

    while(1){
        getcwd(cwd,PATH_MAX);
        if(debug) fprintf(stderr,"PID is : %d\n",getpid());
        printf("Current working directory is: %s\n",cwd);
        fgets(buff,MAX_LEN,stdin);
        if(strcmp(buff,"quit\n")==0){
            if(debug) fprintf(stderr,"Exiting...\n");
            exit(0);
        }
        cmdL = parseCmdLines(buff);

        /* task 1c - handle "cd" */
        if(strncmp(cmdL->arguments[0],"cd",2)==0){
            handleChangeDirectory();
        }
        /*open new process to execute line */
        else if((childPid=fork())<0){
            perror("Error at fork()");
            freeCmdLines(cmdL);
            _exit(1);
        }else{
            if(childPid==0) {/*if it is child prossess*/
                execute(cmdL);
                freeCmdLines(cmdL);
            }else{/*if it is parent prossess lets wait for child process to finish*/
                if(cmdL->blocking){
                    waitpid(childPid,&status,0);
                }
            }
        }
    }
    return 0;
}