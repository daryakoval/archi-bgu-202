#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int digit_cnt(char *string){
    int count =0;
    for(int i=0; string[i]!='\0'; i++){
        if(string[i]<='9' && string[i]>='0')
            count++;
    }
    return count;
}


int main(int argc, char **argv) {
    if(argc<2) printf("Please enter string");
    
    printf("The number of digits in the string is: %d\n", digit_cnt(argv[1]));
}
