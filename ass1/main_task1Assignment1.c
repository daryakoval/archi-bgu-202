#include <stdio.h>
#define	MAX_LEN 34			/* maximal input string size */
					/* enough to get 32-bit string + '\n' + null terminator */
extern void assFunc(int x, int y);

extern char c_checkValidity(int x, int y){
  if(x>=y) return '1';
  else return '0';
}

int main(int argc, char** argv){
  char buf[MAX_LEN ];
  int x=0,y=0;

  for(int i=0; i<2; i++){
    fgets(buf, MAX_LEN, stdin);		/* get user input string */ 
    if(i==0) sscanf(buf,"%d",&x);
    else sscanf(buf,"%d",&y);
  }

  assFunc(x,y);	    /* call your assembly function */

  return 0;
}