
sequential:
	javac -s /src -d ./ src/DiningPhilosophers.java

parallel1: 
	gcc -o dpp1.o src/dpp1.c -lpthread


run-sequential: sequential
	java DiningPhilosophers

run-parallel1: parallel1
	./dpp1.o

run-parallel2: 
	go run src/dpp2.go

clean:
	rm *.o

version:
	make -version
	ldd --version
	gcc --version
	java -version