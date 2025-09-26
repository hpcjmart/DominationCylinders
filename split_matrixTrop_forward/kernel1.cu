#include <stdio.h>
#include <cuda_runtime.h>
#include "cublas_v2.h"
#include "common.h"

int num_submatrix = 1;


void msplitm(unsigned long m, 
	     unsigned long n, 
	     unsigned long k, 
	     const short *A, 
	     unsigned long lda, 
	     const short *B, 
	     unsigned long ldb, 
	     short *C, 
	     unsigned long ldc)
{

	//float alfa=1.0;
	//float beta=0.0;

    unsigned long  A_sz = m * k;
    unsigned long  B_sz = n * k;
    unsigned long  MAX =  (unsigned long long )m* (unsigned long long) n / num_submatrix;

	MAX -= MAX % k;
	unsigned long numSubMatrixB;
	if (MAX==0) numSubMatrixB = 1;
        else numSubMatrixB = B_sz / MAX;
	unsigned long subCols = B_sz / (numSubMatrixB * k);


	unsigned long numSubMatrixA;
	if (MAX==0) numSubMatrixA = 1;
        else numSubMatrixA = A_sz / MAX;
	unsigned long subRows = A_sz / (numSubMatrixA * k);
	
	unsigned long overflowA = m % subRows;
	unsigned long overflowB = n % subCols;


	for(unsigned long i = 0; i < numSubMatrixB + 1; ++i){
		if(overflowB == 0 && i == numSubMatrixB){
			break;
		}

		short *b;
		short *temp3 = (short*) malloc( sizeof(short)*subCols * k );
		for(unsigned long j = 0; j < k; ++j){
			for(unsigned long x = 0; x < subCols; ++x){
				if(i * subCols + x < n){
					temp3[j * subCols + x] = B[j * n + (i*subCols + x)];
				}else{
					temp3[j *subCols + x] = 32767;
				}
			}
		}
		cudaMalloc((void**) &b, sizeof(short) * subCols * k);
		cudaMemcpy(b, temp3, sizeof(short)*subCols*k, cudaMemcpyHostToDevice);

		free(temp3);

		for(unsigned long y = 0; y < numSubMatrixA + 1; ++y){
			if(overflowA == 0 && y == numSubMatrixA){
				break;
			}

            short *a;
			short *temp = (short*) malloc( sizeof(short)*subRows * k );
			for(unsigned long j = 0; j < subRows; ++j){
				for(unsigned long x = 0; x < k; ++x){
					if(y * subRows + j < m){
						temp[j * k + x] = A[y*subRows*k + j*k + x];
					}else{
						temp[j * k + x] = 32767;
					}
				}			
			}
			cudaMalloc((void**) &a, sizeof(short) * subRows * k);
                        cudaMemcpy(a, temp, sizeof(short)*subRows*k, cudaMemcpyHostToDevice);

                        short* c;
			cudaMalloc((void**) &c, sizeof(short) * subCols * subRows);
			doMultiply2Matrices_jam(subRows, k, a, k, subCols, b, c); 			
			cudaMemcpy(temp, c, sizeof(short)*subRows*subCols, cudaMemcpyDeviceToHost);

			if(i == numSubMatrixB && y == numSubMatrixA){
				copyElements(C, temp, subRows, subCols, m, n, y, i, overflowA, overflowB);
			}else if(i == numSubMatrixB){
				copyElements(C, temp, subRows, subCols, m, n, y, i, 0, overflowB);
			}else if(y == numSubMatrixA){
				copyElements(C, temp, subRows, subCols, m, n, y, i, overflowA, 0);
			}else{
				copyElements(C, temp, subRows, subCols, m, n, y, i, 0, 0);
			}
			free(temp);
			cudaFree(a);
			cudaFree(c);
		
		}
		
		cudaFree(b);
	}
}





