/* Vector matrix multiplication
* Host Code
* Date: 02/26/2018
*/

//include all required packages
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h>
#include <math.h>
#include "vec_mat_mult.h" //this contains the structure
#include "matrixmul_kernel.cu"
//will need to input kernel into this

#define MATRIX_SIZE 512 //would like this to be a user input eventually
#define TILE_SIZE 32

extern "C" void compute_gold(float *,const float*,const float*, unsigned int, unsigned int); //this is an extern function that I am importing
Matrix AllocateMatrix(int height, int width, int init);
void fdm(Matrix* M);

void MatrixMulOnDevice(const Matrix M, const Matrix N, Matrix P);


int main(int argc, char **argv){

	Matrix M,N,P;


	srand(52);
	M = AllocateMatrix(MATRIX_SIZE,MATRIX_SIZE,1);
	N = AllocateMatrix(MATRIX_SIZE,1,1);
	P = AllocateMatrix(MATRIX_SIZE,1,0);

	printf(" multiplying matrices on a GPU \n");

	MatrixMulOnDevice(M,N,P);
	

	printf("Multiplying serially on CPU \n");
//this is to cmom[pute in sequential
	struct timeval start, stop;
	gettimeofday(&start, NULL);
	Matrix reference = AllocateMatrix(P.num_rows,P.num_columns,0);
	compute_gold(reference.elements,M.elements,N.elements,M.num_rows,N.num_columns);
	

	gettimeofday(&stop, NULL);
	printf("Execution time = %fs. \n", (float)(stop.tv_sec - start.tv_sec+ (stop.tv_usec - start.tv_usec)/(float)100000));

}

void fdm(Matrix* M){
	cudaFree(M->elements);
	M->elements = NULL;

}

//FUNCTION CALLED ALLOCATE MATRIX
Matrix
AllocateMatrix(int height, int width, int init)
{
	Matrix M;
	M.num_columns = width;
	M.num_rows  = height;
	int size = M.num_columns*M.num_rows;
	M.elements = (float*) malloc(size*sizeof(float));



	for(unsigned int i = 0; i < M.num_rows * M.num_columns ;i++){

		M.elements[i] = (init == 0) ? (0.0f) : floor((rand()*3 / (float)RAND_MAX));
	}



	return M;

}

void
MatrixMulOnDevice(const Matrix M, const Matrix N, Matrix P){
	Matrix M_on_device;
	Matrix N_on_device;
	Matrix P_on_device;


//this line is used to allocate memory
	cudaMalloc((void **) &M_on_device.elements, M.num_columns*M.num_rows*sizeof(float));
	cudaMemcpy(M_on_device.elements,M.elements,M.num_columns*M.num_rows*sizeof(float),cudaMemcpyHostToDevice);

	cudaMalloc((void **) &N_on_device.elements, N.num_columns*N.num_rows*sizeof(float));
	cudaMemcpy(N_on_device.elements,N.elements,N.num_columns*N.num_rows*sizeof(float),cudaMemcpyHostToDevice);


	cudaMalloc((void **) &P_on_device.elements, M.num_rows*N.num_columns*sizeof(float));

	dim3 threads(TILE_SIZE,TILE_SIZE); //intitalize a  thread warp


//determine the size of the execution gtid
	dim3 grid((P_on_device.num_columns + TILE_SIZE - 1)/TILE_SIZE, (P_on_device.num_rows + TILE_SIZE - 1)/TILE_SIZE);


	struct timeval start, stop;
	gettimeofday(&start, NULL);

	MatrixMulKernel<<< grid, threads >>> (P_on_device.elements, M_on_device.elements, N_on_device.elements, MATRIX_SIZE);
	
	cudaThreadSynchronize();




	gettimeofday(&stop, NULL);
	//printf("Execution time = %fs. \n" (float) (stop.tv_sec - start.tv_sec + (stop.tv_usec - start.tv_usec)/(float)1000000));


//print to host
	int size = P.num_columns*P.num_rows*sizeof(float);
	cudaMemcpy(P.elements,P_on_device.elements,size,cudaMemcpyDeviceToHost);

//free the matrix
	fdm(&M_on_device);
	fdm(&N_on_device);
	fdm(&P_on_device);




}

















	


