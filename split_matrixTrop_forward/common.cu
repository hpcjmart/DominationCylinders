#include <stdio.h>
#include <cuda_runtime.h>
#include "common.h"

#define BLOCK_SIZE 32

#define MIN(a,b) \
   ({ __typeof__ (a) _a = (a); \
       __typeof__ (b) _b = (b); \
     _a > _b ? _b : _a; })

__global__ void gpu_matrix_mult(short *a,
		                short *b, 
				short *c, 
				unsigned long m, 
				unsigned long n, 
				unsigned long k)
{ 
    unsigned long row = blockIdx.y * blockDim.y + threadIdx.y; 
    unsigned long col = blockIdx.x * blockDim.x + threadIdx.x;

    if( col < k && row < m) 
    {
        short sum = 32767;
        for(unsigned long i = 0; i < n; i++) 
        {
            sum = MIN( sum, (a[row * n + i] + b[i * k + col]) );
        }
        c[row * k + col] = sum;
    }
} 


void copyElements(short* out, 
                  short* entry, 
                  unsigned long eRows, 
                  unsigned long eCols, 
                  unsigned long oRows, 
                  unsigned long oCols, 
                  unsigned long x, 
                  unsigned long y,
	          unsigned long ofA, 
                  unsigned long ofB){

	unsigned long counterRows = eRows;
	unsigned long counterCols = eCols;
	if(ofA){
		counterRows = ofA;
	}
	if(ofB){
		counterCols = ofB;	
	}
	for(unsigned long i = 0; i < counterRows; ++i){
		for(unsigned long j = 0; j < counterCols; ++j){
			unsigned long index = x*eRows*oCols + (i*oCols) + (y*eCols + j);
                        out[index] = entry[i*eCols + j];
		}

	}
}


void doMultiply2Matrices_jam(
        unsigned long  a1Rows, unsigned long a1Cols,  short* A1,
        unsigned long a2Rows, unsigned long a2Cols,  short* A2,
	short* C)
{

	//int devID = 0;
        cudaDeviceProp deviceProp;
	cudaGetDeviceProperties(&deviceProp,0);
        cudaSetDevice(0);


	unsigned long grid_rows = (a1Rows + BLOCK_SIZE - 1) / BLOCK_SIZE;
        unsigned long grid_cols = (a2Rows + BLOCK_SIZE - 1) / BLOCK_SIZE;
        dim3 dimGrid(grid_cols, grid_rows);
        dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);

        gpu_matrix_mult<<< dimGrid, dimBlock >>>(A1, A2, C, a1Rows, a2Rows, a2Cols);

	cudaDeviceSynchronize();

}

