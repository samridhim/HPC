#include<iostream>
#include<omp.h>
#include<math.h>
using namespace std;

int main()
{
int start = omp_get_wtime();
int N = 100000;
float arr[N];
for(int i =0;i<N;i++){
arr[i] = 5;
}
long int sum =0;
omp_set_num_threads(1);
#pragma omp parallel for reduction(+:sum)
for(int i =0;i<N;i++){
sum+= arr[i];
}
cout<<sum<<endl;
int min_s = arr[0];
#pragma omp parallel for reduction(min:min_s)
for(int i =0;i<N;i++){
   if(arr[i] < min_s)
        {
            min_s = arr[i];  
        }
}
cout<<min_s<<endl;
int max_s = arr[0];
#pragma omp parallel for reduction(max:max_s)
for(int i =0;i<N;i++){
   if(arr[i] > max_s)
        {
            max_s = arr[i];  
        }
}
cout<<max_s<<endl;
float mean = sum/N;
#pragma omp parallel for 
for(int i =0;i<N;i++){
arr[i] -= mean;
}
#pragma omp parallel for 
for(int i =0;i<N;i++){
arr[i] *= arr[i];
}
float sums =0;
#pragma omp parallel for reduction(+:sums) 
for(int i =0;i<N;i++){
sums+= arr[i];
}
float var = sums/N;
float stddev = sqrt(var);
cout<<var<<endl;
cout<<stddev<<endl;
cout<<"Time taken : "<<omp_get_wtime() - start<<" s";
return 0;

}
