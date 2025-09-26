#include <stdio.h>
#include <cuda_runtime.h>
#include <sys/time.h>
#include <iostream>

#include "kernel1.cu"

#include "TimingCPU.h"
#include "TimingGPU.cuh"

#define MIN(a, b) \
    ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _b : _a; })

#define CHECK_CUDA_ERROR(val) check((val), #val, __FILE__, __LINE__)
template <typename T>
void check(T err, const char *const func, const char *const file,
           const int line)
{
    if (err != cudaSuccess)
    {
        std::cerr << "CUDA Runtime Error at: " << file << ":" << line
                  << std::endl;
        std::cerr << cudaGetErrorString(err) << " " << func << std::endl;
        // We don't exit when we encounter CUDA errors in this example.
        // std::exit(EXIT_FAILURE);
    }
}

// Array with matrix power
short **h_C;

// Vector with min of main diagonal
short *min_Diagonal;

short bm;
int am;
short bm2;
int n0m;

short calculo_min_diagonales_2(long matCrow, long matCcol, int indice_matriz);
int matrixMultiply(int block_size, unsigned long matArow, unsigned long matAcol, unsigned long matBrow, unsigned long matBcol, int iteraciones);
int loadfile(dim3 &dimsA, dim3 &dimsB, char *filename1, int iteraciones);
int print_min_diagonales(unsigned long matArow, unsigned long matAcol, unsigned long matBrow, unsigned long matBcol);
int busqueda_recurrencia_CPU(unsigned long matCrow, unsigned long matCcol, int iteraciones);


int loadfile(dim3 &dimsA, dim3 &dimsB, char *filename1, int iteraciones)
{

    FILE *f1;

    //f1 = fopen(filename1, "r");
  
    if ( (f1 = fopen(filename1, "rb")) == NULL)
     {
         fprintf(stderr, "Error opening file.");
         exit(1);
     }

    // Allocate host matrix C

    dim3 dimsC(dimsB.x, dimsA.y, 1);

    //Array de matrices
    //Solo asignamos memoria para la primera entrada
    size_t size_C = (unsigned long)(dimsC.x) * (unsigned long)(dimsC.y);
    h_C = (short **)malloc(sizeof(short *) * (iteraciones + 1));
    
    h_C[0] = (short *)malloc(size_C * sizeof(short));

    if (fread(h_C[0],sizeof(short),size_C, f1) != size_C)
     {
         fprintf(stderr, "Error reading file.");
         exit(1);
     }
     
     //printf("Hola ... %d %d %d %d %d %d\n",h_C[50][0],h_C[50][1],h_C[50][2],h_C[50][3],h_C[50][4],h_C[50][5]);

    fclose(f1);


    printf("Archivo cargado en memoria.....\n");

    // Allocate vector for minimal of main diagonal

    min_Diagonal = (short *)malloc(sizeof(short) * (iteraciones + 1));
    min_Diagonal[0] = calculo_min_diagonales_2((long)dimsC.x, (long)dimsC.y, 0);

    return 0;
}

/**
 *  Run matrix_trop and create de array with power
 */
int matrixMultiply(int block_size, unsigned long matArow, unsigned long matAcol, unsigned long matBrow, unsigned long matBcol, int iteraciones)
{


    unsigned long  A_sz, B_sz, C_sz;
    short *A_h, *B_h, *C_h;
    
    A_sz = matArow*matAcol;
    B_sz = matBrow*matBcol;
    C_sz = matArow*matBcol;

    printf("\nMatrix size : %ld\n",A_sz*2); fflush(stdout);
    printf("Numero de submatrices : %d\n",num_submatrix);
    printf("Numero de iteraciones : %d\n",iteraciones);

    A_h = (short*) malloc( sizeof(short)*A_sz );
    B_h = (short*) malloc( sizeof(short)*B_sz );
    C_h = (short*) malloc( sizeof(short)*C_sz );

    //unsigned long jj;

    if (A_h == NULL)
    {
        printf("Memory not allocated.\n");
        exit(0);
    }

    if (B_h == NULL)
    {
        printf("Memory not allocated.\n");
        exit(0);
    }

    if (C_h == NULL)
    {
        printf("Memory not allocated.\n");
        exit(0);
    }


    memcpy(A_h,h_C[0],A_sz*sizeof(short));
    memcpy(B_h,h_C[0],A_sz*sizeof(short));
    
/*
FILE *f2;
if ( (f2 = fopen("13_8_50.bin", "rb")) == NULL)
     {
         fprintf(stderr, "Error opening file.");
         exit(1);
     }
if (fread(B_h,sizeof(short),B_sz, f2) != B_sz)
     {
         fprintf(stderr, "Error reading file.");
         exit(1);
     }
fclose(f2);
memcpy(h_C[50],B_h,C_sz*sizeof(short));


printf("Hola ... %d %d %d %d %d %d\n",h_C[50][0],h_C[50][1],h_C[50][2],h_C[50][3],h_C[50][4],h_C[50][5]);
printf("Hola ... %d %d %d %d %d %d\n",A_h[0],A_h[1],A_h[2],A_h[3],A_h[4],A_h[5]);
printf("Hola ... %d %d %d %d %d %d\n",B_h[0],B_h[1],B_h[2],B_h[3],B_h[4],B_h[5]);
*/

    int devID = 0;
    cudaDeviceProp deviceProp;
    cudaGetDeviceProperties(&deviceProp, devID);
    printf("\nDevice %d: \"%s\"\n\n", devID, deviceProp.name);
    cudaSetDevice(0);
   
    // Execute the kernel

    int recurrencia;


    for (unsigned int it = 1; it < (iteraciones + 1); it++)
    {

        printf("Entrando al msplit %hu..... ",it);fflush(stdout);
        
        msplitm(matArow, matBcol, matBrow, A_h, matArow, B_h, matBrow, C_h, matBrow);

        cudaDeviceSynchronize();

        printf(".. saliendo de msplit\n");

        //Asignamos memoria para la matriz a guardar
        h_C[it] = (short *)malloc(C_sz * sizeof(short));

        memcpy(B_h,C_h,B_sz*sizeof(short));
        memcpy(h_C[it],C_h,B_sz*sizeof(short));

        /*Guardamos una salida cada multiplo de 1a*/
	/*
	if((it%25)==0){
         char filename2[20];
	 FILE *f2;
         sprintf(filename2,"%lu_%d_%ld.txt",13,num_submatrix,it);
         f2=fopen(filename2,"w");

	 if (fwrite(h_C[it],sizeof(short),C_sz, f2) != C_sz)
          {
            fprintf(stderr, "Error reading file.");
            exit(1);
          }
	 fclose(f2);
	}
        */

	printf("Entrada al calculo de las diagonales ....");fflush(stdout);
        min_Diagonal[it] = calculo_min_diagonales_2(matAcol, matArow, it);
	printf(".. saliendo del calculo de las diagonales\n");
	
        recurrencia = 1;
        if (it > 7) //Entro a partir de la potencia 7
        {
	    printf("Entrando al calculo de la recurrencia....");fflush(stdout);
            recurrencia = busqueda_recurrencia_CPU(matAcol, matArow, it);
            if (recurrencia == 1){
	      printf(".. saliendo por continue...no se ha encontrado\n");
	      continue; 
            }else{
	      printf(".. saliendo por break...se ha encontrado!!!\n");
	      break;
            }
	}
        

    }

    // Liberamos la memoria
    // Menos las potencias calculadas que estan en h_C
    free(A_h);
    free(B_h);
    free(C_h);

    return 0;
}

int busqueda_recurrencia_CPU(unsigned long matCrow, unsigned long matCcol, int iteracion)
{

    size_t size_C = (unsigned long)(matCrow) * (unsigned long)(matCcol);
    short *temp = (short *)malloc(size_C * sizeof(short));

    int it2;
    int salida;

    // hago las diferencias
    for (it2 = (iteracion-1); it2 > (iteracion-7); it2--)
    {

        for (unsigned long j = 0; j < size_C; j++)
            if (h_C[it2][j] == 32767) temp[j]= 32767;
	    else temp[j] = h_C[iteracion][j] - h_C[it2][j];

        bm = temp[0];
        salida = 0;
        for (unsigned long i = 1; i < size_C; i++)
        {
            
            if (temp[i] >= 32767)
            {
                salida = 0;
                continue;
            }
            
            if (bm != temp[i])
            {
                salida = 1;
                break;
            }
        }

        if (salida == 0)
        {
            break;
        }

    } // del bucle it2

    am = iteracion - it2;
    n0m = it2 + 1;

    free(temp);
    free(h_C[iteracion-7]);

    return salida;
}

int print_min_diagonales(unsigned long matArow, unsigned long matAcol, unsigned long matBrow, unsigned long matBcol, int hasta)
{

    for (unsigned long i = 0; i < (hasta + 1); i++)
    {
        printf("Potencia %ld | Menor %d \n", i, min_Diagonal[i - 1]);
    }
    return 0;
}

short calculo_min_diagonales_2(long matCrow, long matCcol, int indice_matriz)
{
    short menor;
    size_t size_C = (unsigned long)(matCrow) * (unsigned long)(matCcol);

    // Recorremos la diagonal buscando el minimo
    menor = 32767;
    for (unsigned long j = 0; j < size_C; j = (j + matCrow + 1))
        if (h_C[indice_matriz][j] < menor)
            menor = h_C[indice_matriz][j];

    return menor;
}

int main(int argc, char **argv)
{

    TimingCPU timer_CPU;
    TimingGPU timer_GPU;

    char *filename1 = argv[1];

    unsigned long matArow, matAcol;
    unsigned long matBrow, matBcol;

    matArow = atoi(argv[2]);
    matAcol = atoi(argv[2]);
    matBrow = atoi(argv[2]);
    matBcol = atoi(argv[2]);

    int block_size = 32;

    int iteraciones = atoi(argv[3]);

    num_submatrix = atoi(argv[4]);

    dim3 dimsA(1, 1, 1);
    dim3 dimsB(1, 1, 1);
    dimsA.x = matAcol;
    dimsA.y = matArow;
    dimsB.x = matBcol;
    dimsB.y = matBrow;

    timer_CPU.StartCounter();
    int load_result = loadfile(dimsA, dimsB, filename1, iteraciones);
    float t_upload_file = timer_CPU.GetCounter() / 1000.0;

    timer_GPU.StartCounter();
    int matrix_result = matrixMultiply(block_size, matArow, matAcol, matBrow, matBcol, iteraciones);
    float t_calculate_recurrence = timer_CPU.GetCounter() / 1000.0;

    int diagonales = print_min_diagonales(matArow, matAcol, matBrow, matBcol, (n0m + am - 1));

/*
    for (unsigned int i = 0; i < (iteraciones + 1); i++)
        free(h_C[i]);
*/
    free(h_C);

    printf("====================\n");
    printf("n0m=%d am=%d bm=%d\n", n0m, am, (int)bm);
    printf("====================\n");
    printf("Time :\n");
    printf("Upload file          : %.5f seg\n", t_upload_file);
    printf("Calculate recurrence : %.5f seg\n", t_calculate_recurrence);
    printf("====================\n");

    exit(0);
}
