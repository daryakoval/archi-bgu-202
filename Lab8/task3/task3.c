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
struct stat fd_stat;
int length;
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

void printData(int elfData){
    if(elfData==ELFDATANONE) printf("\t Invalid data encoding\n");
    if(elfData==ELFDATA2LSB) printf("\t 2's complement, little endian\n");
    if(elfData==ELFDATA2MSB) printf("\t 2's complement, big endian\n");
}

/*Task0*/
void ExamineELFFile(){
    char buf[1024];

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
        mapStart = mmap(NULL, length, PROT_READ ,MAP_SHARED, fd, 0);
        elf=(Elf32_Ehdr*)mapStart;
        if (elf == MAP_FAILED)
            perror("Error at mmap");
        
        printf("Magic numbers :\t %X %C %X\n",elf->e_ident[EI_MAG1],elf->e_ident[EI_MAG2],elf->e_ident[EI_MAG3]);
        printf("Data encoding scheme: ");
        printData(elf->e_ident[EI_DATA]);
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
    if(debug_mode) printf("Current name index : %d\n", index);
    if(debug_mode) printf("Str table offset: %d\n", elf->e_shstrndx);
    return name;
}

char* findTypeName(int type){
    /* Legal values for sh_type (section type).  - from header = elf.h*/
    if(type==SHT_NULL) return "NULL"; /* Section header table entry unused */
    if(type==SHT_PROGBITS) return "PROGBITS"; /* Program data */
    if(type==SHT_SYMTAB) return "SYMTAB"; /* Symbol table */
    if(type==SHT_STRTAB) return "STRTAB"; /* String table */
    if(type==SHT_RELA) return "RELA"; /* Relocation entries with addends */
    if(type==SHT_HASH) return "HASH";	/* Symbol hash table */
    if(type==SHT_DYNAMIC) return "DYNAMIC";	/* Dynamic linking information */
    if(type==SHT_NOTE) return "NOTE";
    if(type==SHT_NOBITS) return "NOBITS";
    if(type==SHT_REL) return "REL";
    if(type==SHT_SHLIB) return "SHLIB";
    if(type==SHT_DYNSYM) return "DYNSYM";   /* Dynamic linker symbol table */
    if(type==SHT_INIT_ARRAY) return "INIT_ARRAY";
    if(type==SHT_FINI_ARRAY) return "FINI_ARRAY";
    if(type==SHT_PREINIT_ARRAY) return "PREINIT_ARRAY";
    if(type==SHT_GROUP) return "GROUP";
    if(type==SHT_SYMTAB_SHNDX) return "SYMTAB_SHNDX";
    if(type==SHT_NUM) return "NUM";
    if(type==SHT_LOOS) return "LOOS";
    if(type==SHT_GNU_LIBLIST) return "GNU_LIBLIST";
    if(type==SHT_CHECKSUM) return "CHECKSUM";
    if(type==SHT_LOSUNW) return "LOSUNW";
    if(type==SHT_SUNW_move) return "SUNW_move";
    if(type==SHT_SUNW_COMDAT) return "SUNW_COMDAT";
    if(type==SHT_SUNW_syminfo) return "SUNW_syminfo";
    if(type==SHT_GNU_verneed) return "GNU_verneed";
    if(type==SHT_GNU_verdef) return "GNU_verdef";
    if(type==SHT_GNU_versym) return "GNU_versym";
    if(type==SHT_HISUNW) return "HISUNW";
    if(type==SHT_HIOS) return "HIOS";
    if(type==SHT_LOPROC) return "LOPROC";
    if(type==SHT_HIPROC) return "HIPROC";
    if(type==SHT_LOUSER) return "LOUSER";
    if(type==SHT_HIUSER) return "HIUSER";
    else return "";
}

/*Task1*/
void PrintSectionNames(){
    int sectionsNum;
    Elf32_Shdr *header;
    fd = open(filename,O_RDONLY);
    if(fd==-1) perror("Error at open file");
    else{
        sectionsNum= elf->e_shnum;
        if(debug_mode) printf("Sections table- size: : %d\n", sectionsNum);
        printf("[Nr]\t Name \t Adress\t\t Offset\t size\t type\t\n");
        for(int i=0; i<sectionsNum; i++){
            header = (Elf32_Shdr*)(mapStart+elf->e_shoff+(i*elf->e_shentsize));
            if(debug_mode) printf("Current header pointer : %p\n", header);
            printf("[%d] \t%s \t%08X \t%X \t%X \t%d \t%s\n", i,findName(header->sh_name),
            header->sh_addr, header->sh_offset , header->sh_size, header->sh_type , findTypeName(header->sh_type));
        }
        close(fd);
    }

}

Elf32_Shdr* findTable(int type){
    int sectionsNum= elf->e_shnum;
    Elf32_Shdr *header;
    for(int i=0; i<sectionsNum; i++){
            header = (Elf32_Shdr*)(mapStart+elf->e_shoff+(i*elf->e_shentsize));
            if(header->sh_type==type) return header; 
    }
    return NULL;
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
    if(debug_mode) printf("Current name index : %d\n", index);
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
        SymHeader=findTable(SHT_DYNSYM);
        size=(SymHeader->sh_size)/(SymHeader->sh_entsize);

        if(debug_mode) printf("Symbol Table .symtab, size: %d\n", size);
        printf("Index:\t Value \t Section Index\t Section Name\t\t Symbol Name:\n");

        for(int i=0; i<size; i++){
            symTable = (Elf32_Sym*)(mapStart+SymHeader->sh_offset+i*SymHeader->sh_entsize);
            if(debug_mode) printf("Current symbol table pointer : %p\n", symTable);
            printf("%d: \t%08X  \t%s \t%s \t\t\t%s\n", i,symTable->st_value,
            sectionIndicate(symTable->st_shndx),findSectionName(symTable->st_shndx),
            findSymbolName(symTable->st_name,SymHeader));
        }
        

        SymHeader=findTable(SHT_SYMTAB);
        size=(SymHeader->sh_size)/(SymHeader->sh_entsize);

        if(debug_mode) printf("Symbol Table .symtab, size: %d\n", size);
        printf("Index:\t Value \t Section Index\t Section Name\t\t Symbol Name:\n");

        for(int i=0; i<size; i++){
            symTable = (Elf32_Sym*)(mapStart+SymHeader->sh_offset+i*SymHeader->sh_entsize);
            if(debug_mode) printf("Current symbol table pointer : %p\n", symTable);
            printf("%d: \t%08X  \t%s \t%s \t\t\t%s\n", i,symTable->st_value,
            sectionIndicate(symTable->st_shndx),findSectionName(symTable->st_shndx),
            findSymbolName(symTable->st_name,SymHeader));
        }
        close(fd);
    }
}

char* getSymName(int index){
    if(index==0) return "";
    Elf32_Sym *sym;
    Elf32_Shdr *dynSymHeader = findTable(SHT_DYNSYM);
    int size = (dynSymHeader->sh_size)/(dynSymHeader->sh_entsize);
    if(debug_mode) printf("Sym table size: %d\n",size);
    sym = (Elf32_Sym*)(mapStart+dynSymHeader->sh_offset);
    char *name=findSymbolName(sym[index].st_name,dynSymHeader);
    return name;
}

int getSymValue(int index){
    Elf32_Sym *sym;
    Elf32_Shdr *dynSymHeader = findTable(SHT_DYNSYM);
    int size = (dynSymHeader->sh_size)/(dynSymHeader->sh_entsize);
    if(debug_mode) printf("Sym table size: %d\n",size);
    sym = (Elf32_Sym*)(mapStart+dynSymHeader->sh_offset);
    int value= sym[index].st_value;
    return value;
}

/*Task3*/
void RelocationTables(){
    Elf32_Shdr *RelHeader;
    Elf32_Rel *RelTable;
    Elf32_Rel rel;
    int type;
    int size; int symbol_index; 
    fd = open(filename,O_RDONLY);
    if(fd==-1) perror("Error at open file");
    else{
        int sectionsNum= elf->e_shnum;
        Elf32_Shdr *header;
        for(int index=0; index<sectionsNum; index++){
            header = (Elf32_Shdr*)(mapStart+elf->e_shoff+(index*elf->e_shentsize));
            if(header->sh_type==SHT_REL){
                RelHeader=header;
                size=(RelHeader->sh_size)/(RelHeader->sh_entsize);

                if(debug_mode) printf("Relocation header pointer : %p, relocation table size : %d\n", RelHeader,size);

                RelTable = (Elf32_Rel*)(mapStart+RelHeader->sh_offset);
                printf("Relocation section '.rel.dyn' at offset %p contains %d entries:\n",RelHeader->sh_offset,size);
                printf("Offset\t\t Info\t\tType\t Sym.Value\t SymName\n");

                for(int i=0; i<size; i++){
                    rel = RelTable[i];
                    type=ELF32_R_TYPE(rel.r_info);
                    symbol_index=ELF32_R_SYM(rel.r_info);
                    if(debug_mode) printf("Current symbol table pointer : %p\n", &rel);
                    printf("%08X \t%08X \t%d \t%08X \t%s\n",rel.r_offset,rel.r_info,type,
                    getSymValue(i),getSymName(symbol_index));
                }
            }
        }
        close(fd);
    }



}

void quit(){
    if(debug_mode==1)
    printf ("quitting..\n");
    munmap(mapStart, length);
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
    {"Print Symbols", PrintSymbols } , {"RelocationTables", RelocationTables} ,{"Quit", quit} , {NULL,NULL}};

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
