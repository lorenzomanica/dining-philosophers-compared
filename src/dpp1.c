#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>

/* number of philosophers */
#define N 5
/* number of i’s left neighbor */
#define LEFT (i+N-1)%N
/* number of i’s right neighbor */
#define RIGHT (i+1)%N 			
/* philosopher is thinking */
#define THINKING 0 			    
/* philosopher is trying to get forks */
#define HUNGRY 1 			    
/* philosopher is eating */
#define EATING 2 			    

#define ROUNDS 10
/* array to keep count how many times one have eaten */
int rounds[N];

bool finish = false;

/* array to keep track of everyone’s state */
int state[N];

/* mutual exclusion for critical regions */
sem_t mutex; 			

/* one semaphore per philosopher */
sem_t s[N]; 			    


typedef struct {
    int index;
} thread_arg, *ptr_thread_arg;


void think()
{
    usleep(3000000);
}

void eat()
{
    usleep(1000000);
}


/* i: philosopher number, from 0 to N−1 */
void test(int i) 			        
{
    if (state[i] == HUNGRY && state[LEFT] != EATING && state[RIGHT] != EATING) {
        state[i] = EATING;
        sem_post(&s[i]);
    }
}


/* i: philosopher number, from 0 to N−1 */
void take_forks(int i) 			
{
    /* enter critical region */
    sem_wait(&mutex);           
    /* record fact that philosopher i is hungry */    
    state[i] = HUNGRY; 			
    /* try to acquire 2 forks */
    test(i);                    
    /* exit critical region */
    sem_post(&mutex);               
    /* block if forks were not acquired */  
    sem_wait(&s[i]);                
}


/* i: philosopher number, from 0 to N−1 */
void put_forks(int i)               
{
    /* enter critical region */
    sem_wait(&mutex);           
    /* philosopher has finished eating */
    state[i] = THINKING; 		
    /* see if left neighbor can now eat */
    test(LEFT);                 
    /* see if right neighbor can now eat */
    test(RIGHT);                
    /* exit critical region */
    sem_post(&mutex);           
}


/* i: philosopher number, from 0 to N−1 */ 
void philosopher(int i) 		
{
    /* repeat forever */
    while (rounds[i]<ROUNDS) {
        /* philosopher is thinking */
        think(); 			    
        /* acquire two forks or block */
        take_forks(i); 			
        /* yum-yum, spaghetti */
        eat();   	
        rounds[i]++;
        /* put both forks back on table */
        put_forks(i);           
    }
}


void * philosopher_task(void * arg) 
{
    ptr_thread_arg p_arg = (ptr_thread_arg)arg;
    philosopher(p_arg->index);
}


void * watcher_task(void * arg) {
    while (true)
    {
        char * str = malloc(4*N*sizeof(char));
        int i;
        int finished = N;
        for (i=0; i<N; i++) {
            char val[4];
            sprintf(val, "%d ", rounds[i]);
            strcat(str, val);
            if (rounds[i]==ROUNDS)
                finished--;
        }
        printf("%s\n", str);
        if (finished==0)
            return 0;
        usleep(10000);
    }
}

int main()
{
    sem_init(&mutex, 0, 1);

    pthread_t thread[N+1];
    thread_arg args[N+1];

    int i;
    for (i=0; i<N+1; i++)
    {
        state[i] = THINKING;
        args[i].index = i;
        if (i==N)
            pthread_create(&(thread[N]), NULL, watcher_task, &(args[i]));
        else
            pthread_create(&(thread[i]), NULL, philosopher_task, &(args[i]));

    }

    for (i=0; i<N+1; i++)
    {
        pthread_join(thread[i], NULL);
    }

    return 0;
}