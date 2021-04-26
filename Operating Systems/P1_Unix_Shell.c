// David Liu
// CSS 430 Program 1 - Basic Unix Shell
//
// Program Description:
// This program executes basic UNIX command line arguments being: redirection (< and >),
// pipe (|), running concurrently (&), and basic function calls (e.g. cat, ls, and ps)
// The semicolon within a command marks the end of a command and the start of the next command if there is one.
// Each word and symbol needs to be delimited by a space.
// Typing "!!" causes the program to execute the last inserted command again.
// If there wasn't a previous command, it notifies the user that there was no previous command.
// Typing "exit" and hitting return marks the end of the program.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include <sys/wait.h>
#include <fcntl.h>

// The max amount of words to be inputted within an argument
#define MAX_LINE 80

// Empties the imputed argument array with empty data
void clear(char* args[]) {
    for (int a = 0; a < MAX_LINE + 1; a++) {
        args[a] = NULL;
    }
}

// Redirects the output of argument execution when input command line has a '<' or a '>'.
// > = redirect output = postRedirect = STDOUT
// < = redirect input = preRedirect = STDIN
void redirect( bool preRedirect, bool postRedirect, char* args[], char* args2[]) {
    int out = -1;
    int in = -1;
    if (postRedirect) {
        out = open(args2[0], O_WRONLY | O_CREAT | O_TRUNC, 644);
        if (out < 0) {
            printf("Error\n");
        }
        dup2(out, STDOUT_FILENO);
    } else if (preRedirect) {
        in = open(args2[0], O_RDONLY, 0644);
        if (in < 0) {
            printf("Read Failure\n");
        }
        dup2(in, STDIN_FILENO);
    }
    execvp(args[0], args);
    fflush(stdin);
    fflush(stdout);
}


// Handles the pipe command by initializing a separate process and rerouting the input and output
// > = redirect output = postRedirect = STDOUT
// < = redirect input = preRedirect = STDIN
void handlePipe(char* args[], char* args2[]) {
    int fd[2];
    pipe(fd);
    int pid = fork();
    if (pid > 0) { // parent
        // close read
        close(fd[0]);
        // Links Output to Write
        dup2(fd[1], STDOUT_FILENO);
        // Executes left side
        execvp(args[0], args);
        // close write
        close(fd[1]);
    } else if (pid == 0) { // child
        // close write
        close(fd[1]);
        // Links Input to Read
        dup2(fd[0], STDIN_FILENO);
        // Execute right side
        execvp(args2[0], args2);
        // close read
        close(fd[0]);
    } else {
        printf("Pipe Failure\n");
    }
}


// Handles execution of 2 separate command concurrently
void handleAmpersand(char* args[], char* args2[]) {
    int pid = fork();
    if (pid == 0) {
        execvp(args[0], args);
    } else if (pid > 0) {
        execvp(args2[0], args2);
    } else {
        printf("Handle ampersand failure\n");
    }
    fflush(stdin);
    fflush(stdout);
}

// Executes the commands given information if the inputted line requires redirection, a pipe, or to be run
// concurrently
void execute(bool ampersand, bool _pipe, bool preRedirect, bool postRedirect, char* args[], char* args2[]) {
    pid_t pid = fork();
    // Child Process
    if (pid == 0) {
        if (ampersand) {
            handleAmpersand(args, args2);
        } else if (preRedirect || postRedirect) {
            redirect(preRedirect, postRedirect, args, args2);
        } else if (_pipe) {
            handlePipe(args, args2);
        } else {
            execvp(args[0], args);
        }
    } else if (pid > 0) {  // Parent Process
        wait(NULL);
    } else {
        printf("First Fork Failed\n");
        return;
    }
    fflush(stdout);
    fflush(stdin);
}

// Parses the user inputted string w/ delimited spaces to be ready for execution.
void parseInput(char* command) {
    // arguments of 1st side
    char** args = (char **) malloc( MAX_LINE * sizeof(char *) );
    // arguments of 2nd side
    char** args2 = (char **) malloc( MAX_LINE * sizeof(char *) );

    bool ampersand = false;
    bool pipe = false;
    bool pRedirect = false;
    bool fRedirect = false;
    int index = 0;
    char* arr = strtok(command, " ");
    while (arr != NULL) {
        if (strcmp(arr, ";") == 0) {
            execute(ampersand, pipe, pRedirect, fRedirect, args, args2);
            index = 0;
            arr = strtok(NULL, " ");
            ampersand = false;
            pipe = false;
            pRedirect = false;
            fRedirect = false;
            clear(args);
            clear(args2);
            continue;
        }
        if (strcmp(arr, "&") == 0) {
            index = 0;
            ampersand = true;
            arr = strtok(NULL, " ");
            continue;
        }
        if (strcmp(arr, "|") == 0) {
            index = 0;
            pipe = true;
            arr = strtok(NULL, " ");
            continue;
        }
        if (strcmp(arr, "<") == 0) {
            index = 0;
            pRedirect = true;
            arr = strtok(NULL, " ");
            continue;
        }
        if (strcmp(arr, ">") == 0) {
            index = 0;
            fRedirect = true;
            arr = strtok(NULL, " ");
            continue;
        }
        if (ampersand || pipe || pRedirect || fRedirect) {
            args2[index] = arr;
        } else {
            args[index] = arr;
        }
        index++;
        arr = strtok(NULL, " ");
    }
    if (index != 0) {
        execute(ampersand, pipe, pRedirect, fRedirect, args, args2);
    }
    free(arr);
}

// Implements the recursiveness of getting user input until he/she inserts "exit" in which the program ends.
int main(void) {
    char prev[MAX_LINE + 1] = "";
    while (1) {
        fflush(stdout);
        fflush(stdin);
        printf("osh>");
        char s[MAX_LINE + 1];
        if (fgets(s, MAX_LINE + 1, stdin) == NULL) {
            printf("%s\n", "Failed to read");
        } else {
            // removes end of line from fgets
            if (s[strlen(s) - 1] == '\n') {
                s[strlen(s) - 1] = 0;
            }
            if (strcmp(s, "exit") == 0) {
                break;
            }
            if (strcmp(prev, "") == 0 && strcmp(s, "!!") == 0) {
                printf("%s\n", "No Previous History");
            } else {
                if (strcmp(s, "!!") == 0) {
                    parseInput(prev);
                } else {
                    strcpy(prev, s);
                    parseInput(s);
                }
            }
        }
    }
    return 0;
}
