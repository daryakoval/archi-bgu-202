#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct state {
  char debug_mode;
  char file_name[128];
  int unit_size;
  unsigned char mem_buf[10000];
  size_t mem_count;
  /*
   .
   .
   Any additional fields you deem necessary
  */
} state;

struct fun_desc {
    char *name;
    void (*fun)(state* s);
};
void toggleDebug(state* s){
    if(s->debug_mode==0){
        s->debug_mode=1;
        printf("Debug flag now on\n");
    }else {
        s->debug_mode=0;
        printf("Debug flag now off\n");
    }
}

void SetFileName(state *s){
    printf("Please enter file name:\n");
    char buff[128];
    fgets(buff,128,stdin);
    sscanf(buff,"%s",s->file_name);
    if(s->debug_mode==1)
    printf ("Debug: file name set to %s\n",s->file_name);
}

void SetUnitSize(state *s){
    printf("Please enter unit size: \n");
    int index=0;
    char buff[32];
    fgets(buff,32,stdin);
    sscanf(buff,"%d",&index);
    if((index==1) || (index==2) || (index == 4)){
        s->unit_size=index;
        if(s->debug_mode==1) printf ("Debug: set size to %d\n",s->unit_size);
    }else{
        printf("Error : size not valid\n");
    }
}

void quit(state *s){
    if(s->debug_mode==1)
    printf ("quitting..\n");
    free(s);
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

void debugPrintStart(state *s){
    if(s->debug_mode==1)
    printf ("Unit Size: %d, FileName: %s, MemCount: %d\n\n",s->unit_size,s->file_name,s->mem_count);
}

void debug(state *s, char* str){

}
int main(int argc, char **argv) {
    int i=0;
    int getI=0;
    struct state *s = (state*)calloc(sizeof(state),1);
    s->debug_mode=0;

    struct fun_desc menu[]= {{"Toggle Debug Mode", toggleDebug}, {"Set File Name",SetFileName} , {"Set Unit Size", SetUnitSize } ,{"Quit", quit} , {NULL,NULL}};

    int sizeStruct= sizeof(struct fun_desc);
    int sizeMenu = sizeof(menu);
    int sizeOfMenuArray= (sizeMenu/sizeStruct)-1;

    while(1){
        i=0;
        debugPrintStart(s);
        printf("Please choose a function:\n");
        while (menu[i].name!=NULL){
            printf("%d) %s \n",i,menu[i].name);
            i++;
        }
        printf("Option:");

        getI = getIndex();
        int valid = checkBounds(sizeOfMenuArray,getI);

        if(valid) {
            menu[getI].fun(s);
            printf("DONE.\n\n");
        }
    }
    return 0;
}
