#include <stdio.h>
#include<omp.h>
#define BLOCK_SIZE 1024
__global__ void FindSquare(float *input){
int tid = threadIdx.x + blockIdx.x *blockDim.x;
input[tid] *= input[tid]; 
}
__global__ void FindDiff(float *input, float mean, float n){
int tid = threadIdx.x + blockIdx.x *blockDim.x;
if(tid<n)
input[tid] -= mean; 
else
input[tid] =0;
}
__global__ void FindSum(float* input, float *output,int n)
{
	__shared__ int sh[BLOCK_SIZE];		
	int myId = threadIdx.x + blockDim.x * blockIdx.x;
  	int tid = threadIdx.x;
	if(tid<BLOCK_SIZE)
	sh[tid] = input[myId];
	else
	sh[tid] = 0;
	__syncthreads();
	for(unsigned int s = blockDim.x/2 ; s>0 ; s >>=1){

	if(tid<s){
	sh[tid] += sh[tid +s];
	}
	__syncthreads();	
	}
        if(tid==0)
        output[blockIdx.x] = sh[0];
}
int main(int argc, char *argv[])
{
	float start = omp_get_wtime();
	int N = 20000; //2,00,000 elements to be summed
	
 	int num_blocks;
	time_t t;
	srand((unsigned) time(&t));
	int actual_n = N;
	float *h;
	h = (float*)malloc(N*sizeof(float));
	for(int i=0; i<actual_n; i++)
	{
		h[i] = 10;
	}
	printf("\n");
        printf("Elements #: %d\n", actual_n);
	float* d, *d_temp;
        float *d_final;
	cudaMalloc(&d, N*sizeof(float));
        if(N/BLOCK_SIZE ==0) 
	{
	num_blocks = 1;
	}
	else if(N%BLOCK_SIZE!=0)
	num_blocks= N/BLOCK_SIZE +1;	
	else
	num_blocks = N/BLOCK_SIZE;
	cudaMemcpy(d, h, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMalloc(&d_temp, num_blocks*sizeof(float));
        cudaMalloc(&d_final, num_blocks*sizeof(float));
	FindSum<<<num_blocks, BLOCK_SIZE>>>(d, d_temp,num_blocks);
	FindSum <<<num_blocks, BLOCK_SIZE>>>(d_temp,d_final,num_blocks);
	float *result;
	result = (float*)malloc(sizeof(float));
	cudaMemcpy(result, d_final, sizeof(float), cudaMemcpyDeviceToHost);
	printf("Sum is: %0.02f \n", result[0]);
	printf("Mean is %0.02f \n", (double)result[0]/actual_n);	
	cudaMemcpy(d, h, N*sizeof(float), cudaMemcpyHostToDevice);
	FindDiff<<<num_blocks, BLOCK_SIZE>>>(d, result[0]/actual_n,actual_n);
	cudaMemcpy(h, d, N*sizeof(float), cudaMemcpyDeviceToHost);
	cudaMemcpy(d,h, N*sizeof(float), cudaMemcpyHostToDevice);
	FindSquare<<<num_blocks, BLOCK_SIZE>>>(d);
	cudaMemcpy(h,d, N*sizeof(float), cudaMemcpyDeviceToHost);	
	cudaMemcpy(d, h, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMalloc(&d_temp, num_blocks*sizeof(float));
        cudaMalloc(&d_final, num_blocks*sizeof(float));
	FindSum<<<num_blocks, BLOCK_SIZE>>>(d, d_temp,actual_n);
	FindSum <<<num_blocks, BLOCK_SIZE>>>(d_temp,d_final,num_blocks);
	cudaMemcpy(result, d_final, sizeof(float), cudaMemcpyDeviceToHost);
	printf("Variance is: %0.02f \n", (double)result[0]/actual_n);
	printf("Standard Deviation is: %0.02f \n", sqrt((double)result[0]/actual_n));
	printf("Time taken : %f\n", omp_get_wtime()-start);	
	cudaFree(d);
	free(h);
	return 0;
}
