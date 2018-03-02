//kernel fior tiled multiplication


__global__ void
MatrixMulKernel(float* P, const float* M, const float* N, int matrix_size){
	//thread index
//	int threadX = threadIdx.x;
	int threadY = threadIdx.y;


	//block index
//	int blockX = blockIdx.x;
	int blockY = blockIdx.y;


	//FIND position in gloval matrix

	//int column_number = blockDim.x*blockX + threadX;

	int row_number = blockDim.y*blockY + threadY;
	

	double P_temp = 0;

	int k;

	for( k = 0;k< matrix_size; k++){
		double M_element = M[matrix_size*row_number + k];
		double N_element = N[k];
		P_temp += M_element*N_element;

	}	
	P[k] = (float)P_temp;

}
