#include <linux/limits.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include "LineParser.h"
#define MAX_LEN 2048
#define TERMINATED  -1
#define RUNNING 1
#define SUSPENDED 0

typedef struct process{
    cmdLine* cmd;                         /* the parsed command line*/
    pid_t pid; 		                  /* the process id that is running the command*/
    int status;                           /* status of the process: RUNNING/SUSPENDED/TERMINATED */
    struct process *next;	                  /* next process in chain */
} process;

char cwd[PATH_MAX];
char buff[MAX_LEN];
struct cmdLine *cmdL;
int debug=0;
int childPid=-1;
int status;
process* process_head = NULL;

void updateProcessList(process *process_list);
void printProcessList(process* process_list);

void addProcess(process* process_list, cmdLine* cmd, pid_t pid){
    process* p = (process*)malloc(sizeof(process));
    p->cmd = cmd;
    p->next = NULL;
    p->pid = pid;
    p->status = RUNNING;
    if(process_list==NULL){
        process_head = p; 
    }else{
        process * temp = process_list;
        while(temp->next != NULL){
            temp=temp->next;
        }
        temp->next = p;
    }
}
void deleteProcess(process *p){
    process * temp = process_head;
    if(temp==p){
        process_head=p->next;
        freeCmdLines(temp->cmd);
        free(temp);
        return;
    }
    process * prev = process_head;
    while(temp != p && temp !=NULL){
        prev = temp;
        temp=temp->next;
    }
    if(temp==p){
        prev->next=p->next;
        freeCmdLines(temp->cmd);
        free(temp);
    }

}
void printStatus(int s){
    if(s==-1) printf("TERMINATED\t");
    if(s==1) printf("RUNNING\t\t");
    if(s==0) printf("SUSPENDED\t");

}
void printCmdLine(cmdLine* cmd){
    cmdLine* temp = cmd;
    while(temp!=NULL){
        int i =0;
        printf("CmdLine:\nArguments Count : %d\n Arguments:\n",temp->argCount);
        for(i=0; i< temp->argCount; i++){
            printf("%s ",temp->arguments[i]);
        }
        if(temp->inputRedirect!= NULL) printf("\nInput Rediredirect: %s\n",temp->inputRedirect);
        if(temp->outputRedirect!= NULL) printf("Output Rediredirect: %s\n",temp->outputRedirect);
        if(temp->blocking) printf("\nCmdLine blocking : true\n");
        else printf("CmdLine blocking : false\n");
        printf("CmdLine index :%d\n", temp->idx);
        temp=temp->next;
        if(temp == NULL) printf("CmdLine Next : NULL \n");
        else printf("CmdLine Next : \n");

    }
}
void printCommand(cmdLine* cmd){
    int i=0;
    for(i=0; i< cmd->argCount; i++){
            printf("%s ",cmd->arguments[i]);
        }
    printf("\n");
}
void printProcess(process *p){
    printf("%d\t\t",p->pid);
    printStatus(p->status);
    printCommand(p->cmd);

}
void printProcessList(process* process_list){
    updateProcessList(process_list);
    printf("Index\t\tPID\t\t Status\t\t Command\n");
    if(process_list==NULL) return;
    process * temp = process_list;
    process * toDelte =temp;
    int index = 0;
    while(temp != NULL){
        printf("Index : %d\t",index);
        printProcess(temp);
        toDelte=temp;
        temp=temp->next;
        if(toDelte->status==TERMINATED) deleteProcess(toDelte);
        index++;
    }
}
void execute(cmdLine *pCmdLine){
    cmdLine *temp = pCmdLine;
    if(debug) fprintf(stderr,"PID is : %d\n",getpid());
    if(debug) fprintf(stderr,"Executing: %s\n",temp->arguments[0]);
    while(temp!=NULL){
        if(execvp(temp->arguments[0],temp->arguments)<0){
            perror("Error at execute()");
            freeCmdLines(pCmdLine);
            _exit(1);
        }
        temp=temp->next;
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
void freeProcessList(process* process_list){
    if(process_list==NULL) return;
    process * temp = process_list;
    process * current = process_list;
    while (current!= NULL){
        freeCmdLines(current->cmd);
        temp=current->next;
        free(current);
        current=temp;
    }
    
}
void updateProcessList(process *process_list){
    if(process_list==NULL) return;
    process * temp = process_list;
    while(temp != NULL){
        int ret = waitpid(temp->pid,&status,WNOHANG);
        if(ret==-1){
            temp->status=TERMINATED;
        }
        else if(ret !=0 && WIFSTOPPED(status)){
            temp->status=SUSPENDED;
        }else if(ret !=0 && WIFCONTINUED(status)){
            temp->status=RUNNING;
        }else if(ret !=0 && WIFEXITED(status)){
            temp->status=TERMINATED;
        }
        temp=temp->next;
    }
}
void updateProcessStatus(process* process_list, int pid, int status1){
    process * temp = process_list;
    while(temp != NULL){
        if(temp->pid==pid){
            temp->status=status1;
        }
        temp=temp->next;
    }
}
void handleSuspend(char *procid){
    int pid = atoi(procid);
    if(kill(pid,SIGTSTP)<0){
        perror("Erro at kill()");
    }else{
        updateProcessStatus(process_head,pid,SUSPENDED);
    }
}
void handleKill(char *procid){
    int pid = atoi(procid);
    if(kill(pid,SIGINT)<0){
        perror("Erro at kill()");
    }else{
        updateProcessStatus(process_head,pid,TERMINATED);
    }
}
void handleWake(char *procid){
    int pid = atoi(procid);
    if(kill(pid,SIGCONT)<0){
        perror("Erro at kill()");
    }else{
        updateProcessStatus(process_head,pid,RUNNING);
    }
}
void checkArguments(int argc, char** argv){
  if(argc>1) {
      int i=0;
        for (i = 1; i < argc; i++) {
            if (strcmp(argv[i], "-D") == 0) {/*debug mode*/
                debug = 1;
            }
        }
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
            freeProcessList(process_head);
            exit(0);
        }
        cmdL = parseCmdLines(buff);

        /* task 1c - handle "cd" */
        if(strncmp(cmdL->arguments[0],"cd",2)==0){
            handleChangeDirectory();
            freeCmdLines(cmdL);
        }/* task 2c - handle "kill" */
        else if(strncmp(cmdL->arguments[0],"kill",4)==0){
            handleKill(cmdL->arguments[1]);
            freeCmdLines(cmdL);
        }/* task 2c - handle "wake" */
        else if(strncmp(cmdL->arguments[0],"wake",4)==0){
            handleWake(cmdL->arguments[1]);
            freeCmdLines(cmdL);
        }/* task 2c - handle "suspend" */
        else if(strncmp(cmdL->arguments[0],"suspend",7)==0){
            handleSuspend(cmdL->arguments[1]);
            freeCmdLines(cmdL);
        }/* procs command*/
        else if(strncmp(cmdL->arguments[0],"procs",5)==0){
            printProcessList(process_head);
            freeCmdLines(cmdL);
        }/*open new process to execute line */
        else if((childPid=fork())<0){
            perror("Error at fork()");
            _exit(1);
        }else{
            if(childPid==0) {/*if it is child prossess*/
                execute(cmdL);
            }else{/*if it is parent prossess, add to list, lets wait for child process to finish*/
                addProcess(process_head,cmdL,childPid);
                if(cmdL->blocking){
                    waitpid(childPid,&status,0);
                }
            }
        }
    }
    return 0;

}
