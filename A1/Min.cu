#include <stdio.h>
#define N 2048

//Note: N should always be in powers of 2 (like 2, 4, 8, 16, 32, ...) -Mohit Agrawal

__global__ void FindMin(int* input)
{
	int tid = threadIdx.x;
	int step_size = 1;
	int number_of_threads = blockDim.x;

	while (number_of_threads > 0)
	{
		if (tid < number_of_threads)
		{
			int fst = tid * step_size * 2;
			int snd = fst + step_size;
			if(input[fst] >= input[snd])
			{
				input[fst] = input[snd];
			}
			else
			{
				input[fst] = input[fst];
			}
		}
		step_size <<= 1; 
		number_of_threads >>= 1;
	}
}
int main()
{
	time_t t;
	srand((unsigned) time(&t));
	
	int *h;
	h = (int*)malloc(N*sizeof(int));
	
	for(int i=0; i<N; i++)
	{
		h[i] = rand()%N;
	}
	for(int i=0; i<N; i++)
	{
		printf("%d ", h[i]);
	}
	printf("\n");

	int* d;
	cudaMalloc(&d, N*sizeof(int));
	
	cudaMemcpy(d, h, N*sizeof(int), cudaMemcpyHostToDevice);

	FindMin <<<1, N/2 >>>(d);
	
	cudaDeviceSynchronize();

	int *result;
	result = (int*)malloc(sizeof(int));
	
	cudaMemcpy(result, d, sizeof(int), cudaMemcpyDeviceToHost);

	printf("Min is: %d \n", result[0]);

	cudaFree(d);
	free(h);

	return 0;
}
