// David Liu
// CSS 430 Program 4 - Contiguous Memory Allocation
//
// Program Description:
// This program executes user input command to allocate, free, compact, read, and show contiguous memory
// algorithms in action.
// Takes user input in the form:
// A  <name>  <size>  <algo>
// Allocate <size> bytes for process <name> using algorithm <algo>.  <algo> can be any of F for First-Fit,
// B for Best-Fit or W for Worst-Fit.
// F  <name>
// Free all the allocations owned by <name>
// S Show the state of the memory pool
// R  <file>
// Read the script in the file called <file> and execute each command.
// C
// Compact the memory pool, sliding all allocations to lower addresses so they become one contiguous block,
// and so that all the free space lies to the right as one contiguous block

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Max size of our memory pool
#define MEMSIZE 80
#define MAX_LINE 255
#define INFINITY 2147483648
// Our data
char memory[MEMSIZE];

// Finds the first available slot to fill in data. Will print no available space if no available space is found
void firstFit(const char name[MAX_LINE], int size) {
    int index = 0;
    int count = 0;
    for (int a = 0; a < MEMSIZE; a++) {
        if (memory[a] == '.') {
            if (count == 0) {
                index = a;
            }
            count++;
            if (size == count) {
                for (int b = index; b < index + size; b++) {
                    memory[b] = name[0];
                }
                return;
            }
        } else {
            count = 0;
        }
    }

    printf("%s\n", "No available space for first fit");
}

// Finds the smallest slot capable of fitting in the size of given data
void bestFit(const char name[MAX_LINE], int size) {
    int minIndex = -1;
    long minCount = INFINITY;
    int index = 0;
    int count = 0;
    for (int a = 0; a < MEMSIZE; a++) {
        if (memory[a] == '.') {
            if (count == 0) {
                index = a;
            }
            count++;
        } else {
            if (count == size) {
                // store
                for (int b = index; b < index + size; b ++) {
                    memory[b] = name[0];
                }
                return;
            } else if (count > size) {
                if (count < minCount) {
                    minCount = count;
                    minIndex = index;
                }
                count = 0;
            } else {
                count = 0;
            }
        }
    }

    // store if minIndex
    if (minIndex >= 0) {
        for (int a = minIndex; a < minIndex + size; a++) {
            memory[a] = name[0];
        }
        return;
    }
    printf("%s\n", "No available space for best fit");

}

// Finds the largest slot capable of fitting in the size of given data
void worstFit(const char name[MAX_LINE], int size) {
    int maxIndex = -1;

    long maxCount = -INFINITY;
    int index = 0;
    int count = 0;
    for (int a = 0; a < MEMSIZE; a++) {
        if (memory[a] == '.') {
            if (count == 0) {
                index = a;
            }
            count++;
        } else {
            if (count >= size) {
                if (count > maxCount) {
                    maxCount = count;
                    maxIndex = index;
                }
                count = 0;
            } else {
                count = 0;
            }
        }
    }

    // store if minIndex
    if (maxIndex >= 0) {
        for (int a = maxIndex; a < maxIndex + size; a++) {
            memory[a] = name[0];
        }
        return;
    }
    printf("%s\n", "No available space for worst fit");
}

// Takes user input in the form: A  <name>  <size>  <algo>
void allocate(char name[MAX_LINE], int size, char algo[MAX_LINE]) {
    if (algo[0] == 'F') {
        firstFit(name, size);
    } else if (algo[0] == 'B') {
        bestFit(name, size);
    } else if (algo[0] == 'W') {
        worstFit(name, size);
    } else {
        printf("%s\n", "Invalid Algorithm");
    }
}

// Frees all occurrences of the given character in the memory pool.
void freeSpace(const char name[MAX_LINE]) {
    for (int a = 0; a < MEMSIZE; a++) {
        if (memory[a] == name[0]) {
            memory[a] = '.';
        }
    }
}

// Compacts the data by shifting all data to the left leaving all available empty space in one contniuous block.
void compact() {
    int openIndex = 0;
    for (int a = 0; a < MEMSIZE; a++) {
        if (memory[a] != '.') {
            if (openIndex != a) {
                memory[openIndex] = memory[a];
                memory[a] = '.';
            }
            openIndex++;
        }
    }
}

// Reads from a given txt file following the standard format
void read(const char* fileName) {
    FILE *fp;
    char line[MAX_LINE];
    fp = fopen(fileName, "r");
    if (fp == NULL) {
        printf("%s\n", "File could not be opened");
        return;
    }
    while (fgets(line, MAX_LINE, fp)) {
        if (line[strlen(line) - 1] == '\n') {
            line[strlen(line) - 1] = 0;
        }
        printf("%s\n", line);
        if (line[0] == 'A') {
            char* s = strtok(line, " ");
            char name[MAX_LINE];
            int size = 0;
            char algo[MAX_LINE];
            int index = 0;
            while (s != NULL) {
                if (index == 1) {
                    strcpy(name, s);
                } else if (index == 2) {
                    size = atoi(s);
                } else if (index == 3) {
                    strcpy(algo, s);
                }
                index++;
                s = strtok(NULL, " ");
            }
            allocate(name, size, algo);
        } else if (line[0] == 'F') {
            char* s = strtok(line, " ");
            char name[MAX_LINE];
            s = strtok(NULL, " ");
            strcpy(name, s);
            freeSpace(name);
        } else if (line[0] == 'S') {
            // Show
            printf("%s\n", memory);
        } else if (line[0] == 'C') {
            // Compact
            compact();
        } else {
            printf("%s\n", "Invalid Line");
        }
    }

    fclose(fp);
}

// Loops while user does input "exit" and executes commands to allocate, free, read, and compact memory.
int main() {
    // Initializes the memory
    for (int a = 0; a < MEMSIZE; a++) {
        memory[a] = '.';
    }
    // User Input
    while (1) {
        fflush(stdout);
        fflush(stdin);
        char s[MAX_LINE + 1];
        // Gets user input
        if (fgets(s, MAX_LINE + 1, stdin) == NULL) {
            printf("%s\n", "Failed to read");
        } else {
            if (s[strlen(s) - 1] == '\n') {
                s[strlen(s) - 1] = 0;
            }
            char* string = strtok(s, " ");
            if (strcmp(string, "A") == 0) {
                // Loops through delimiter to find substring of desired allocate information
                char name[MAX_LINE];
                int size = 0;
                char algo[MAX_LINE];
                int index = 0;
                while (string != NULL) {
                    if (index == 1) {
                        strcpy(name, string);
                    } else if (index == 2) {
                        size = atoi(string);
                    } else if (index == 3) {
                        strcpy(algo, string);
                    }
                    index++;
                    string = strtok(NULL, " ");
                }
                allocate(name, size, algo);
            } else if (strcmp(string, "R") == 0) {
                char name[MAX_LINE];
                string = strtok(NULL, " ");
                strcpy(name, string);
                read(name);
            } else if (strcmp(string, "F") == 0) {
                char name[MAX_LINE];
                int index = 0;
                while (string != NULL) {
                    if (index == 1) {
                        strcpy(name, string);
                    }
                    index++;
                    string = strtok(NULL, " ");
                }
                freeSpace(name);
            } else if (strcmp(string, "S") == 0) {
                printf("%s\n", memory);
            } else if (strcmp(string, "C") == 0) {
                compact();
            } else if (strcmp(string, "exit") == 0) {
                return 0;
            } else {
                printf("%s\n", "Invalid User Input");
            }
        }
    }
}
