#include <stdio.h>


int main(){

    int c= getchar();
    while(c!=-1){

        if(c>=97 && c<=122){
            c=c-32;
        }
        putchar(c);
        c = getchar();
    }

     return 0;
}