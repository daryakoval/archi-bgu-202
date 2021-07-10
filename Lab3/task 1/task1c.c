#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

typedef struct virus {
    unsigned short SigSize;
    char virusName[16];
    char* sig;
} virus;
typedef struct link link;
struct link {
    link *nextVirus;
    virus *vir;
};
struct fun_desc {
    char *name;
    void (*fun)();
};

void printVirus(virus* virus, FILE* output);
FILE *signatures;
FILE *file;
link* start =NULL;
char* filename;
int fileLength =0;

void PrintHex(FILE *output,char* buffer, int length) {
    for(int i = 0; i<length; i++){
        fprintf(output,"%02hhX", buffer[i]);
        fprintf(output," ");
    }
    fprintf(output,"\n\n");
}

virus* readVirus(FILE* from){
    unsigned short N=0;
    char store[18];
    int finish = fread(store, 1, 18,from);

    if(finish!=0) {
        N=store[0]+(store[1]<<8);

        unsigned char c = 1;
        char *sig = (char *) malloc(sizeof(char) * (c << 16));
        fread(sig, sizeof(char), N, from);

        struct virus *retVirus = (virus*)malloc(sizeof(virus)+N);
        retVirus->SigSize=N;
        for(int i=0; i<16; i++){
            retVirus->virusName[i]=store[i+2];
        }
        retVirus->sig=sig;

        return retVirus;
    }
    return NULL;
}

void printVirus(virus* virus, FILE* output){
    fprintf(output,"%s","Virus name:");
    fprintf(output,"%s\n",virus->virusName);
    fprintf(output,"%s","Virus size:");
    fprintf(output,"%d\n",virus->SigSize);
    fprintf(output,"%s\n","signature:");
    PrintHex(output,virus->sig,virus->SigSize);
}

void list_print(link *virus_list, FILE* output){
    link *temp=virus_list;
    while(temp!=NULL){
        printVirus(temp->vir,output);
        temp=temp->nextVirus;
    }
}

void list_free(link *virus_list){
    link *next;
    link *current = virus_list;
    while(current!=NULL){
        next = current->nextVirus;
        free(current->vir->sig);
        free(current->vir);
        free(current);
        current=next;
    }
}

link* list_append(link* virus_list, virus* data){
    link *newLink = (link*)malloc(sizeof(link));
    newLink->vir=data;
    //If the given list is null - create new list head
    if(virus_list == NULL){
        newLink->nextVirus=NULL;
        return newLink;

    }
    /*
    //adds to beginning;
    newLink->nextVirus=virus_list;
    return newLink;*/

    //adds to the end:
    link *temp =virus_list;
    newLink->nextVirus=NULL;
    while(temp->nextVirus!=NULL){
        temp=temp->nextVirus;
    }
    temp->nextVirus=newLink;
    return virus_list;
}

void loadSignatures(){
    printf("Please enter signatures file name:\n");
    char buff[1024];
    fgets(buff,1024,stdin);
    char signaturesFile[1024];
    sscanf(buff,"%s",signaturesFile);
    signatures = fopen(signaturesFile,"r");

    virus* tempData;
    do{
        tempData = readVirus(signatures);
        if(tempData!=NULL)
            start = list_append(start,tempData);
    }while(tempData!=NULL);

    fclose(signatures);
}

void printSignatures(){
    list_print(start,stdout);
}

//TODO check 1c
void detect_virus(char *buffer, unsigned int size, link *virus_list){
    unsigned short virSize;
    int memCmpr;
    link *temp = virus_list;
    while(temp!=NULL){
        virSize = temp->vir->SigSize;
        for(unsigned int i=0; i<=size-virSize; i++){
            memCmpr = memcmp(buffer+i,temp->vir->sig,virSize);
            if(memCmpr==0){
                fprintf(stdout,"Starting byte location: %d\n",i);
                fprintf(stdout,"Virus name: %s\n",temp->vir->virusName);
                fprintf(stdout,"Size of virus signature: %d\n\n",virSize);
            }
        }
        temp=temp->nextVirus;
    }
}

void DetectVirus(){
    file = fopen(filename,"r");

    char *buffer = (char *) malloc(sizeof(char) * (10000));
    fseek(file,0,SEEK_END);
    fileLength=ftell(file);
    rewind(file);
    if(fileLength>10000) fileLength=10000;
    fread(buffer, sizeof(char), fileLength, file);

    detect_virus(buffer,fileLength,start);

    fclose(file);
    free(buffer);
}

//TODO 2b
void kill_virus(char *fileName, int signatureOffset, int signatureSize){
}

void FixFile(){
}

void quit(){
    list_free(start);
    exit(0);
}

int checkBounds(int bound, int getI){
    if(getI>=0 && getI<bound){
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

int main(int argc, char **argv) {
    int i=0;
    int getI=0;
    bool t=true;

    struct fun_desc menu[]= {{"Load signatures", loadSignatures}, {"Print signatures",printSignatures} , {"Detect viruses", DetectVirus } , {"Fix file", FixFile},{"Quit", quit} , {NULL,NULL}};

    int sizeStruct= sizeof(struct fun_desc);
    int sizeMenu = sizeof(menu);
    int sizeOfMenuArray= (sizeMenu/sizeStruct)-1;

    if(argc>1)
        filename=argv[1];

    while(t){
        i=0;
        printf("Please choose a function:\n");
        while (menu[i].name!=NULL){
            printf("%d) %s \n",i+1,menu[i].name);
            i++;
        }
        printf("Option:");

        getI = getIndex()-1;
        int valid = checkBounds(sizeOfMenuArray,getI);

        if(valid) {
            menu[getI].fun();
            printf("DONE.\n\n");
        }
    }
    return 0;
}
