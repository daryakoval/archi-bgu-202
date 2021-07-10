
#define SYS_WRITE 4
#define STDOUT 1

int main (int argc , char* argv[], char* envp[])
{
  char * str;
  str = "Hello World \n";
  system_call(SYS_WRITE,STDOUT,str, 13);
  return 0;
}
