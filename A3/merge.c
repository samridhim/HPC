
/*
* Merge Sort using OpenMP.
* code referred from http://www.cs.kent.edu/~jbaker/23Workshop/Chesebrough/mergesort/mergesortOMP.cpp
* to run -> gcc -fopenmp merge.c
*		 -> export OMP_NUM_THREADS=<<N>> N is the number of threads you want. N=1 means no parallelism.
*		 ->	./a.out
*/

#include<omp.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define n 2000
void merge(int A[], int size, int temp[])   //merge left and right half sorted arrays
{
	int i =0;
	int j = size/2;
	int ti = 0;
	while(i<size/2 && j<size)
	{
		if(A[i]<A[j]) {
		temp[ti++] = A[i++];
		}
		else
		temp[ti++] = A[j++];
	}
	while(i<size/2)
	{
		temp[ti++] = A[i++];
	}
	while(j<size) 
	{
		temp[ti++] = A[i++];
	}	

	memcpy(A, temp, sizeof(int)*size);   //copy the temp array to final array A
}


/* 
So, #pragma omp task firstprivate creates a series of tasks such that each recursive call to this 
function is given to one thread which will execute it.

#pragma omp taskwait is acting like a "barrier". It waits for each of the children thread to complete before joining to master thread.

For more info on tasks refer - http://www.icl.utk.edu/~luszczek/teaching/courses/fall2016/cosc462/pdf/W45L1%20-%20OpenMP%20Tasks.pdf
*/
void merge_sort(int A[], int size , int temp[])
{  	
	if(size<2) return;	
	#pragma omp task firstprivate(A, size, temp) 
	{
	//printf("Thread ID : %d is merging. \n", omp_get_thread_num());  	
	merge_sort(A, size/2, temp);
	}
	#pragma omp task firstprivate(A, size, temp)
	{
	printf("Thread ID : %d is merging. \n", omp_get_thread_num());  
	merge_sort(A+size/2, size-(size/2), temp);
	}
	#pragma omp taskwait
	{
	merge(A, size, temp);
	}
}

int main()
{
	double start = omp_get_wtime();
	int *A = (int*) malloc(sizeof(int) * n);
	for(int i =0;i<n;i++)
	{
		A[i] = n-i;
	}
	int *temp = (int*) malloc(sizeof(int) * n);
	#pragma omp parallel num_threads(10)
	{
	#pragma omp single
	{
	merge_sort(A, n, temp);
	}	
	}	
	printf("\n");
	//for(int i =0;i<n;i++) printf("%d ", A[i]); //print sorted
	printf("Time taken is %g s", omp_get_wtime() - start);  //calculate time taken by code.
	free(A);
	free(temp);
}

