#include <stdlib.h>
#include <stdio.h>
#include <string.h>
char* carray;
char* mapped_array;
int i=0;

char censor(char c) {
    if(c == '!')
        return '.';
    else
        return c;
}

char encrypt(char c){
    if(c>=32 && c<=126)
        c=c+3;
    return c;
} /* Gets a char c and returns its encrypted form by adding 3 to its value.
          If c is not between 0x20 and 0x7E it is returned unchanged */
char decrypt(char c){
    if(c>=32 && c<=126)
        c=c-3;
    return c;
} /* Gets a char c and returns its decrypted form by reducing 3 to its value.
            If c is not between 0x20 and 0x7E it is returned unchanged */
char dprt(char c){
    printf("%d\n",c);
    return c;
} /* dprt prints the value of c in a decimal representation followed by a
           new line, and returns c unchanged. */
char cprt(char c){
    if(c>=32 && c<=126){
        printf("%c\n",c);
    }else
    {
        printf("%c\n",'.');
    }
    return c;

} /* If c is a number between 0x20 and 0x7E, cprt prints the character of ASCII value c followed
                    by a new line. Otherwise, cprt prints the dot ('.') character. After printing, cprt returns
                    the value of c unchanged. */
char my_get(char c){
    return fgetc(stdin);
}
/* Ignores c, reads and returns a character from stdin using fgetc. */

char quit(char c){
    if(c=='q'){
        free(carray);
        free(mapped_array);
        exit(0);
    }return c;
} /* Gets a char c,  and if the char is 'q' , ends the program with exit code 0. Otherwise returns c. */

char* map(char *array, int array_length, char (*f) (char)){
    mapped_array = (char*)(malloc(array_length*sizeof(char)));
    for(int i =0; i<array_length; i++){
        mapped_array[i]=(*f)(array[i]);
    }
    free(carray);

    if((*f)==my_get){
        if(mapped_array[4]!='\n'){
            while(getchar()!='\n');
        }
    }

    return mapped_array;
}

struct fun_desc {
    char *name;
    char (*fun)(char);
};

int checkBounds(int bound, int input){
    if(input>=0 && input<bound){
        printf("Within Bounds\n");
        return 1;
    }else{
        printf("Not within bounds\n\n");
        return 0;
    }
}

int getIndex(){
    int index=0;
    char buff[1024];
    fgets(buff,1024,stdin);
    sscanf(buff,"%d",&index);
    return index;
}

int main(){
    int input;
    int base_len = 5;
    carray=(char*)(malloc(5*sizeof(char)));
    struct fun_desc menu[]= {{"Censor",censor}, {"Encrypt",encrypt} , {"Decrypt", decrypt} , {"Print dec", dprt}, {"Print string", cprt}, {"Get string", my_get},{"Quit", quit} , {NULL,NULL}};

    int sizeStruct= sizeof(struct fun_desc);
    int sizeMenu = sizeof(menu);
    int sizeOfMenuArray= (sizeMenu/sizeStruct)-1;

    while(1){

        printf("Please choose a function:\n");
        while (menu[i].name!=NULL){
            printf("%d) %s \n",i,menu[i].name);
            i++;
        }
        printf("Option:");

        input = getIndex();
        int valid = checkBounds(sizeOfMenuArray,input);

        if(valid) {
            carray = map(carray, base_len, menu[input].fun);
            printf("DONE.\n\n");
        }
        i=0;
    }

    return 0;

}

