#include <stdio.h>
#define N 32
#define BLOCK_SIZE 32

__global__ void add_kernel(int *X, int *Y, int *Z){
    int i = threadIdx.x;
    int j = threadIdx.y;

    int index = i*N+j;

    Z[index] = X[index] + Y[index];
}

int main()
{
    int n;
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    printf("input positive integer n: ");
    scanf("%d", &n);
    

    int X[N*N];
    int Y[N*N];

    for(int i=0; i<N; i++){
        for(int j=0; j<N; j++){
            X[i*N+j] = 0;
            Y[i*N+j] = 1;
        }
    }

    int Z[N*N];

    int *d_X, *d_Y, *d_Z;
    cudaMalloc((void**) &d_X, (N*N)*sizeof(int));
    cudaMalloc((void**) &d_Y, (N*N)*sizeof(int));
    cudaMalloc((void**) &d_Z, (N*N)*sizeof(int));

    cudaMemcpy(d_X, &X, (N*N)*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_Y, &Y, (N*N)*sizeof(int), cudaMemcpyHostToDevice);

    dim3 dimGrid(2, 1);
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE, 1);

    cudaEventRecord(start);
    add_kernel<<<dimGrid, dimBlock>>>(d_X, d_Y, d_Z);
    cudaEventRecord(stop);

    cudaMemcpy(&Z, d_Z, (N*N)*sizeof(int), cudaMemcpyDeviceToHost);

    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    cudaFree(d_X);
    cudaFree(d_Y);
    cudaFree(d_Z);

    printf("%f ms\n", milliseconds);
    for(int i=0; i<N; i++){
        for(int j=0; j<N; j++){
            printf("%d ", Z[i*N+j]);
        }
        printf("\n");
    }
}