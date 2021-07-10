#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#define DECIMAL "%d\n"
#define HEXADECIMAL "%02X\n"
#define KB(i) ((i)*1<<10)

typedef struct state {
    char debug_mode;
    char file_name[128];
    int unit_size;
    unsigned char mem_buf[10000];
    size_t mem_count;
    char *display_mode;

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

/*Task 1a*/
void LoadIntoMemory(state *s){
    char buff[32];
    int fd;
    int location;
    int length;
    if(s->file_name){
        fd = open(s->file_name,O_RDWR);
        if(fd>=0){
            printf("Please enter <location> <length> \n");
            fgets(buff,32,stdin);
            sscanf(buff,"%X %d",&location, &length);
            if(s->debug_mode) printf("Filename: %s, location : %X, length: %d\n",s->file_name,location,length);
            lseek(fd, location, SEEK_SET);
	        s->mem_count=read(fd,s->mem_buf,s->unit_size*length);
            close(fd);
            printf("Loaded %d units into memory\n",length);
        }
        else perror("Error at open file");
    }else
        printf("Filename is Null - not setted yet\n");
}

/*Task 1b*/
void ToggleDisplayMode(state *s){
    if(strcmp(s->display_mode,DECIMAL)==0){
        s->display_mode=HEXADECIMAL;
        printf("Display flag now on, hexadecimal representation\n");
    }else{
        s->display_mode=DECIMAL;
        printf("Display flag now off, decimal representation\n");
    }
}

/* Prints the buffer to screen by converting it to text with printf */
/*COPY - PASTE FROM UNITS FILE- PROVIDED AT LAB ASSIGNMENT*/
char* unit_to_format(int unit_size,state *s) {
    if(strcmp(s->display_mode,HEXADECIMAL)==0){
        static char* formats[] = {"%#hhX\n", "%#hX\n", "No such unit", "%#X\n"};
        return formats[unit_size-1];
    }
    static char* formats[] = {"%#hhd\n", "%#hd\n", "No such unit", "%#d\n"};
    return formats[unit_size-1];
    
}
void print_units(state *s,char* buffer, int u, int unit_size) {
    int written=0;
        char* end = buffer + unit_size*u;
        while ((buffer < end)) {
            //print ints
            int var = *((int*)(buffer));
            written += printf(unit_to_format(unit_size,s), var);
            buffer += unit_size;
        }
}
void printD_Or_H(state *s){
    if(strcmp(s->display_mode,DECIMAL)==0) printf("Decimal\n=======\n");
    else printf("Hexadecimal\n===========\n");
}

/*Task 1c */
void MemoryDisplay(state *s){
    char buf[32];
    int u;
    int *addr;
    printD_Or_H(s);

    printf("Please enter <u> <addr>\n");
    fgets(buf,32,stdin);
    sscanf(buf,"%d" "%p",&u,&addr);

    if(s->debug_mode) printf("Filename: %s, addr : %X, u: %d\n",s->file_name,addr,u);
    if(!addr) print_units(s,(char*)s->mem_buf,u,s->unit_size);
    else print_units(s,(char*)addr,u,s->unit_size);
}

/*Task 1d*/
void SaveIntoFile(state *s){
    char buf[1024];
    int fileEnd;
    FILE *fp;
    int sourceadress;
    int targetlocation;
    int length;
    if(s->file_name){
        fp=fopen(s->file_name,"r+");
        if(fp){
            printf("Please enter <source-address> <target-location> <length> \n");
            fgets(buf,1024,stdin);
            sscanf(buf,"%X" "%X" "%d",&sourceadress, &targetlocation, &length);

            if(s->debug_mode) printf("Filename: %s, source-address: %X, target-location: %X, length: %d\n",s->file_name,sourceadress,targetlocation,length);

            fseek(fp,0,SEEK_END);
            fileEnd=ftell(fp);
            if(fileEnd<=targetlocation){
                printf("Taregt location is greater than file length\n");
            }else{
                fseek(fp,targetlocation,SEEK_SET);
                if(sourceadress==0) fwrite(s->mem_buf, s->unit_size, length, fp);
                else fwrite((char*)sourceadress, s->unit_size, length, fp);
            }
            fclose(fp);
        }
        else perror("Error at open file");
    }else
        printf("Filename is Null - not setted yet\n");
}

/*Task 1e*/
void MemoryModify(state *s){
    char buf[1024];
    unsigned int location;
    unsigned int val;

    printf("Please enter <location> <val> \n");
    fgets(buf,1024,stdin);
    sscanf(buf,"%X" "%X" ,&location, &val);

    if(s->debug_mode) printf("Filename: %s, location: %X, val: %X\n",s->file_name,location,val);

    if(s->mem_count>location){
        memcpy(s->mem_buf+location,&val,s->unit_size);
    }
    else printf("Target location is greater than mem length\n");
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

int main(int argc, char **argv) {
    int i=0;
    int getI=0;
    struct state *s = (state*)calloc(sizeof(state),1);
    s->debug_mode=0;
    s->display_mode=DECIMAL;
    s->unit_size=1;

    struct fun_desc menu[]= {{"Toggle Debug Mode", toggleDebug}, {"Set File Name",SetFileName} , {"Set Unit Size", SetUnitSize },
    {"Load Into Memory", LoadIntoMemory },{"Toggle Display Mode", ToggleDisplayMode } ,{"Memory Display", MemoryDisplay },
    {"Save Into File", SaveIntoFile },    {"Memory Modify", MemoryModify }, {"Quit", quit} , {NULL,NULL}};

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
