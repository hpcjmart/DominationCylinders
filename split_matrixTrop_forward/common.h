#ifndef _COMMON_H_
#define _COMMON_H_

#include <cuda_runtime.h>
#include "cublas_v2.h"

void PrintMatrix(char name[], int rows, int cols, const float* m);
void copyElements(short* out, 
		  short* entry, 
		  unsigned long eRows, 
		  unsigned long eCols, 
		  unsigned long oRows, 
		  unsigned long oCols, 
		  unsigned long x, 
		  unsigned long y,
	          unsigned long ofA, 
		  unsigned long ofB);

void doMultiply2Matrices_jam(
        unsigned long a1Rows, unsigned long a1Cols,  short * A1,
        unsigned long a2Rows, unsigned long a2Cols,  short * A2,
        short* C);


#endif
