#include<stdio.h>
#include<time.h>
#define N 3
#define NUM_THREADS_PER_BLOCK 256
__global__ void mm_kernel(float *d_a, float *d_b, float *d_c, int n){

int op_index = blockDim.x * blockIdx.x + threadIdx.x;
  int row = op_index / n, col = op_index % n;
  if(op_index<n*n)
    {
      float temp=0;
      for(int i=0; i<n; i++)
	temp += d_a[row*n+i] * d_b[col + i*n];
      d_c[op_index] = temp;
    }
}

int main(){
float *a, *b, *c;
float *d_a, *d_b, *d_c;
int n = N*N;

a = (float *)malloc(n);
b = (float *)malloc(n);
c = (float *)malloc(n);

cudaMalloc((void **)&d_a,sizeof(float)*n);
cudaMalloc((void **)&d_b,sizeof(float)*n);
cudaMalloc((void **)&d_c,sizeof(float)*n);

srand(time(NULL));
for(int i =0;i<N;i++){
 for(int j =0;j<N;j++){
	a[i*N +j] = rand()%10; 	
	printf("%f ", a[i*N+j]);
}
printf("\n");
}
printf("\n\n");

srand(time(NULL));
for(int i =0;i<N;i++){
 for(int j =0;j<N;j++){
	b[i*N +j] = rand()%9; 
	printf("%f ", b[i*N+j]);	
}
printf("\n");
}

printf("\n\n");
cudaMemcpy(d_a, a, sizeof(float)*n, cudaMemcpyHostToDevice);
cudaMemcpy(d_b, b, sizeof(float)*n, cudaMemcpyHostToDevice);

mm_kernel<<<ceil((float)N*N/NUM_THREADS_PER_BLOCK), NUM_THREADS_PER_BLOCK>>>(d_a, d_b, d_c, N);
cudaMemcpy(c, d_c, sizeof(float)*n, cudaMemcpyDeviceToHost);
for(int i =0;i<N;i++){
 for(int j =0;j<N;j++){ 
	printf("%f ", c[i*N+j]);	
}
printf("\n");
}
cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
}
