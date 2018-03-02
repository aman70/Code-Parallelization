/* Matrix multiplication: P = M * N.
 * Device code.

    Author: Naga Kandasamy
    Date: 2/16/2017
 */

#ifndef _MATRIXMUL_KERNEL_H_
#define _MATRIXMUL_KERNEL_H_
#define TILE_SIZE 32
#include <stdio.h>
#include "matrixmul.h"

__global__ void 
MatrixMulKernel(Matrix M, Matrix N, Matrix P)
{

	__shared__ float Msub[TILE_SIZE][TILE_SIZE];
	__shared__ float Nsub[TILE_SIZE];
	// Thread index
	int threadX = threadIdx.x;
	int threadY = threadIdx.y;

	// Block index
	int blockX = blockIdx.y;
	//int blockY = blockIdx.y;

	// Find position in Matrix
	//int column_number = blockDim.x * blockX + threadX;
	int row_number = ((TILE_SIZE)* blockX) + threadY;
	

	double P_temp = 0.0f;

	//this is where things get funky

	int k = 0;
	int temp;
	while(k < M.width){

        	if(k + threadX  < M.width && row_number < M.height)
			Msub[threadY][threadX] = M.elements[row_number*M.width + k + threadX];
		else
			Msub[threadY][threadX] = 0.0f;
		
		if(k + threadY < N.height)
			Nsub[threadX] = N.elements[threadX + k];

		else
			Nsub[threadY] = 0.0f;
		for(temp = 0;temp <TILE_SIZE; temp++)
			P_temp += Msub[threadY][temp]*Nsub[temp];
		__syncthreads();
		k += TILE_SIZE;
	}		
	
		
	// Write result to P
	//P[row_number * matrix_size + column_number] = (float)P_temp;
	if(row_number < P.height)
		P.elements[row_number] = (float)P_temp;
	return;
}

#endif
