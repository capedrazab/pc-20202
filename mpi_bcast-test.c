//mpicc mpi_test2.c -o mpi_test2 -lm
//

#include <stdio.h>
#include <string.h>
#include <mpi.h>
#include <math.h>
#define MSG_LENGTH 10

int main (int argc, char *argv[])
{
    int i, tag=0, tasks, iam;
    double x;
    char message[MSG_LENGTH+2];
    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int namelen;
    const int root=0;
    MPI_Status status;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &tasks);
    MPI_Comm_rank(MPI_COMM_WORLD, &iam);
    strcpy(message, "Hola Mundo");
    MPI_Bcast(message, MSG_LENGTH, MPI_CHAR, root, MPI_COMM_WORLD);
    if (iam == 0) {
        printf("\nMensaje enviado"); fflush(stdout);
     } else {
        printf("\nnode %d %s ", iam, message);                        
        MPI_Get_processor_name(processor_name, &namelen);
        printf("processor %s", processor_name); fflush(stdout);
    }
    printf("\n");
    MPI_Finalize();
}
