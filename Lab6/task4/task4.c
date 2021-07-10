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
process* process_head = NULL;
struct Link *head = NULL;

void updateProcessList(process *process_list);
void printProcessList(process* process_list);

/*copy paste from LineParser.c*/
static char *strClone(const char *source){
    char* clone = (char*)malloc(strlen(source) + 1);
    strcpy(clone, source);
    return clone;
}

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
/*Lab 6*/
void execute(cmdLine *pCmdLine){
    if(debug) fprintf(stderr,"PID is : %d\n",getpid());
    if(debug) fprintf(stderr,"Executing: %s\n",pCmdLine->arguments[0]);
    if(pCmdLine->inputRedirect!=NULL){
        if(debug) fprintf(stderr,"Input Redirect...\n");
        fclose(stdin);
        if(fopen(pCmdLine->inputRedirect,"r")==NULL){
            perror("Error at open file()");
            _exit(1);
        }
    }
    if(pCmdLine->outputRedirect!=NULL){
        if(debug) fprintf(stderr,"Output Redirect...\n");
        fclose(stdout);
        if(fopen(pCmdLine->outputRedirect,"w+")==NULL){
            perror("Error at open file()");
            _exit(1);
        }
    }
    if(execvp(pCmdLine->arguments[0],pCmdLine->arguments)<0){
        perror("Error at execute()");
        freeCmdLines(pCmdLine);
        _exit(1);
    }
}
/*Lab 6*/
void handleChangeDirectory(){
    char *dir=cmdL->arguments[1];
    if(debug) fprintf(stderr,"Changing Directory...\n");
    if(strncmp(cmdL->arguments[1],"~",1)==0){
        dir = getenv("HOME");
    }
    if(chdir(dir)<0){
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
/*Lab 6 task 2*/
char* findVar(char *name){
    Link * temp = head;
    char* ret = NULL;
    while (temp != NULL){
        if(strcmp(temp->name,name)==0)
            return temp->value;
        temp=temp->next;
    }
    return ret;
}
/*Lab 6*/
void handleSet(){
    if(debug) fprintf(stderr,"Setting variable%s, to %s ...\n",cmdL->arguments[1],cmdL->arguments[2]);
    Link * prev = head;
    Link * temp = head;
    if(head!=NULL){
        while(temp!=NULL){
            if(strcmp(temp->name,cmdL->arguments[1])==0){
                free(temp->value);
                temp->value=strClone(cmdL->arguments[2]);
                return;
            }
            prev=temp;
            temp=temp->next;
        }
        Link *newLink=(Link*)malloc(sizeof(Link));
        newLink->next = NULL;
        newLink->name= strClone(cmdL->arguments[1]);
        newLink->value=strClone(cmdL->arguments[2]);
        prev->next=newLink;
    }else{/*head is null*/
        Link *newLink=(Link*)malloc(sizeof(Link));
        newLink->next = NULL;
        newLink->name= strClone(cmdL->arguments[1]);
        newLink->value=strClone(cmdL->arguments[2]);
        head = newLink;
    }
}
/*Lab 6*/
void handleVars(){
    if(debug) fprintf(stderr,"Handle variables ...\n");
    Link * temp = head;
    while (temp != NULL){
        printf("Name: %s Value: %s\n",temp->name,temp->value);
        temp=temp->next;
    }
}
/*Lab 6*/
void replaceDollars(cmdLine *cmd){
    int i;
    char *val;
    cmdLine *temp = cmdL;
    while(temp !=NULL){
        for (i=0; i<temp->argCount; i++){
            if(strncmp(temp->arguments[i],"$",1)==0){
                val= findVar((temp->arguments[i])+1);
                if(val){
                    replaceCmdArg(temp,i,val);
                }
                else fprintf(stderr,"No such variable %s\n",(temp->arguments[i]));
            }
        }temp=temp->next;
    }
}
/*Lab 6*/
void freeList(){
    Link * temp = head;
    Link * next = head;
    while (temp != NULL){
        free(temp->name);
        free(temp->value);
        next=temp->next;
        free(temp);
        temp=next;
    }
}
/*Lab 6 Task 4- I did copy paste from my task3, with little changes*/
void handlePipes(cmdLine *firstLine, cmdLine *secondLine){
    int pipefd[2];
    int child1Pid=-1;
    int child2Pid=-1;

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

        if(firstLine->inputRedirect!=NULL){
        if(debug) fprintf(stderr,"Input Redirect...\n");
        fclose(stdin);
        fopen(firstLine->inputRedirect,"r");
        }

        if(debug) fprintf(stderr,"child1>redirecting stdout to the write end of the pipe…\n");
        fclose(stdout);     /*close standart output*/
        dup(pipefd[1]);   /*duplicate the write-end of the pipe using dup*/
        close(pipefd[1]);          /*Close the file descriptor that was duplicated.*/
        if(debug) fprintf(stderr,"child1>going to execute cmd: …\n");
        execvp(firstLine->arguments[0],firstLine->arguments);       /*Execute "left side of pipe"*/
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
        if(secondLine->outputRedirect!=NULL){
        if(debug) fprintf(stderr,"Output Redirect...\n");
        fclose(stdout);
        fopen(secondLine->outputRedirect,"w+");
        }

        if(debug) fprintf(stderr,"child2>redirecting stdin to the read end of the pipe…\n");
        fclose(stdin);             /*close standart intput*/
        dup(pipefd[0]);     /*duplicate the read-end of the pipe using dup*/
        close(pipefd[0]);                /*Close the file descriptor that was duplicated.*/
        if(debug) fprintf(stderr,"child2>going to execute cmd: …\n");
        execvp(secondLine->arguments[0],secondLine->arguments);               /*Execute "right side of pipe"*/
    }else if(child2Pid!=0 && child1Pid!=0){
        if(debug) fprintf(stderr,"parent_process>closing the read end of the pipe…\n");
        close(pipefd[0]); /*Close the read end of the pipe*/
    }

    if(debug) fprintf(stderr,"parent_process>waiting for child processes to terminate…\n");
    waitpid(child1Pid,&status,0);
    waitpid(child2Pid,&status,0);

    if(debug) fprintf(stderr,"parent_process>exitin…\n");
}

void checkArguments(int argc, char** argv){
    if(argc>1) {
        int i=0;
        for (i = 1; i < argc; i++) {
            if (strcmp(argv[i], "-d") == 0) {/*debug mode*/
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
            freeList();
            freeProcessList(process_head);
            exit(0);
        }
        cmdL = parseCmdLines(buff);
        replaceDollars(cmdL);

        if(strcmp(cmdL->arguments[0],"quit")==0){
            if(debug) fprintf(stderr,"Exiting...\n");
            freeList();
            freeCmdLines(cmdL);
            freeProcessList(process_head);
            exit(0);
        }
            /* task 1c - handle "cd" */
        else if(strncmp(cmdL->arguments[0],"cd",2)==0){
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
        }/* task 2 - handle "set" */
        else if(strncmp(cmdL->arguments[0],"set",3)==0){
            handleSet();
            freeCmdLines(cmdL);
        }/* task2 handle vars*/
        else if(strncmp(cmdL->arguments[0],"vars",4)==0){
            handleVars();
            freeCmdLines(cmdL);
        }/*if we recived pipe - task 4 */
        else if(cmdL->next!=NULL){
            handlePipes(cmdL,cmdL->next);
            freeCmdLines(cmdL);
        }/*open new process to execute line */
        else if((childPid=fork())<0){
            perror("Error at fork()");
            freeCmdLines(cmdL);
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
