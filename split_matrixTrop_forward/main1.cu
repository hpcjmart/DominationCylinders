#include <stdio.h>
#include <stdlib.h>
#include "kernel1.cu"

// --- Timing includes
#include "TimingCPU.h"
#include "TimingGPU.cuh"

int main (int argc, char *argv[])
{

    TimingCPU timer_CPU,timer1_CPU;
    TimingGPU timer_GPU;

    // Initialize host variables ----------------------------------------------

    printf("\nSetting up the problem..."); fflush(stdout);

    short *A_h, *B_h, *C_h;
    unsigned long  A_sz, B_sz, C_sz;
    unsigned long matArow, matAcol;
    unsigned long matBrow, matBcol;
    char *filename1;
    char filename2[20];
    FILE *f1;
    FILE *f2;


    unsigned long iteraciones = atoi(argv[4]);
    unsigned long tamano = atoi(argv[5]);
    num_submatrix = atoi(argv[2]);
    matArow = atoi(argv[3]);
    matAcol = matBrow = atoi(argv[3]);
    matBcol = atoi(argv[3]);
    filename1=argv[1];

    timer_CPU.StartCounter();

    A_sz = matArow*matAcol;
    B_sz = matBrow*matBcol;
    C_sz = matArow*matBcol;

    printf("\nMatrix size : %ld\n",A_sz); fflush(stdout);

    A_h = (short*) malloc( sizeof(short)*A_sz );
    B_h = (short*) malloc( sizeof(short)*B_sz );
    C_h = (short*) malloc( sizeof(short)*C_sz );

    printf("Opening file : %s\n",filename1);
    f1=fopen(filename1,"r");
    if (f1==NULL) {printf("File error..\n"); fflush(stdout); exit (1);}

    short a;
    unsigned long ii;
    unsigned long jj;
    int count;

    for (ii = 0; ii < A_sz; ii++){
        count=fscanf(f1,"%hu",&a);
        if (count == 0)
        {
            printf("Error loading file..\n");
            exit(0);
        }
        A_h[ii] = a;
        B_h[ii] = a;
        //C_h[ii] = 9999;
    }

    fclose(f1);

    float t_upload_file=timer_CPU.GetCounter()/1000.0;

    printf("A: %lu x %lu \tB: %lu x %lu\tC: %lu x %lu\n", 
        matArow, 
	matAcol, 
	matBrow, 
	matBcol, 
	matArow, 
	matBcol);


    // Launch kernel using msplitm ---------------------------

    printf("Launching kernel...\n"); fflush(stdout);

    timer_GPU.StartCounter();

    for(unsigned long i = 0; i < iteraciones; i++){

     msplitm(matArow, matBcol, matBrow, A_h, matArow, B_h, matBrow, C_h, matBrow);
     cudaDeviceSynchronize();

     //OJO Quitado solo es la medida pura del producto de matrices
     //Tenemos que copiar la matriz C en B y volver a iterar
     
     printf("Hemos salido de msplitm\n");

     for (jj=0; jj < B_sz; jj++) { B_h[jj] = C_h[jj]; }

    //}

    float t_iteration=timer_GPU.GetCounter()/1000.0;

    timer1_CPU.StartCounter();

    // Save matrix C in file
    sprintf(filename2,"%lu_%d_%ld.txt",tamano,num_submatrix,i);
    f2=fopen(filename2,"w");
    for (jj = 0; jj < C_sz; jj++){
                    fprintf(f2,"%d\n",C_h[jj]);
    }

    float t_download_file=timer1_CPU.GetCounter()/1000.0;


    }

    // Free memory ------------------------------------------------------------

    free(A_h);
    free(B_h);
    free(C_h);

    //printf("Upload data    : %.6f seg.\n", t_upload_file);
    //printf("Iteration time : %.6f seg.\n", t_iteration);
    //printf("Download file  : %.6f seg.\n", t_download_file);
    //printf("==========================\n");
    //printf("Total          : %.6f seg.\n", t_upload_file+t_iteration+t_download_file);

    return 0;

}

