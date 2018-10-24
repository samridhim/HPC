/* code for bubble sort in openmp using odd even strategy 
to run it : gcc -fopenmp bubble_sort
			./a.out
*/

#include<omp.h>  //openmp header file, default in gcc
#include<stdio.h>
#define NUM_THREADS 1 //defining the number of threads that openmp can use. Threads are Numbered as 0,1,.....

int main()
	{
		//omp_set_num_threads(NUM_THREADS);   //set openmp number of threads
		double start = omp_get_wtime(); 
		int A[10000];
		int j = 10000;
		for(int i =0;i<10000;i++)
		A[i] = j--;
		for(int k =0;k<10000;k++){             //number of passes
			if(k%2==0){                     //if k is even then do even indices, i.e, 0-1, 2-3, 4-5...
			#pragma omp parallel for        //achieve parallelism by telling each thread to take one set of indices (0-1, 2-3...)
				for(int i =0;i<10000;i+=2){
					//printf("Thread ID : %d\n", omp_get_thread_num()); 
					if(A[i]>A[i+1]){
						int temp = A[i];	
						A[i] = A[i+1];
						A[i+1] = temp;
					}
				}
			}
			else{	                       //if odd then take indices 1-2, 3-4, 5-6...
			#pragma omp parallel for      //achieve parallelism by telling each thread to take one set of indices (1-2,3-4...)
				for(int i =1;i<10000-1;i+=2){
					//printf("Thread ID : %d\n", omp_get_thread_num()); 
					if(A[i]>A[i+1]){
						int temp = A[i];
						A[i] = A[i+1];
						A[i+1] = temp;
					}
				}
			}
		}                               //end bubble sort
		for(int i =0;i<10000;i++) 
			printf("%d  ", A[i]);
		double end = omp_get_wtime();
		printf("\nTime taken in second(s) is %g \n", end - start); 
}

