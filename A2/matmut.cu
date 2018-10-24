#include<stdio.h>
#include<time.h>
#define N 2
#define M 3
#define P 2
#define BLOCK_SIZE 16
__global__ void mm_kernel(float *d_a, float *d_b, float *d_c, int n, int m, int p){
    int row = blockIdx.y * blockDim.y + threadIdx.y; 
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int sum = 0;
    if( col < p && row < n) 
    {
        for(int i = 0; i < m; i++) 
        {
            sum += d_a[row * m + i] * d_b[i * p + col];
        }
        d_c[row * p + col] = sum;
}
}

int main(){
float *a, *b, *c;
float *d_a, *d_b, *d_c;
int n = N*M;
int t = M*P;
int u = N*P;

a = (float *)malloc(n);
b = (float *)malloc(t);
c = (float *)malloc(u);

cudaMalloc((void **)&d_a,sizeof(float)*n);
cudaMalloc((void **)&d_b,sizeof(float)*t);
cudaMalloc((void **)&d_c,sizeof(float)*u);

srand(time(NULL));
for(int i =0;i<N;i++){
 for(int j =0;j<M;j++){
	a[i*M +j] = rand()%10; 	
	printf("%f ", a[i*M+j]);
}
printf("\n");
}
printf("\n\n");

srand(time(NULL));
for(int i =0;i<M;i++){
 for(int j =0;j<P;j++){
	b[i*P +j] = rand()%9; 
	printf("%f ", b[i*P+j]);	
}
printf("\n");
}

printf("\n\n");
cudaMemcpy(d_a, a, sizeof(float)*n, cudaMemcpyHostToDevice);
cudaMemcpy(d_b, b, sizeof(float)*t, cudaMemcpyHostToDevice);
mm_kernel<<<dim3(BLOCK_SIZE,BLOCK_SIZE,1), dim3(N,P,1)>>>(d_a, d_b, d_c, N,M,P);
cudaMemcpy(c, d_c, sizeof(float)*u, cudaMemcpyDeviceToHost);
for(int i =0;i<N;i++){
 for(int j =0;j<P;j++){ 
	printf("%f ", c[i*P+j]);	
}
printf("\n");
}
cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
}
