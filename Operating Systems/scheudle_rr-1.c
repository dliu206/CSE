//
//// David Liu
//// CSS 430 Program 3 - Schedule Round Robin
////
//// Program Description:
//// This scheduler receives all tasks and runs a simulated time slice of 10 ms from the least task number to the highest.
//// Ex. T1, T2, T3, ... T10
//
//#include<stdlib.h>
//#include "task.h"
//#include "list.h"
//#include <stddef.h>
//#include <string.h>
//#include <stdbool.h>
//
//#include "schedulers.h"
//#include "cpu.h"
//
//#define QUANTUM 10
//struct node* list = NULL;
//
//// Adds each task to an unsorted list
//void add(char* name, int priority, int burst) {
//    Task* t = malloc(sizeof(Task));
//    t->name = malloc(sizeof(char) * strlen(name));
//    strcpy(t->name, name);
//    t->priority = priority;
//    t->burst = burst;
//    insert(&list, t);
//}
//
//
//void schedule() {
//    // Keeps track of the last task ran
//    char lastTask[100];
//    strcpy(lastTask, "");
//    while (list != NULL) {
//        struct node* curr = list;
//        bool ran = false;
//
//        if (strcmp(curr->task->name, lastTask) == 0 || strcmp(lastTask, "") == 0) {
//            // run to last
//            while (curr->next != NULL) {
//                curr = curr->next;
//            }
//
//            strcpy(lastTask, curr->task->name);
//            if (curr->task->burst > QUANTUM) {
//                run(curr->task, QUANTUM);
//                curr->task->burst -= QUANTUM;
//            } else {
//                run(curr->task, curr->task->burst);
//                delete(&list, curr->task);
//            }
//            ran = true;
//        } else if (strcmp(curr->task->name, lastTask) > 0) { // traverse case
//            while (curr->next != NULL) {
//                if (strcmp(curr->next->task->name, lastTask) <= 0) {
//                    // run curr
//                    strcpy(lastTask, curr->task->name);
//                    if (curr->task->burst > QUANTUM) {
//                        run(curr->task, QUANTUM);
//                        curr->task->burst -= QUANTUM;
//                    } else {
//                        run(curr->task, curr->task->burst);
//                        delete(&list, curr->task);
//                    }
//                    ran = true;
//                    break;
//                } else {
//                    curr = curr->next;
//                }
//
//            }
//
//        }
//        if (!ran) {
//            strcpy(lastTask, curr->task->name);
//            if (curr->task->burst > QUANTUM) {
//                run(curr->task, QUANTUM);
//                curr->task->burst -= QUANTUM;
//            } else {
//                run(curr->task, curr->task->burst);
//                delete(&list, curr->task);
//            }
//        }
//    }
//}