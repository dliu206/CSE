//
//// David Liu
//// CSS 430 Program 3 - Scheduler FCFS
////
//// Program Description:
//// This scheduler receives all tasks and runs the next immediately received task in a priority queue
//// Ex. T1, T2, T3, ... T10
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
//
//void add(char* name, int priority, int burst) {
//    Task* t = malloc(sizeof(Task));
//    t->name = malloc(sizeof(char) * strlen(name));
//    strcpy(t->name, name);
//    t->priority = priority;
//    t->burst = burst;
//    insert(&list, t);
//}
//
//void schedule() {
//    while (list != NULL) {
//        struct node* curr = list;
//        while (curr->next != NULL) {
//            curr = curr->next;
//        }
//        Task* task = curr->task;
//
//        run(task, task->burst);
//        delete(&list, task);
//    }
//}