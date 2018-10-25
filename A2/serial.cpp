#include<iostream>
#define N 100
#define M 300
#define P 200
#include<omp.h>
using namespace std;

int main(){
float start = omp_get_wtime();
int a[N*M], b[M*P], c[N*P];
for(int i =0;i<N;i++){
for(int j =0;j<M;j++){
a[i*M + j] = 1;
}
}
for(int i =0;i<N;i++){
for(int j =0;j<M;j++){
cout<<a[i*M+j]<<" ";
}
cout<<endl;
}
for(int i =0;i<M;i++){
for(int j =0;j<P;j++){
b[i*P + j] = 1;
}
}
for(int i =0;i<M;i++){
for(int j =0;j<P;j++){
cout<<b[i*P+j]<<" ";
}
cout<<endl;
}
cout<<endl;
for(int row =0;row<N;row++){
for(int col =0;col<P;col++){
	int sum =0;	
	for(int i =0;i<M;i++){
	sum += a[row*M + i] * b[i*P + col];
	}
	c[row*P + col] = sum;
}
}
for(int i=0;i<N;i++){
for(int j =0;j<P;j++)
{
cout<<c[i*P+j]<<" ";
//cout<<endl;
}

cout<<endl;
}
cout<<(float) omp_get_wtime() - start<<endl;
}
