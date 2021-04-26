
// David Liu
// CSS 430 Program 3 - Scheduler Priority Round Robin
//
// Program Description:
// This scheduler receives all tasks and executes tasks at higher priorities first followed by their task number
// in ascending order with a simulated time slice of 10 ms
// (Max priority is 10 and Least priority is 1)
// Ex. T1, T2, T3, ... T10
#include <stdlib.h>
#include "task.h"
#include "list.h"
#include <stddef.h>
#include <string.h>
#include <stdbool.h>
#include "schedulers.h"
#include "cpu.h"

struct node* priorityList[MAX_PRIORITY + 1];


// [name] [priority] [CPU burst]
void add(char* name, int priority, int burst) {
    Task* t = malloc(sizeof(Task));
    t->name = malloc(sizeof(char) * strlen(name));
    strcpy(t->name, name);
    t->priority = priority;
    t->burst = burst;
    insert(&priorityList[priority], t);
}


void schedule() {
    while (1) {
        for (int a = MAX_PRIORITY; a >= MIN_PRIORITY; a--) {
            char lastTask[100];
            strcpy(lastTask, "");
            while (priorityList[a] != NULL) {
                struct node* curr = priorityList[a];
                bool ran = false;

                if (strcmp(curr->task->name, lastTask) == 0 || strcmp(lastTask, "") == 0) {
                    // run to last
                    while (curr->next != NULL) {
                        curr = curr->next;
                    }

                    strcpy(lastTask, curr->task->name);
                    if (curr->task->burst > QUANTUM) {
                        run(curr->task, QUANTUM);
                        curr->task->burst -= QUANTUM;
                    } else {
                        run(curr->task, curr->task->burst);
                        delete(&priorityList[a], curr->task);
                    }
                    ran = true;
                } else if (strcmp(curr->task->name, lastTask) > 0) { // traverse case
                    while (curr->next != NULL) {
                        if (strcmp(curr->next->task->name, lastTask) <= 0) {
                            // run curr
                            strcpy(lastTask, curr->task->name);
                            if (curr->task->burst > QUANTUM) {
                                run(curr->task, QUANTUM);
                                curr->task->burst -= QUANTUM;
                            } else {
                                run(curr->task, curr->task->burst);
                                delete(&priorityList[a], curr->task);
                            }
                            ran = true;
                            break;
                        } else {
                            curr = curr->next;
                        }

                    }

                }
                if (!ran) {
                    strcpy(lastTask, curr->task->name);
                    if (curr->task->burst > QUANTUM) {
                        run(curr->task, QUANTUM);
                        curr->task->burst -= QUANTUM;
                    } else {
                        run(curr->task, curr->task->burst);
                        delete(&priorityList[a], curr->task);
                    }
                }
            }

        }

        break;


    }
}