#include<mpi.h>
#include<iostream>
using namespace std;
#define N 1000
#define send_data_tag 2000
#define return_data_tag 2001

int binarySearch(int arr[], int key, int l, int r){
while(l<=r){
int mid = (l+r)/2;
if(arr[mid]==key)
return mid;
if(arr[mid]<key)
l = mid+1;
else if(arr[mid]>key)
r = mid-1;
}
return -1;
}

int main(int argc, char *argv[]){
int rank, size, isFound = -1,solId, num_elems_recvd, proc_array[N],key;
int avg_elems_pp;
MPI_Init(&argc, &argv);
MPI_Comm_rank(MPI_COMM_WORLD, &rank);
MPI_Comm_size(MPI_COMM_WORLD, &size);
MPI_Status status;
if(rank ==0){
int init_array[N];
for(int i =0;i<N;i++){
init_array[i] = i+1;
}
cout<<"Enter key";
cin>>key;
int avg_elems_pp = N/size;
for(int i = 1; i<size;i++){
int start = i*avg_elems_pp;
MPI_Send(&avg_elems_pp, 1, MPI_INT, i, send_data_tag, MPI_COMM_WORLD);
MPI_Send(&init_array[start], avg_elems_pp, MPI_INT, i, send_data_tag, MPI_COMM_WORLD);
MPI_Send(&key, 1, MPI_INT, i, send_data_tag, MPI_COMM_WORLD);
}
int index = binarySearch(init_array, key, 0, avg_elems_pp-1);
if(index>=0){
solId = 0;
isFound = index;
cout<<"Found at "<<index<<" by Process "<<solId<<endl; 
}
else{
for(int id =1;id<size;id++){
int index=-1;
MPI_Recv(&index, 1, MPI_INT,id, return_data_tag, MPI_COMM_WORLD, &status);
if(index!=-1){
isFound = index + id*avg_elems_pp;
solId = id;
}
if(isFound>=0){
cout<<"Found at "<<index<<" by Process "<<solId<<endl; 
break;
}
}
}
cout<<"Sorry not Found key"<<endl;
}
else
{
MPI_Recv(&num_elems_recvd, 1, MPI_INT, 0, send_data_tag, MPI_COMM_WORLD, &status);
MPI_Recv(&proc_array, num_elems_recvd, MPI_INT, 0, send_data_tag, MPI_COMM_WORLD, &status);
MPI_Recv(&key, 1, MPI_INT, 0, send_data_tag, MPI_COMM_WORLD, &status);
isFound = binarySearch(proc_array, key, 0, num_elems_recvd);
MPI_Send(&isFound, 1, MPI_INT, 0, return_data_tag, MPI_COMM_WORLD);
}
MPI_Finalize();
}
