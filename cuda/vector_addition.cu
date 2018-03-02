//LOOK AT ONE OF THE INCLUDE FILES. DOES NOT SEEM RIGHT
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <math.h>
#include <float.h>
#include <string,h>

#include "vector_addition_kernel.cu"

#define THREAD_BLOCK_SIZE 128
#define NUM_THREAD_BLOCKS 240



void compute_on_device(float *A_on_host,float *B_on_host, float *gpu_result,int num_elements)
{

float *A_on_device = NULL;
float *B_on_device = NULL;
float *C_on_device = NULL;




//create  a space in GPU for A
cudaMalloc((void **) &A_on_device, num_elements*sizeof(float));

//copy elements from CPU to GPU
cudaMemcpy(A_on_device,A_on_host, num_elements*sizeof(float), cudaMemcpyHostToDevice); //copy from host to device a set number of elements




//create  a space in GPU for A
cudaMalloc((void **) &B_on_device, num_elements*sizeof(float));I
cudaMemcpy(B_on_device,B_on_host, num_elements*sizeof(float), cudaMemcpyHostToDevice); //copy from host to device a set number of elements

//llocate space in memory on GPU for the output
cudaMalloc((void **) &C_on_device, num_elements*sizeof(float));

//setup execution grid on GPU
dim3 thread_block(THREAD_BLOCK_SIZE,1,1); //set number of threads in a thread block
printf("Setting a (%d x 1) execution grid .\n",NUM_THREAD_BLOCKS);
dim3 grid(NUM_THREAD_BLOCKS, 1);

printf("Adding vectors on the GPU. \n");





