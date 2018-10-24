#include<stdio.h>
#include<time.h>
#include "omp.h"


__global__ void square_reduce(float *n){
n[threadIdx.x] = n[threadIdx.x] * n[threadIdx.x];
}
__global__ void reduce_diff(float *n, float mean){
n[threadIdx.x] = n[threadIdx.x] - mean;
}
__global__ void reduce_max(float *n){
int tid = threadIdx.x;

int stepsize = 1;
int num_threads = gridDim.x;

while(num_threads>0){
	if(tid<num_threads){
		int fst = tid*stepsize*2;
		int snd = fst + stepsize;
		n[fst] += n[snd];
	}
	stepsize<<=1;
	num_threads>>=1;
}
}

int main()
{
float start = omp_get_wtime();
int N = 10;
srand(time(0));
int actual_n = N;
while((N&(N-1))!=0){
N = N+1;
}
printf("%d, %d", actual_n, N);
printf("\n");
float *h_arr, *h_max;
h_arr = (float*)malloc(sizeof(float)*N);
h_max = (float*)malloc(sizeof(float)*N);
for(int i =0;i<N;i++){
if(i<actual_n)
h_arr[i] = 5;
else
h_arr[i] = 0;
}
for(int i =0;i<actual_n;i++){
printf("%0.02f ", h_arr[i]);
}
printf("\n");
float *d_arr;
cudaMalloc((void **)&d_arr, sizeof(float)*N);

cudaMemcpy(d_arr, h_arr, sizeof(float)*N, cudaMemcpyHostToDevice);

reduce_max<<<2, N/2>>>(d_arr);

cudaDeviceSynchronize();
cudaMemcpy(h_max, d_arr, sizeof(float)*N, cudaMemcpyDeviceToHost);
printf("Sum is %0.02f\n", h_max[0]);
printf("Mean is %f\n", (float)h_max[0]/actual_n);
float *h_std_dev_arr;
float *d_std_dev_arr;
h_std_dev_arr = (float *)malloc(sizeof(float)*N);
cudaMalloc((void **)&d_std_dev_arr, sizeof(float)*N);
for(int i =0;i<N;i++){
if(i<actual_n)
h_std_dev_arr[i] =h_arr[i];
else
h_std_dev_arr[i] =(float)h_max[0]/actual_n;
}
for(int i =0;i<N;i++){
printf("%0.02f ",h_std_dev_arr[i]);
}

cudaMemcpy(d_std_dev_arr, h_std_dev_arr, sizeof(float)*N, cudaMemcpyHostToDevice);
float mean = (float)h_max[0]/actual_n;
reduce_diff<<<1, N>>>(d_std_dev_arr,mean);
cudaMemcpy(h_std_dev_arr, d_std_dev_arr, sizeof(float)*N, cudaMemcpyDeviceToHost);

printf("\n");
for(int i =0;i<N;i++)
printf("%0.02f ",h_std_dev_arr[i]);

cudaMemcpy(d_std_dev_arr, h_std_dev_arr, sizeof(float)*N, cudaMemcpyHostToDevice);
square_reduce<<<1,N>>>(d_std_dev_arr);
cudaMemcpy(h_std_dev_arr, d_std_dev_arr, sizeof(float)*N, cudaMemcpyDeviceToHost);

printf("\n");
for(int i =0;i<N;i++)
printf("%0.02f ",h_std_dev_arr[i]);

float *h_sum_std_dev_arr;
h_sum_std_dev_arr = (float*)malloc(sizeof(float)*N);

cudaMemcpy(d_std_dev_arr, h_std_dev_arr, sizeof(float)*N, cudaMemcpyHostToDevice);
reduce_max<<<1, N/2>>>(d_std_dev_arr);
cudaMemcpy(h_sum_std_dev_arr, d_std_dev_arr, sizeof(float)*N, cudaMemcpyDeviceToHost);

printf("\n");
printf("%0.02f\n",h_sum_std_dev_arr[0]);

printf("Variance is %0.02f\n",h_sum_std_dev_arr[0]/actual_n);
printf("Std Deviance is %0.02f\n", sqrt(h_sum_std_dev_arr[0]/actual_n));
printf("Time taken %f\n", omp_get_wtime() - start);
return 0;  
}


