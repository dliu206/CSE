//
//// David Liu
//// CSS 430 Program 3 - Scheduler Priority
////
//// Program Description:
//// This scheduler receives all tasks and executes tasks at higher priorities first followed by their task number
//// in ascending order.
//// (Max priority is 10 and Least priority is 1)
//// Ex. T1, T2, T3, ... T10
//
//#include<stdlib.h>
//#include "task.h"
//#include "list.h"
//#include <stddef.h>
//#include <string.h>
//
//#include "schedulers.h"
//#include "cpu.h"
//
//struct node* list = NULL;
//struct node* priorityList[10];
//
//// [name] [priority] [CPU burst]
//void add(char* name, int priority, int burst) {
//    Task* t = malloc(sizeof(Task));
//    t->name = malloc(sizeof(char) * strlen(name));
//    strcpy(t->name, name);
//    t->priority = priority;
//    t->burst = burst;
//    insert(&priorityList[priority - 1], t);
//}
//
//void schedule() {
//    for (int a = 9; a >= 0; a--) {
//        if (priorityList[a] != NULL) {
//            while (priorityList[a] != NULL) {
//                struct node* curr = priorityList[a];
//                while (curr->next != NULL) {
//                    curr = curr->next;
//                }
//                run(curr->task, curr->task->burst);
//                delete(&priorityList[a], curr->task);
//            }
//        }
//    }
//}