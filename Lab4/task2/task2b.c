#include "util.h"

#define SYS_EXIT 1
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_READ 3
#define SYS_WRITE 4
#define SYS_GETDENTS 141
#define STDOUT 1
#define STDERR 2
#define O_RDONLY 0 
#define BUFF_SIZE 8192


typedef struct ent{
  int inode;
  int offset;
  short len;
  char buf[1];
}ent;

extern int system_call();
char* findType(char* name);
int i, pMode, aMode, debug, fd, ret, count;
char *Pprefix, *Aprefix;
char buff[BUFF_SIZE];


void checkArguments(int argc, char** argv){
  pMode=0; aMode=0; debug=0;
  if(argc>1) {

        for (i = 1; i < argc; i++) {
            if (strcmp(argv[i], "-D") == 0) {/*debug mode*/
                debug = 1;
            }
            else if(strncmp(argv[i],"-p",2)==0) {/*-p - p mode*/
                Pprefix = argv[i]+2;
                pMode=1;
            }else if(strncmp(argv[i],"-a",2)==0) {/*-a a mode*/
                Aprefix = argv[i]+2;
                aMode=1;
            }else {
              system_call(SYS_WRITE,STDOUT, "invalid parameter \n", 19);
              system_call(SYS_EXIT,0x55);
            }
        }

    }
}

void debugPrint(char* sysName, int sysnameSize, int retValue){
  system_call(SYS_WRITE,STDERR,sysName,sysnameSize);
  system_call(SYS_WRITE,STDERR, itoa(retValue), strlen(itoa(retValue)));
  system_call(SYS_WRITE,STDERR, "\n", 1);
}

int main (int argc , char* argv[], char* envp[])
{
  struct ent *entp;
  
  checkArguments(argc,argv);

  /*Start*/
  ret=system_call(SYS_WRITE,STDOUT,"Flame 2 strikes! \n",18);
  if(debug) debugPrint("SYS_WRITE 4 ", 13,ret);

  /* open current directory*/
  fd=system_call(SYS_OPEN,".", O_RDONLY,0777);
  if(debug) debugPrint("SYS_OPEN 5 ", 12,fd);
  if(fd < 0) system_call(SYS_EXIT,0x55);

  /*call getdents*/
  count= system_call(SYS_GETDENTS,fd,buff,BUFF_SIZE);
  if(debug) debugPrint("SYS_GETDENTS 141 ",18,count);

  /*print in loop all files*/
  i=0;
  while(i<count){
    entp =(struct ent*) (buff+i);

    if(pMode && strncmp(entp->buf,Pprefix,strlen(Pprefix))==0){

      ret=system_call(SYS_WRITE,STDOUT,entp->buf,strlen(entp->buf));
      if(debug) debugPrint("SYS_WRITE 4 ", 13,ret);

      system_call(SYS_WRITE,STDOUT," Type: ",8);
      ret=system_call(SYS_WRITE,STDOUT,findType(entp->buf),strlen(findType(entp->buf)));
      system_call(SYS_WRITE,STDOUT,"\n",1);
      if(debug) debugPrint("SYS_WRITE 4 ", 13,ret+9);

    }
    else if(!pMode){
      
      ret=system_call(SYS_WRITE,STDOUT,entp->buf,strlen(entp->buf));
      system_call(SYS_WRITE,STDOUT,"\n",1);

      if(debug) debugPrint("SYS_WRITE 4 ", 13,ret+1);

    }
    if(aMode && strncmp(entp->buf,Aprefix,strlen(Aprefix))==0){
      
    }

    i=i+entp->len;

  }

  system_call(SYS_CLOSE,fd);
  return 0;
}

char* findType(char* name){
  int j;
  for(j=0; name[j]!=0; j++){
    if(name[j]=='.'){
      return name+j+1;
    }
  }return " ";
}
