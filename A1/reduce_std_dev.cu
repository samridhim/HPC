#include<stdio.h>
#include<time.h>
#include "omp.h"


__global__ void square_reduce(float *n){
int myId = threadIdx.x + blockDim.x * blockIdx.x;
int tid = threadIdx.x;
	for(unsigned int s = blockDim.x/2 ; s>0 ; s >>=1){

	if(tid<s){
	n[myId] *= n[myId];
	}
	__syncthreads();	
	}
	if(tid ==0)
	n[blockIdx.x] = n[myId];
}
__global__ void reduce_diff(float *n, float mean){
int myId = threadIdx.x + blockDim.x * blockIdx.x;
  	int tid = threadIdx.x;
	for(unsigned int s = blockDim.x/2 ; s>0 ; s >>=1){

	if(tid<s){
	n[myId] = n[myId] - mean;
	}
	__syncthreads();	
	}
	if(tid ==0)
	n[blockIdx.x] = n[myId];
}
__global__ void reduce_max(float *n){

  int index = blockDim.x * blockIdx.x + threadIdx.x, output_index = blockIdx.x;
  extern __shared__ float temp_arr[];
  if(index<n)
    temp_arr[threadIdx.x] = arr[index];
  else
    temp_arr[threadIdx.x] = 0;
  __syncthreads();

  for(int i=NUM_THREADS_PER_BLOCK/2; i>0; i/=2)
    {
      if(threadIdx.x<i)
	temp_arr[threadIdx.x] += temp_arr[threadIdx.x+i];
      __syncthreads();
    }

  if(threadIdx.x==0)
    b[output_index] = temp_arr[0];
}

int main()
{
float start = omp_get_wtime();
int N = 1024;

srand(time(0));
int actual_n = N;
while((N&(N-1))!=0){
N = N+1;
}
//printf("%d, %d", actual_n, N);
//printf("\n");
float *h_arr, *h_max;
h_arr = (float*)malloc(sizeof(float)*N);
h_max = (float*)malloc(sizeof(float)*N);
for(int i =0;i<N;i++){
if(i<actual_n)
h_arr[i] = 5;
else
h_arr[i] = 0;
}
//for(int i =0;i<actual_n;i++){
//printf("%0.02f ", h_arr[i]);
//}
printf("\n");
float *d_arr,*d_intermediate;
cudaMalloc((void **)&d_arr, sizeof(float)*N);
cudaMalloc((void **)&d_intermediate, sizeof(float)*2);
cudaMemcpy(d_intermediate, h_arr, sizeof(float)*N, cudaMemcpyHostToDevice);
reduce_max<<<dim3(2,1,1), N>>>(d_intermediate);
cudaMemcpy(d_arr, d_intermediate, sizeof(float)*N, cudaMemcpyHostToDevice);
reduce_max<<<dim3(1,1,1), N>>>(d_arr);
cudaDeviceSynchronize();
cudaMemcpy(h_max, d_arr, sizeof(float)*N, cudaMemcpyDeviceToHost);
printf("Sum is %0.02f\n", h_max[0]);
printf("Mean is %f\n", (float)h_max[0]/actual_n);
/*float *h_std_dev_arr;
float *d_std_dev_arr;
h_std_dev_arr = (float *)malloc(sizeof(float)*N);
cudaMalloc((void **)&d_std_dev_arr, sizeof(float)*N);
for(int i =0;i<N;i++){
if(i<actual_n)
h_std_dev_arr[i] =h_arr[i];
else
h_std_dev_arr[i] =(float)h_max[0]/actual_n;
}
//for(int i =0;i<N;i++){
//printf("%0.02f ",h_std_dev_arr[i]);
//}

cudaMemcpy(d_std_dev_arr, h_std_dev_arr, sizeof(float)*N, cudaMemcpyHostToDevice);
float mean = (float)h_max[0]/actual_n;
reduce_diff<<<1, N>>>(d_std_dev_arr,mean);
cudaMemcpy(h_std_dev_arr, d_std_dev_arr, sizeof(float)*N, cudaMemcpyDeviceToHost);

//printf("\n");
//for(int i =0;i<N;i++)
//printf("%0.02f ",h_std_dev_arr[i]);

cudaMemcpy(d_std_dev_arr, h_std_dev_arr, sizeof(float)*N, cudaMemcpyHostToDevice);
square_reduce<<<1,N>>>(d_std_dev_arr);
cudaMemcpy(h_std_dev_arr, d_std_dev_arr, sizeof(float)*N, cudaMemcpyDeviceToHost);

//printf("\n");
//for(int i =0;i<N;i++)
//printf("%0.02f ",h_std_dev_arr[i]);

float *h_sum_std_dev_arr;
h_sum_std_dev_arr = (float*)malloc(sizeof(float)*N);

cudaMemcpy(d_std_dev_arr, h_std_dev_arr, sizeof(float)*N, cudaMemcpyHostToDevice);
reduce_max<<<1, N/2>>>(d_std_dev_arr);
cudaMemcpy(h_sum_std_dev_arr, d_std_dev_arr, sizeof(float)*N, cudaMemcpyDeviceToHost);

//printf("\n");
//printf("%0.02f\n",h_sum_std_dev_arr[0]);

printf("Variance is %0.02f\n",h_sum_std_dev_arr[0]/actual_n);
printf("Std Deviance is %0.02f\n", sqrt(h_sum_std_dev_arr[0]/actual_n));
printf("Time taken %f\n", omp_get_wtime() - start);
*/
return 0;  
}
