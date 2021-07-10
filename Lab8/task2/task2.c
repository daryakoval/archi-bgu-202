#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <elf.h>

struct fun_desc {
    char *name;
    void (*fun)();
};

int debug_mode =0;
int fd=-1;
char filename[100];
void *mapStart;
Elf32_Ehdr *elf=NULL; 


/*copied from util.c file provided at lab4*/
char itoaBuf[12];
char *itoa(int num){
	char* p = itoaBuf+12-1;
	*p='\0';
	do {
		*(--p) = '0' + num%10;
	} while(num/=10);
	return p;
}

void toggleDebug(){
    if(debug_mode==0){
        debug_mode=1;
        printf("Debug flag now on\n");
    }else {
        debug_mode=0;
        printf("Debug flag now off\n");
    }
}

/*Task0*/
void ExamineELFFile(){
    char buf[1024];
    int length;

    printf("Please enter <filename> \n");
    fgets(buf,1024,stdin);
    sscanf(buf,"%s",filename);

    if(fd!=-1){
        close(fd);
    }
    fd = open(filename,O_RDONLY);
    if(fd==-1) perror("Error at open file");
    else{
        length = lseek(fd,0,SEEK_END);
        mapStart = mmap(NULL, length, PROT_READ,MAP_SHARED, fd, 0);
        elf=(Elf32_Ehdr*)mapStart;
        if (elf == MAP_FAILED)
            perror("Error at mmap");
        
        printf("Magic numbers :\t %X %C %X\n",elf->e_ident[EI_MAG1],elf->e_ident[EI_MAG2],elf->e_ident[EI_MAG3]);
        printf("Data encoding scheme: ");
        if(elf->e_ident[EI_DATA]==ELFDATANONE) printf("\t Invalid data encoding\n");
        if(elf->e_ident[EI_DATA]==ELFDATA2LSB) printf("\t 2's complement, little endian\n");
        if(elf->e_ident[EI_DATA]==ELFDATA2MSB) printf("\t 2's complement, big endian\n");
        printf("Entry point:\t %X \n",elf->e_entry);
        printf("The file offset in which the section header table resides:\t %d \n",elf->e_shoff);
        printf("Number of section headers:\t %d \n",elf->e_shnum);
        printf("The size of each section header entry:\t %d \n",elf->e_shentsize);
        printf("The file offset in which the program header table resides:\t %d \n",elf->e_phoff);
        printf("Number of program headers:\t %d \n",elf->e_phnum);
        printf("The size of each program header entry:\t %d \n",elf->e_phentsize);
        close(fd);
    }
}

char* findName(int index){
    Elf32_Shdr *headerTable= (Elf32_Shdr*)(mapStart+elf->e_shoff);
    char* namesTableOffset= mapStart+headerTable[elf->e_shstrndx].sh_offset;
    char* name = namesTableOffset+index;
    return name;
}

/*Task1*/
void PrintSectionNames(){
    int sectionsNum;
    Elf32_Shdr *header;
    fd = open(filename,O_RDONLY);
    if(fd==-1) perror("Error at open file");
    else{
        sectionsNum= elf->e_shnum;
        printf("[Nr]\t Name \t Adress\t\t Offset\t size\t type\t\n");
        for(int i=0; i<sectionsNum; i++){
            header = (Elf32_Shdr*)(mapStart+elf->e_shoff+(i*elf->e_shentsize));
            printf("[%d] \t%s \t%08X \t%X \t%X \t%d\n", i,findName(header->sh_name),
            header->sh_addr, header->sh_offset , header->sh_size, header->sh_type);
        }
        close(fd);
    }

}
Elf32_Shdr* symTabHeader(){
    int sectionsNum= elf->e_shnum;
    Elf32_Shdr *header;
    for(int i=0; i<sectionsNum; i++){
            header = (Elf32_Shdr*)(mapStart+elf->e_shoff+(i*elf->e_shentsize));
            if(header->sh_type==SHT_SYMTAB) return header; 

    }
}
char* findSectionName(int index){
    if(index==SHN_ABS) return "";
    Elf32_Shdr *headerTable= (Elf32_Shdr*)(mapStart+elf->e_shoff);
    char* namesTableOffset= mapStart+headerTable[elf->e_shstrndx].sh_offset;
    char* name = namesTableOffset+headerTable[index].sh_name;
    return name;
}

char* findSymbolName(int index, Elf32_Shdr *SymHeader){
    Elf32_Shdr *headerTable= (Elf32_Shdr*)(mapStart+elf->e_shoff);
    char* namesTableOffset= mapStart+headerTable[SymHeader->sh_link].sh_offset;
    char* name = namesTableOffset+index;
    return name;
}
char* sectionIndicate(int sec){
    if(sec==SHN_ABS){
        return "ABS";
    }else if(sec==SHN_UNDEF){
        return "UND";
    }else return itoa(sec);
    
}

/*Task2*/
void PrintSymbols(){
    Elf32_Shdr *SymHeader;
    Elf32_Sym *symTable;
    int size;
    fd = open(filename,O_RDONLY);
    if(fd==-1) perror("Error at open file");
    else{
        SymHeader=symTabHeader();
        size=(SymHeader->sh_size)/(SymHeader->sh_entsize);

        printf("Index:\t Value \t Section Index\t Section Name\t Symbol Name:\n");

        for(int i=0; i<size; i++){
            symTable = (Elf32_Sym*)(mapStart+SymHeader->sh_offset+i*SymHeader->sh_entsize);
            printf("%d: \t%08X  \t%s \t%s \t%s\n", i,symTable->st_value,
            sectionIndicate(symTable->st_shndx),findSectionName(symTable->st_shndx),
            findSymbolName(symTable->st_name,SymHeader));
        }


        close(fd);
    }

}

/*Task3*/
void RelocationTables(){

}

void quit(){
    if(debug_mode==1)
    printf ("quitting..\n");
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
   

    struct fun_desc menu[]= {{"Toggle Debug Mode", toggleDebug}, {"Examine ELF File",ExamineELFFile} , {"Print Section Names", PrintSectionNames }, 
    {"Print Symbols", PrintSymbols } , {"Quit", quit} , {NULL,NULL}};

    int sizeStruct= sizeof(struct fun_desc);
    int sizeMenu = sizeof(menu);
    int sizeOfMenuArray= (sizeMenu/sizeStruct)-1;

    while(1){
        i=0;
        printf("Please choose a function:\n");
        while (menu[i].name!=NULL){
            printf("%d) %s \n",i,menu[i].name);
            i++;
        }
        printf("Option:");

        getI = getIndex();
        int valid = checkBounds(sizeOfMenuArray,getI);

        if(valid) {
            menu[getI].fun();
            printf("DONE.\n\n");
        }
    }
    return 0;
}
