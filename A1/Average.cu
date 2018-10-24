#include <stdio.h>
#define N 10
#define BLOCK_SIZE 512
//Note: N should always be in powers of 2 (like 2, 4, 8, 16, 32, ...) -Mohit Agrawal
int main()
{
 //int num_blocks = N/BLOCK_SIZE;
 int *h_a = (int *) malloc(sizeof(int) * N);
 for(int i =0;i<N;i++){
 h_a[i] = 5;
 printf("%d", h_a[i]);
 }
 int *d_a;
 cudaMalloc((void **)&d_a, sizeof(int) *N);
 cudaMemcpy(&d_a, h_a, sizeof(int)*N, cudaMemcpyHostToDevice);
  h_a = (int *) malloc(sizeof(int));
  cudaMemcpy(h_a, d_a, sizeof(int), cudaMemcpyDeviceToHost);
  printf("%d", h_a);
}
