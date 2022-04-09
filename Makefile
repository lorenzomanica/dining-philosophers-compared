
parallel1: 
	gcc -o dpp1.o src/dpp1.c -lpthread

run-parallel1: parallel1
	./dpp1.o

clean:
	rm *.o

version:
	make -version
	ldd --version
	gcc --version