// David Liu
// CSS 430 Homework 5 - Synchronization Hands-on
//
// Program Description:
// This programs is a solution to the producer-consumer problem derived from the starter code
// given by Jim Hogg.

#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>

#define BUFSIZE 1000
#define gMax    20

int NUMPROD = 1;    // number of producers
int NUMCONS = 1;    // number of consumers

int gBuf[BUFSIZE];  // global gBuf
int gNum = 0;       // global counter

int gIn  = 0;       // input  cursor gIn gBuf
int gOut = 0;       // output cursor gIn gBuf


sem_t empty;
sem_t full;
sem_t flag;


void say(int me, char* msg, int x) {
    printf("%d %s %d \n", me, msg, x);
}

void insert(int x) {
    gBuf[gIn] = x;
    gIn = (gIn + 1) % BUFSIZE;
}

int extract() {
    int x = gBuf[gOut];
    return x;
}

void *producer(void* arg)
{
    int me = pthread_self();
    while (1) {
        sem_wait(&empty);
        sem_wait(&flag);
        if (gIn <= gMax) {
            int num = gNum;
            insert(num);
            gNum = (gNum + 1) % BUFSIZE;
            say(me, "Produced: ", num);
        } else {
            sem_post(&flag);
            sem_post(&full);
            return NULL;
        }
        sem_post(&flag);
        sem_post(&full);
    }
}


void *consumer(void* arg)
{

    int me = pthread_self();
    while (1) {
        sem_wait(&full);
        sem_wait(&flag);
        if (gOut <= gMax) {
            int item = extract();
            say(me, "Consumed: ", item);
            gOut = (gOut + 1) % BUFSIZE;
        } else {
            sem_post(&flag);
            sem_post(&empty);
            return NULL;
        }
        sem_post(&flag);
        sem_post(&empty);
    }
}

void checkInput(int argc, char* argv[]) {
    if (argc == 1) {
        NUMPROD = 1;
        NUMCONS = 1;
        return;
    }

    if (argc != 3) {
        printf("Specify <producers>  <consumer> \n");
        printf("Eg:  2  3 \n");
        exit(0);
    }

    NUMPROD = atoi(argv[1]);
    if (NUMPROD < 1 || NUMPROD > 10) {
        printf("Number of producers must lie in the range 1..10 \n");
        exit(0);
    }

    NUMCONS = atoi(argv[2]);
    if (NUMCONS < 1 || NUMCONS > 10) {
        printf("Number of consumers must lie in the range 1..10 \n");
        exit(0);
    }
}



int main(int argc, char* argv[])
{
    checkInput(argc, argv);

    pthread_t prod[NUMPROD];
    pthread_t cons[NUMCONS];

    sem_init(&flag,0,1);
    sem_init(&empty, 0, BUFSIZE);
    sem_init(&full,0,0);

    int conId[NUMCONS];

    for(int i = 0; i < NUMPROD; i++) {
        pthread_create(&prod[i], NULL, producer, NULL);
    }
    for(int i = 0; i < NUMCONS; i++) {
        conId[i] = pthread_create(&cons[i], NULL, consumer, NULL);
    }

    for(int i = 0; i < NUMPROD; i++) {
        pthread_join(prod[i], NULL);
    }

    for(int i = 0; i < NUMCONS; i++) {
        pthread_join(cons[i], NULL);
    }

    printf("Num Producers: %d  Num Consumer: %d \n", NUMPROD, NUMCONS);

    printf("All done! Hit any key to finish \n");
    getchar();

    return 0;

}