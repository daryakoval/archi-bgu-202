
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(int argc, char** argv){

    int i,c,d;
    FILE * output=stdout;

    d=0;
    for(i=1; i<argc; i++){
        if(strcmp(argv[i],"-D")==0){
            d=1;
            output=stderr;
        }
        else{
            printf("invalid parameter - %s\n",argv[i]);
            return 1;
        }
    }

    c= getchar();
    //putc('\n',stdout);

    while(c!=-1){
        if(d && c!=10){

            fprintf(output,"%d", c);
            fprintf(output,"\t");
        }
        if(c>=97 && c<=122){
            c=c-32;
        }
        if(d && c!=10){
            fprintf(output,"%d\n", c);
        }
        //TODO: how to make the text line to print the last?
        putc(c,stdout);
        c = getchar();
    }

    return 0;
}