#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <elf.h>

int fd=-1;
char* filename;
void *mapStart;
struct stat fd_stat;
int length;
Elf32_Ehdr *elf=NULL; 
Elf32_Phdr *progHeader=NULL; 

void ExamineELFFile(){
    int size;
    fd = open(filename,O_RDONLY);
    if(fd==-1) perror("Error at open file");
    else{
        length = lseek(fd,0,SEEK_END);
        mapStart = mmap(NULL, length, PROT_READ ,MAP_SHARED, fd, 0);
        elf=(Elf32_Ehdr*)mapStart;
        if (elf == MAP_FAILED)
            perror("Error at mmap");

        char e = elf->e_ident[EI_MAG1];
        char l = elf->e_ident[EI_MAG2];
        char f = elf->e_ident[EI_MAG3];

        if(e!='E' || l!='L' || f!='F') {
            printf("Magic numbers are :\t %C %C %C\n",elf->e_ident[EI_MAG1],elf->e_ident[EI_MAG2],elf->e_ident[EI_MAG3]);
            exit(1);
        }
        progHeader=(Elf32_Phdr*)(mapStart+elf->e_phoff);
        size=elf->e_phnum;

        printf("Type\tOffset\t\tVirtAddr\t PhysAddr\tFileSiz\tMemSiz\tFlg\tAlign\n");

        for(int i=0; i<size; i++){
                    printf("%d \t %06x \t%08x \t%08x \t%05x \t%05x \t%d \t%x\n",
                    progHeader[i].p_type, progHeader[i].p_offset, progHeader[i].p_vaddr,
                    progHeader[i].p_paddr, progHeader[i].p_filesz, progHeader[i].p_memsz,
                    progHeader[i].p_flags, progHeader[i].p_align);
                }
        close(fd);
    }
}

void checkArguments(int argc, char** argv){
    if(argc>1) {
        filename=argv[1];
    }
    else{
         printf("Please enter args.\n");
         exit(1);
    }
}

int main(int argc, char **argv) {
    checkArguments(argc,argv);
    ExamineELFFile();
    return 0;
}
