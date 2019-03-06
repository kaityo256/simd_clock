all: a.out avx2.out avx512.out
CC=icpc
CC=g++
CPPFLAGS=-O3 -xHOST
CPPFLAGS=-O3

a.out: test.cpp
	$(CC) $(CPPFLAGS) test.cpp -o $@

avx2.out: test.cpp
	$(CC) $(CPPFLAGS) -mavx2 test.cpp -DAVX2 -o $@

avx512.out: test.cpp
	$(CC) $(CPPFLAGS) test.cpp -mavx512f -DAVX512 -o $@

.PHONY: run clean

run:
	perf stat ./a.out 2> xmm.txt
	perf stat ./avx2.out 2> ymm.txt
	perf stat ./avx512.out 2> zmm.txt

clean:
	rm -f a.out avx2.out avx512.out
