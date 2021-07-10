#include <stdio.h>

int main(){

    int iarray[] = {1,2,3};
    char carray[] = {'a','b','c'};
    int* iarrayPtr =iarray;
    char* carrayPtr = carray;

    for(int i=0; i<3;i++){
        printf("%d\n",*(iarrayPtr+i));
    }
    for(int i=0; i<3;i++){
        printf("%c\n",*(carrayPtr+i));
    }

    int *p;
    printf("%p",p);

    return 0;
}
