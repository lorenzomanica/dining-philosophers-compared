
sequential:
	javac -s /src -d ./bin src/DiningPhilosophers.java

parallel1: 
	gcc -o bin/dpp1.o src/dpp1.c -lpthread


run-sequential: sequential
	java -cp ./bin DiningPhilosophers

run-parallel1: parallel1
	./bin/dpp1.o

run-parallel2: 
	go run src/dpp2.go

run-parallel3:
	java -cp ./lib/orc-2.1.2.jar:lib/\* orc.Main src/dpp3.orc

clean:
	rm ./bin/*.o ./bin/*.class

version:
	make -version
	ldd --version
	gcc --version
	java -version