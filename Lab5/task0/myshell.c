#include <linux/limits.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include "LineParser.h"
#define MAX_LEN 2048

char cwd[PATH_MAX];
char buff[MAX_LEN];
struct cmdLine *cmdL;

void execute(cmdLine *pCmdLine){
    cmdLine *temp = pCmdLine;
    printf("Executing...\n");
    while(temp!=NULL){
        if(execvp(temp->arguments[0],temp->arguments)<0){
            perror("Error at execute()");
            freeCmdLines(cmdL);
            exit(1);
        }
        temp=temp->next;
    }
}

int main(){

    while(1){
        getcwd(cwd,PATH_MAX);
        printf("Current working directory is: %s\n",cwd);
        fgets(buff,MAX_LEN,stdin);
        if(strcmp(buff,"quit\n")==0) return 0;
        cmdL = parseCmdLines(buff);
        execute(cmdL);
        freeCmdLines(cmdL);
    }
    return 0;
}