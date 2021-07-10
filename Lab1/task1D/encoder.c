#include <stdio.h>
#include <string.h>


int main(int argc, char** argv){

    int i,c,debug,e,enc;
    FILE * output=stdout;
    char *encoder;

    unsigned long enclen=0;
    debug=0;
    e=0;
    enc=0;
    if(argc>1) {

        for (i = 1; i < argc; i++) {
            if (strcmp(argv[i], "-D") == 0) {//debug mode
                debug = 1;
 		printf("-D\n");
            }
            else if (strncmp(argv[i], "+e",2)==0){//+e mode
                e=1;
                enclen= strlen(argv[i]);
                encoder = argv[i]+2;
                enclen=enclen-2;
            }
            else if (strncmp(argv[i], "-e", 2) == 0) {//-e mode
                e=2;
                enclen = strlen(argv[i]);
                encoder = argv[i]+2;
                enclen=enclen-2;
            }
            else if(strncmp(argv[i],"-o",2)==0) {//-o - print to file mode
                char *filename = argv[i]+2;
                output=fopen(filename,"w");
            }
            else {
                printf("invalid parameter - %s\n", argv[i]);
                return 1;

            }
        }

    }
    c= getchar();

    while(c!=-1){
        if(debug && c!=10){
            fprintf(stderr,"%d", c);
            fprintf(stderr,"\t");
        }
        if(e==0 && c>=97 && c<=122){
            c=c-32;
        }
        else if(e==1 && c!=10){//+e
            int a = encoder[enc%enclen]-'0';
            c=c+a;
            enc++;
        }
        else if(e==2 && c!=10){//-e
            int a=encoder[enc%enclen]-'0';
            c=c-a;
            enc++;
        }
        if(debug && c!=10){
            fprintf(stderr,"%d\n", c);
        }
        if(c==10){
            enc=0;
            if(debug){
		fprintf(stderr,"\n");
            }
        }
        fprintf(output,"%c",c);
        c = getchar();
    }

    if(output!=stdout)
        fclose(output);
    return 0;
}


