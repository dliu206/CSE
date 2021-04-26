//
//// David Liu
//// CSS 430 Program 3 - Scheduler Shortest Job First
////
//// Program Description:
//// This scheduler receives all tasks and executes tasks based on lowest burst time remaining
//#include<stdlib.h>
//#include "task.h"
//#include "list.h"
//#include <stddef.h>
//#include <string.h>
//#include <limits.h>
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
//        int min = INT_MAX;
//        Task* t = NULL;
//        struct node* curr = list;
//        while (curr != NULL) {
//            if (curr->task->burst < min) {
//                min = curr->task->burst;
//                t = curr->task;
//            } else if (min == curr->task->burst && strcmp(curr->task->name, t->name) < 0) {
//                t = curr->task;
//            }
//            curr = curr->next;
//        }
//        run(t, min);
//        delete(&list, t);
//    }
//}