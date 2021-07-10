#include "util.h"

#define SYS_EXIT 1
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_READ 3
#define SYS_WRITE 4
#define SYS_LSEEK 19
#define SEEK_SET 0
#define STDIN 0
#define STDOUT 1
#define STDERR 2
#define O_RDONLY 0 
#define O_WRONLY 1
#define O_CREAT 64

extern int system_call();
int i, output, input, debug, rd, wr;
char *inFileName, *outFileName;
int c;


void checkArguments(int argc, char** argv){
output=STDOUT;
input=STDIN;
  if(argc>1) {

        for (i = 1; i < argc; i++) {
            if (strcmp(argv[i], "-D") == 0) {/*debug mode*/
                debug = 1;
            }
            else if(strncmp(argv[i],"-o",2)==0) {/*-o - print to file mode*/
                outFileName = argv[i]+2;
                output=system_call(SYS_OPEN,outFileName, O_CREAT | O_WRONLY,0777);
            }else if(strncmp(argv[i],"-i",2)==0) {/*-i read from input*/
                inFileName = argv[i]+2;
                input=system_call(SYS_OPEN,inFileName, O_RDONLY,0777);
            }else {
              system_call(SYS_WRITE,STDOUT, "invalid parameter\n", 18);
              system_call(SYS_EXIT,0x55);
            }
        }

    }
}

int main (int argc , char* argv[], char* envp[])
{
  debug=0;
  checkArguments(argc,argv);
  if(output < 0 || input < 0 ) system_call(SYS_EXIT,0x55);

  while((rd = system_call(SYS_READ,input, &c, 1))>0){
    if(debug && c!=10){
      system_call(SYS_WRITE,STDERR,"SYS_READ 3 ",12);
      system_call(SYS_WRITE,STDERR, itoa(rd), strlen(itoa(rd)));
      system_call(SYS_WRITE,STDERR, "\n", 1);
    }
    if(c>=97 && c<=122){
      c=c-32;
    }
    if(c==10 && debug){
      system_call(SYS_WRITE,STDERR, "\n", 1);
    }
    wr= system_call(SYS_WRITE,output, &c, 1);
    if(debug && c!=10){
      system_call(SYS_WRITE,STDERR,"SYS_WRITE 4 ",13);
      system_call(SYS_WRITE,STDERR, itoa(wr), strlen(itoa(wr)));
      system_call(SYS_WRITE,STDERR, "\n", 1);
    }
  }
   
  if(input != STDIN) system_call(SYS_CLOSE,input);
  if(output != STDOUT) system_call(SYS_CLOSE,output);
  return 0;
}