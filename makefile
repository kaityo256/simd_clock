all: a.out avx2.out avx512.out
CC=icpc
CPPFLAGS=-O3 -xHOST

a.out: test.cpp
	$(CC) $(CPPFLAGS) test.cpp -o $@

avx2.out: test.cpp
	$(CC) $(CPPFLAGS) test.cpp -DAVX2 -o $@

avx512.out: test.cpp
	$(CC) $(CPPFLAGS) test.cpp -DAVX512 -o $@

.PHONY: run clean

run:
	perf stat ./a.out
	perf stat ./avx2.out
	perf stat ./avx512.out

clean:
	rm -f a.out avx2.out avx512.out
