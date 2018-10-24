#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include"omp.h"
#define N 1024
#define threads_per_block 1024
__global__ void add(float*a,float*b,float*c)
{
 int tid = threadIdx.x + blockIdx.x*blockDim.x;
 c[tid] = a[tid] + b[tid];
}
int main()
{
	int num_blocks;
	float start = clock();
	float *a, *b, *c;
	float *d_a, *d_b, *d_c;
	int n = sizeof(float)*N;
	cudaMalloc((void **)&d_a, n);
	cudaMalloc((void **)&d_b, n);
	cudaMalloc((void **)&d_c, n);
	a = (float *)malloc(n);
	b = (float *)malloc(n);
	c = (float *)malloc(n);
	
	printf("A and B are \n");
	srand(time(NULL));	
	for(int i =0;i<N;i++)
	{
	a[i] = 1;
	printf("%0.03f ", a[i]);	
	}	
	printf("\n\n");
	srand(time(NULL));	
	for(int i =0;i<N;i++)
	{
	b[i] = 1;
	printf("%0.03f ", b[i]);
	}	
	printf("\n\n");
	cudaMemcpy(d_a, a,n, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b,n, cudaMemcpyHostToDevice);
	if(N/threads_per_block ==0)
	num_blocks = 1;
	else
	num_blocks = N/threads_per_block;
	add<<<num_blocks,threads_per_block>>>(d_a, d_b, d_c);
	cudaMemcpy(c, d_c,n, cudaMemcpyDeviceToHost);
	for(int i =0;i<N;i++)
	printf("%0.02f ", c[i]);	
	cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
	printf("\n\n Time taken %f\n", (double)(clock()-start)/CLOCKS_PER_SEC);	

 	 return 0;
}
