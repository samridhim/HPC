#include<iostream>
#define N 20000
#define BLOCK_SIZE 1024
using namespace std;

__global__ void ReduceMax(int n, int *input, int *d_max){
__shared__ int sh[BLOCK_SIZE];
int tid = threadIdx.x;
int myid = threadIdx.x + blockDim.x * blockIdx.x;
if(tid<n)
sh[tid] = input[myid];
else
sh[tid] = 0;
__syncthreads();
for(int i = blockDim.x/2 ; i>0;i>>=1){
if(tid<i)
sh[tid] = max(sh[tid], sh[tid +i]);  //replace by min for minimum and set sh[tid] = N+1
__syncthreads();
}
if(tid==0)
atomicMax(d_max, sh[0]);
}


int main(){
int num_blocks;
int *h, *h_max;
h=(int *)malloc(sizeof(int)*N);
h_max=(int *)malloc(sizeof(int));
for(int i =0;i<N;i++){
h[i] = i+1;
}
int *d_h, *d_max;
if(N/BLOCK_SIZE ==0) num_blocks = 1;
else if(sqrt(N) !=0)
num_blocks = N/BLOCK_SIZE + 1;
else
num_blocks = N/BLOCK_SIZE;
cudaMalloc((void **)&d_h, sizeof(int)*N);
cudaMalloc((void **)&d_max, sizeof(int));
cudaMemcpy(d_h, h, sizeof(int)*N, cudaMemcpyHostToDevice);
ReduceMax<<<num_blocks, BLOCK_SIZE>>>(N, d_h, d_max);
cudaMemcpy(h_max, d_max, sizeof(int), cudaMemcpyDeviceToHost);
cout<<h_max[0]<<endl;
}
