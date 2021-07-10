#include "util.h"

#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_READ 3
#define SYS_WRITE 4
#define SYS_LSEEK 19
#define SEEK_SET 0
#define STDOUT 1
#define O_RDRW 2

extern int system_call();

int main (int argc , char* argv[], char* envp[])
{
  int fd;
  char * name;
  char * fileName;

  if(argc!=3){
    return 0x55;
  }

  fileName = argv[1];
  name = argv[2];
  fd = system_call(SYS_OPEN,fileName, O_RDRW,0777);
  if(fd==-1) return 0x55;

  system_call(SYS_LSEEK,fd, 0x291, SEEK_SET);
  if(system_call(SYS_WRITE,fd, name, strlen(name))==-1) return 0x55;
  if(system_call(SYS_WRITE,fd, ".\n\0", 3)==-1) return 0x55;

  system_call(SYS_CLOSE,fd);
    
  return 0;
}