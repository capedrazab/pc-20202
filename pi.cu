#@title pi
%%cu
/****** calculate pi *******/
#include <stdio.h>
#include <math.h>
// For the CUDA runtime routines (prefixed with "cuda_")
#include <cuda_runtime.h>

#define BLOCKSPERGRID  512
#define NUMTHREADS 8192
#define ITERATIONS 16e09

/*****************************************************************************
/*kernel
*****************************************************************************/


__global__ void calculatePi(double *piTotal, long int iterations, int totalThreads)
{   long int initIteration, endIteration;
    long int i = 0;
    double piPartial;
    
    int index = (blockDim.x * blockIdx.x) + threadIdx.x;

    initIteration = (iterations/totalThreads) * index;
    endIteration = initIteration + (iterations/totalThreads) - 1;
    
    i = initIteration;
    piPartial = 0;
    
    do{
        piPartial = piPartial + (double)(4.0 / ((i*2)+1));
        i++;
        piPartial = piPartial - (double)(4.0 / ((i*2)+1));
        i++;
    }while(i < endIteration);

    piTotal[index] = piPartial;
    
    __syncthreads();
    if(index == 0){
        for(i = 1; i < totalThreads; i++)
            piTotal[0] = piTotal[0] + piTotal[i];
    }
}


/******************************************************************************/


int main()
{   
    int blocksPerGrid, threadsPerBlock, i, size;
    long int iterations;
    int totalThreads;
    double *h_pitotal, *d_pitotal;
    
    blocksPerGrid = BLOCKSPERGRID;
    cudaError_t err = cudaSuccess;

    size = sizeof(double)*NUMTHREADS;
    h_pitotal = (double *)malloc(size);
    if ( h_pitotal == NULL){
        fprintf(stderr, "Failed to allocate host vectors!\n");
        exit(EXIT_FAILURE);
    }
    
    for(i = 0; i < NUMTHREADS; i++)
        h_pitotal[i] = 0.0;

    err = cudaMalloc((void **)&d_pitotal, size);
    if (err != cudaSuccess){
        fprintf(stderr, "Failed to allocate device vector C (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }
    
    err = cudaMemcpy(d_pitotal, h_pitotal, sizeof(double)*NUMTHREADS, cudaMemcpyHostToDevice);
    if (err != cudaSuccess){
        fprintf(stderr, "Failed to copy vector C from device to host (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    // Lanzar KERNEL
    threadsPerBlock = NUMTHREADS/blocksPerGrid;
    totalThreads = blocksPerGrid * threadsPerBlock;
    iterations = ITERATIONS;
    printf("CUDA kernel launch with %d blocks of %d threads Total: %i       ", blocksPerGrid, threadsPerBlock, totalThreads  );
    calculatePi<<<blocksPerGrid, threadsPerBlock>>>(d_pitotal, iterations, totalThreads);
    err = cudaGetLastError();
    if (err != cudaSuccess){
        fprintf(stderr, "Failed to launch vectorAdd kernel (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    err = cudaMemcpy(h_pitotal, d_pitotal, size, cudaMemcpyDeviceToHost);
    if (err != cudaSuccess){
        fprintf(stderr, "Failed to copy vector C from device to host (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    err = cudaFree(d_pitotal);
    if (err != cudaSuccess){
        fprintf(stderr, "Failed to free device vector C (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }

    printf("Calculated pi: %.12f", *h_pitotal);
    // Free host memory

    free(h_pitotal);
    err = cudaDeviceReset();
    if (err != cudaSuccess){
        fprintf(stderr, "Failed to deinitialize the device! error=%s\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }
    return 0;
}

