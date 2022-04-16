package main

import (
	"hash/fnv"
	"log"
	"math/rand"
	"os"
	"time"
)

// Number of philosophers is simply the length of this list.
// It is not otherwise fixed in the program.
var ph = []string{"Aristotle", "Kant", "Spinoza", "Marx", "Russell"}
var it = []int{0, 0, 0, 0, 0}

const hunger = 10                    // number of times each philosopher eats
const think = 500 * time.Millisecond // mean think time
const eat = 100 * time.Millisecond   // mean eat time

var fmt = log.New(os.Stdout, "", 0) // for thread-safe output

var done = make(chan bool)

// This solution uses channels to implement synchronization.
// Sent over channels are "forks."
type fork byte

// A fork object in the program models a physical fork in the simulation.
// A separate channel represents each fork place.  Two philosophers
// have access to each fork.  The channels are buffered with capacity = 1,
// representing a place for a single fork.

// Goroutine for philosopher actions.  An instance is run for each
// philosopher.  Instances run concurrently.
func philosopher(id int, phName string,
	dominantHand, otherHand chan fork, done chan bool) {
	// each philosopher goroutine has a random number generator,
	// seeded with a hash of the philosopher's name.
	h := fnv.New64a()
	h.Write([]byte(phName))
	rg := rand.New(rand.NewSource(int64(h.Sum64())))
	// utility function to sleep for a randomized nominal time
	rSleep := func(t time.Duration) {
		time.Sleep(t/2 + time.Duration(rg.Int63n(int64(t))))
	}
	for h := 0; h < hunger; h++ {
		rSleep(think)
		<-dominantHand // pick up forks
		<-otherHand
		rSleep(eat)
		it[id] = it[id] + 1
		dominantHand <- 'f' // put down forks
		otherHand <- 'f'
	}
	done <- true
}

func watcher() {
	for {
		fmt.Printf("%d %d %d %d %d ", it[0], it[1], it[2], it[3], it[4])
		time.Sleep(50 * time.Millisecond)
	}
}

func main() {
	// Create fork channels and start philosopher goroutines,
	// supplying each goroutine with the appropriate channels
	go watcher()

	place0 := make(chan fork, 1)
	place0 <- 'f' // byte in channel represents a fork on the table.
	placeLeft := place0
	for i := 1; i < len(ph); i++ {
		placeRight := make(chan fork, 1)
		placeRight <- 'f'
		go philosopher(i, ph[i], placeLeft, placeRight, done)
		placeLeft = placeRight
	}
	// Make one philosopher left handed by reversing fork place
	// supplied to philosopher's dominant hand.
	// This makes precedence acyclic, preventing deadlock.
	go philosopher(0, ph[0], place0, placeLeft, done)
	// they are all now busy eating
	for range ph {
		<-done // wait for philosphers to finish
	}
}
