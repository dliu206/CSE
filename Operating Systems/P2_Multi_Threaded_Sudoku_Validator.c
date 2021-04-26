
// David Liu
// CSS 430 Program 2- Multi-Threaded Sudoku Validator
//
// Program Description:
// This program validates a hard-coded given Sudoku puzzle and prints to console if the puzzle is
// a valid solution.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <stdbool.h>

// Our answer if it's valid
bool valid = true;
int NUM_THREADS = 27;
int sudoku_board[9][9] =
        {
                {6, 2, 4, 5, 3, 9, 1, 8, 7},
                {5, 1, 9, 7, 2, 8, 6, 3, 4},
                {8, 3, 7, 6, 1, 4, 2, 9, 5},
                {1, 4, 3, 8, 6, 5, 7, 2, 9},
                {9, 5, 8, 2, 4, 7, 3, 6, 1},
                {7, 6, 2, 3, 9, 1, 4, 5, 8},
                {3, 7, 1, 9, 5, 6, 8, 4, 2},
                {4, 9, 6, 1, 8, 2, 5, 7, 3},
                {2, 8, 5, 4, 7, 3, 9, 1, 6}
        };

/* structure for passing data to threads */
typedef struct
{
    int row;
    int col;
} parameters;

// Checks if the grid is valid
void* checkGrid(void* p) {
    parameters* param = (parameters*) p;
    int arr[10] = {0};
    int row = param->row;
    int col = param->col;
    for (int a = row; a < row + 3; a++) {
        for (int b = col; b < col + 3; b++) {
            if (arr[sudoku_board[a][b]] != 0) {
                valid = false;
                pthread_exit(NULL);
            } else {
                arr[sudoku_board[a][b]] = 1;
            }
        }
    }
    pthread_exit(NULL);
}

// Checks if the row is valid
void* checkRow(void* p) {
    parameters* param = (parameters*) p;
    int arr[10] = {0};
    int row = param->row;

    for (int a = 0; a < 9; a++) {
        if (arr[sudoku_board[row][a]] != 0) {
            printf("%s\n", "Check Row failure");
            valid = false;
            pthread_exit(NULL);
        } else {
            arr[sudoku_board[row][a]] = 1;
        }
    }
    pthread_exit(NULL);
}

// Checks if the column is valid
void* checkCol(void* p) {
    parameters* param = (parameters*) p;
    int arr[10] = {0};
    int col = param->col;

    for (int a = 0; a < 9; a++) {
        if (arr[sudoku_board[a][col]] != 0) {
            printf("%s\n", "Check Col failure");
            valid = false;
            pthread_exit(NULL);
        } else {
            arr[sudoku_board[a][col]] = 1;
        }
    }
    pthread_exit(NULL);
}



int main() {

    // Creates a log of pthreads to be closed when finished
    pthread_t threads[NUM_THREADS];

    // Creates pthreads for rows and columns
    int index = 0;
    for (int a = 0; a < 9; a++) {
        parameters* p1 = (parameters*) malloc (sizeof(parameters));
        // {0, 0} {0, 1} {0, 2} ...
        // increment row
        p1->row = 0;
        p1->col = a;
        pthread_create(&threads[index], NULL, checkCol, p1);
        index++;

        parameters* p2 = (parameters*) malloc (sizeof(parameters));
        // {0, 0} {1, 0} {2, 0} ...
        // increment col
        p2->row  = a;
        p2->col = 0;
        pthread_create(&threads[index], NULL, checkRow, p2);
        index++;
    }


    // Creates pthreads for grids
    for (int b = 0; b < 3; b++) {
        // {0, 0} {0, 3} {0, 6}
        parameters* p1 = (parameters*) malloc (sizeof(parameters));
        p1->row = 0;
        p1->col = b * 3;
        pthread_create(&threads[index], NULL, checkGrid, p1);
        index++;

        // {3, 0} {3, 3} {3, 6}
        parameters* p2 = (parameters*) malloc (sizeof(parameters));
        p2->row  = 3;
        p2->col = b * 3;
        pthread_create(&threads[index], NULL, checkGrid, p2);
        index++;

        // {6, 0} {6, 3} {6, 6}
        parameters* p3 = (parameters*) malloc (sizeof(parameters));
        p3->row  = 6;
        p3->col = b * 3;
        pthread_create(&threads[index], NULL, checkGrid, p3);
        index++;
    }

    // Closes all the threads
    for (int c = 0; c < NUM_THREADS; c++) {
        int temp = pthread_join(threads[c], NULL);
        if (temp != 0) {
            printf("%s\n", "Deadlock Detected");
        }
    }
    
    // Reports if it's a valid pthread
    if (valid) {
        printf("%s\n", "Valid Sudoku");
    } else {
        printf("%s\n", "Invalid Sudoku");
    }
    return 0;
}
