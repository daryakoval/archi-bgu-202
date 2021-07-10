#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int addr5;	//uninialised data - bss
int addr6;	//uninialised data - bss

int foo();	//section text 
void point_at();
void foo1();   //section text 
void foo2();  //section text 

int main (int argc, char** argv){
    int addr2; //stack
    int addr3;  //stack
    char* yos="ree"; //yoss - rodata - initialised or heap?
                    //&yoss - stack
    int * addr4 = (int*)(malloc(50)); //addr4 - heap, &addr4 - stack
    printf("- &addr2: %p\n",&addr2);
    printf("- &addr3: %p\n",&addr3);
    printf("- addr4: %p\n",addr4);
    printf("- &addr4: %p\n",&addr4);
    printf("- foo: %p\n",foo);
    printf("- &addr5: %p\n",&addr5);
    printf("- &addr6: %p\n",&addr6);
    printf("- yos: %p\n",yos);
    printf("- &yos: %p\n",&yos);


	point_at();

    printf("- foo: %p\n",foo);
    printf("- &foo: %p\n",&foo);
    printf("- &foo1: %p\n" ,&foo1);
    printf("- &foo2: %p\n" ,&foo2);
    printf("- &foo2 - &foo1: %ld\n" ,&foo2 - &foo1);
    return 0;
}

int foo(){
    return -1;
}

void point_at(){
    int local;	//stack
	static int addr0 = 2; //section data
    static int addr1; // data ? or bss?
	
    printf("- local: %p\n",&local);
	printf("- addr0: %p\n", &addr0);
    printf("- addr1: %p\n",&addr1);
}

void foo1 (){    
    printf("foo1\n"); 
}

void foo2 (){    
    printf("foo2\n");    
}
