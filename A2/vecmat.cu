#include<stdio.h>
#include<time.h>
__global__ void vectadd(float *a, float *b, float *c, int n, int m){
int tid = threadIdx.x + blockIdx.x * blockDim.x;
int sum =0;
if(tid<m){
for(int i =0;i<n;i++){
sum+= a[i]*b[i*m+tid];
}
c[tid] = sum;
}
}

int main(){
float *a, *b, *c;
float *d_a, *d_b, *d_c;

int n = 3;
int m = 4;

a = (float *) malloc(sizeof(float)*n);
b = (float *)malloc(sizeof(float)*n*m);
c = (float *)malloc(sizeof(float)*m);

cudaMalloc((void **)&d_a, sizeof(float)*n);
cudaMalloc((void **)&d_b, sizeof(float)*n*m);
cudaMalloc((void **)&d_c, sizeof(float)*m);

for(int i =0;i<n;i++){
a[i] = rand()%10;
printf("%f ", a[i]);
}
printf("\n");
for(int i =0;i<n;i++){
for(int j =0;j<m;j++){
b[i*m +j] = rand()%9;
printf("%f ",b[i*n +j]);
}
printf("\n");
}
printf("\n");

cudaMemcpy(d_a, a, sizeof(float)*n,cudaMemcpyHostToDevice);
cudaMemcpy(d_b, b, sizeof(float)*n*m, cudaMemcpyHostToDevice);

vectadd<<<ceil(float(4/3)), 4>>>(d_a, d_b, d_c, n, m);
cudaMemcpy(c, d_c, sizeof(float)*m, cudaMemcpyDeviceToHost);

for(int i =0;i<m;i++){
printf("%f", c[i]);}

return 0;
}
