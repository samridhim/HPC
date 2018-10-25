#include<stdio.h>
#define N 2000000
#define BLOCK_SIZE 1024
//using namespace std;

__global__ void ReduceMin(int n, int *input, int *output){
__shared__ int sh[BLOCK_SIZE];
int tid = threadIdx.x;
int myId = threadIdx.x + blockIdx.x*blockDim.x;
if(tid<BLOCK_SIZE)
sh[tid] = input[myId];
else
sh[tid] = INT_MAX;
__syncthreads();
for(int i = blockDim.x/2; i>0;i>>=1){
if(tid<i)
{
if(sh[tid]>sh[tid+i])   // sh[tid]<sh[tid +i] for max
sh[tid] = atomicMin(&sh[tid+i], sh[tid]);  //atomicMax for max
else
sh[tid] = sh[tid];
}
__syncthreads();
}
if(tid==0)
output[blockIdx.x] = sh[0];
}

int main(){
int num_blocks;
if(N%BLOCK_SIZE!=0)
 num_blocks = N/BLOCK_SIZE+1;
else if(N/BLOCK_SIZE==0)
num_blocks =1;
else
num_blocks= N/BLOCK_SIZE;
int *h = (int*)malloc(sizeof(int)*N);
int *d_h, *d_temp;
int *h_temp = (int *) malloc(sizeof(int)*1);
cudaMalloc((void **)&d_h, sizeof(int)*N);
cudaMalloc((void **)&d_temp, sizeof(int)*num_blocks);
for(int i =0;i<N;i++)
h[i] = i+1;
cudaMemcpy(d_h, h, sizeof(int)*N, cudaMemcpyHostToDevice);
ReduceMin<<<num_blocks,BLOCK_SIZE>>>(BLOCK_SIZE, d_h, d_temp);
cudaMemcpy(h, d_temp, sizeof(int)*num_blocks, cudaMemcpyDeviceToHost);
int maxx = INT_MAX;  //INT_MIN for max
for(int i =0;i<num_blocks;i++){
if(h[i]<maxx &&h[i]!=0)  //h[i]>maxx for max
maxx = h[i];
}
printf("%d", maxx);
cudaFree(d_h);
cudaFree(d_temp);
}
