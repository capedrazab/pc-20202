// ejecutar con mpirun -np 4 mpi_test

#include <stdio.h>
#include <string.h>
#include <mpi.h>

#define MSG_LENGTH 15

int main (int argc, char *argv[])
{
        int i, tag=1, tasks, iam;
        char message[MSG_LENGTH];
        MPI_Status status;

        MPI_Init(&argc, &argv);
        MPI_Comm_size(MPI_COMM_WORLD, &tasks);
        MPI_Comm_rank(MPI_COMM_WORLD, &iam);
        if (iam == 0) {
                strcpy(message, "Hello, world!");
                for (i = 1; i < tasks; i++)
                        MPI_Send(message, MSG_LENGTH, MPI_CHAR, i, tag, MPI_COMM_WORLD);
        } else{
                MPI_Recv(message, MSG_LENGTH, MPI_CHAR, 0, tag, MPI_COMM_WORLD, &status);
        }
        printf("node %d: %s\n", iam, message);
        MPI_Finalize();
        return 0;
}

