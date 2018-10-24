#include<set>
#include<mpi.h>
#include<iostream>

#define send_data_tag 2001
#define return_data_tag 2002
#define N 10

int process_array[1024];
using namespace std;


int main(int argc, char *argv[]){
int start_row, end_row; int key;int num_elements_to_recv;
MPI_Init(&argc, &argv);
MPI_Status status;
int rank, size;
MPI_Comm_rank(MPI_COMM_WORLD,&rank);
MPI_Comm_size(MPI_COMM_WORLD, &size);
int initial_array[N];
for(int i =0;i<N;i++){
initial_array[i] = i+1;
}
int avg_elems_pp = N/size;
if(rank ==0){
int id;
cout<<"Hello Rank 0";
for(id = 1;id<size;id++){
MPI_Send(&avg_elems_pp, 1, MPI_INT, id, send_data_tag, MPI_COMM_WORLD);
}
}
else{
MPI_Recv(&num_elements_to_recv,1,MPI_INT,0,send_data_tag,MPI_COMM_WORLD,&status);
cout<<rank<<" "<<num_elements_to_recv<<endl;
}
MPI_Finalize();
}
