#include <stdio.h>
#include <stdlib.h>
FILE *input;

void PrintHex(int buffer[], int length) {	
        fprintf(stdout,"%02hhX", buffer[0]);
        printf(" ");
}

int main(int argc, char **argv) {
    char *filename = argv[1]; //filename is at the second place
    input = fopen(filename,"r");
    int *buffer = (int*)malloc(sizeof(int));

    while(fread(buffer, sizeof(char), 1,input)==1){
        PrintHex(buffer,1);
    }
    printf("\n");
    free(buffer);
    fclose(input);
    return 0;
}
