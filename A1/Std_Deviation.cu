#include <stdio.h>
#include <math.h>
#define N 1024

//Note: N should always be in powers of 2 (like 2, 4, 8, 16, 32, ...) -Mohit Agrawal

__global__ void FindSum(float input[])
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
			input[fst] += input[snd];
		}
		step_size <<= 1; 
		number_of_threads >>= 1;
	}
}
__global__ void FindDiff(float input[], float mean)
{
	int tid = threadIdx.x;
	
	if (tid < N)
	{
		input[tid] = input[tid] - mean;
	}
}
int main()
{
	//Initialization
	time_t t;
	srand((unsigned) time(&t));
	
	float *h;
	h = (float*)malloc(N*sizeof(float));
	
	for(int i=0; i<N; i++)
	{
		h[i] = ((float)rand() / (float)RAND_MAX) * N;
	}
	for(int i=0; i<N; i++)
	{
		printf("%f ", h[i]);
	}
	printf("\n");

	//Finding sum
	float* d;
	cudaMalloc(&d, N*sizeof(float));
	cudaMemcpy(d, h, N*sizeof(float), cudaMemcpyHostToDevice);

	FindSum <<<1, N/2 >>>(d);
	cudaDeviceSynchronize();

	float *result;
	result = (float*)malloc(sizeof(float));
	cudaMemcpy(result, d, sizeof(float), cudaMemcpyDeviceToHost);
	printf("Sum is: %f \n", result[0]);
	
	//Mean calculation
	float avg = result[0]/N;
	printf("Avg is: %f \n", avg);

	//Subtracting mean from each element
	float *g;
	cudaMalloc(&g, N*sizeof(float));
	cudaMemcpy(g, h, N*sizeof(float), cudaMemcpyHostToDevice);
	
	FindDiff <<<1, N >>>(g, avg);
	cudaDeviceSynchronize();
	
	float *solution;
	solution = (float*)malloc(N*sizeof(float));
	cudaMemcpy(solution, g, N*sizeof(float), cudaMemcpyDeviceToHost);
	
	printf("Difference: ");
	for(int i=0; i<N; i++)
	{
		printf("%f ", solution[i]);
	}
	printf("\n");
	
	for(int i=0; i<N; i++)
	{
		solution[i] = fabsf(solution[i] * solution[i]);
	}
	
	printf("Squares: ");
	for(int i=0; i<N; i++)
	{
		printf("%f ", solution[i]);
	}
	printf("\n");
	
	float *solute;
	cudaMalloc(&solute, N*sizeof(float));
	cudaMemcpy(solute, solution, N*sizeof(float), cudaMemcpyHostToDevice);
	
	//Adding the squares of differences
	FindSum <<<1, N/2 >>>(solute);
	cudaDeviceSynchronize();

	float *std_dev;
	std_dev = (float*)malloc(sizeof(float));
	cudaMemcpy(std_dev, solute, sizeof(float), cudaMemcpyDeviceToHost);

	printf("Sum of Squares: ");
	printf("%f \n", std_dev[0]);
	
	//Taking arithmetic mean of the sqaures of differences
	float sol = std_dev[0]/N;
	
	float answer = sqrt(sol);
	
	printf("Standard Deviation is: %f \n", answer);
	
	cudaFree(d);
	free(h);

	return 0;
}
