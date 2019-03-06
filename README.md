# Frequency Behavior of Intel Xeon with SIMD instructions

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

## Summary

This is a sample program to see frequency behavior of Intel Xeon with SIMD instructions.

## Source code

```cpp
#include <cstdio>
#include <iostream>
#include <x86intrin.h>

const int N = 100000;
const int M = 1000;
__attribute__((aligned(64))) double z[N] = {};

void func() {
  for (int i = 0; i < N; i++) {
    z[i] = z[i] * z[i] + z[i];
  }
}

#ifdef AVX2
void func_avx2() {
  for (int i = 0; i < N; i += 4) {
    __m256d zi = _mm256_load_pd(z + i);
    zi = zi * zi + zi;
    _mm256_store_pd(z + i, zi);
  }
}
#endif

#ifdef AVX512
void func_avx512() {
  for (int i = 0; i < N; i += 8) {
    __m512d zi = _mm512_load_pd(z + i);
    zi = zi * zi + zi;
    _mm512_store_pd(z + i, zi);
  }
}
#endif

int main() {
  for (int i = 0; i < M; i++) {
#ifdef AVX2
    func_avx2();
#elif AVX512
    func_avx512();
#else
    func();
#endif
  }
  std::cout << z[0] << std::endl;
}
```

## Build

The make command will build three executables, a.out, avx2.out, and avx512.out.

```sh
$ make
g++ -O3 test.cpp -o a.out
g++ -O3 -mavx2 test.cpp -DAVX2 -o avx2.out
g++ -O3 test.cpp -mavx512f -DAVX512 -o avx512.out
```

* a.out: Scalar code which uses xmm registers.
* avx2.out: Vector code which uses ymm registers.
* avx512.out: Vector code with uses zmm registers.

## Run

Check CPU frequency by `perf stat` as follows.

### Results on Haswell

```sh
$ cat /proc/cpuinfo
(snip)
model name      : Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
(snip)

$ perf stat ./a.out > /dev/null
 Performance counter stats for './a.out':

         57.371825 task-clock                #    0.313 CPUs utilized          
                38 context-switches          #    0.001 M/sec                  
                 4 CPU-migrations            #    0.000 M/sec                  
               697 page-faults               #    0.012 M/sec                  
       143,495,653 cycles                    #    2.501 GHz                    
     <not counted> stalled-cycles-frontend 
     <not counted> stalled-cycles-backend  
       411,911,565 instructions              #    2.87  insns per cycle        
        52,327,950 branches                  #  912.084 M/sec                  
            35,480 branch-misses             #    0.07% of all branches        

       0.183278008 seconds time elapsed

$ perf stat ./avx2.out > /dev/null
 Performance counter stats for './avx2.out':

         46.727693 task-clock                #    0.966 CPUs utilized          
                 9 context-switches          #    0.000 M/sec                  
                 1 CPU-migrations            #    0.000 M/sec                  
               697 page-faults               #    0.015 M/sec                  
       116,928,370 cycles                    #    2.502 GHz                    
     <not counted> stalled-cycles-frontend 
     <not counted> stalled-cycles-backend  
       179,479,778 instructions              #    1.53  insns per cycle        
        25,854,681 branches                  #  553.305 M/sec                  
            22,254 branch-misses             #    0.09% of all branches        

       0.048377394 seconds time elapsed
```

The CPU frequency dose not change.

### Results on Skylake

```sh
$ cat /proc/cpuinfo
(snip)
model name      : Intel(R) Xeon(R) Gold 6148 CPU @ 2.40GHz
(snip)

$ perf stat ./a.out > /dev/null

 Performance counter stats for './a.out':

         36.122388      task-clock:u (msec)       #    0.982 CPUs utilized          
                 0      context-switches:u        #    0.000 K/sec                  
                 0      cpu-migrations:u          #    0.000 K/sec                  
               797      page-faults:u             #    0.022 M/sec                  
       105,645,056      cycles:u                  #    2.925 GHz                    
       403,004,071      instructions:u            #    3.81  insn per cycle         
        50,496,983      branches:u                # 1397.941 M/sec                  
            17,250      branch-misses:u           #    0.03% of all branches        

       0.036802222 seconds time elapsed

$ perf stat ./avx2.out > /dev/null

 Performance counter stats for './avx2.out':

         23.364917      task-clock:u (msec)       #    0.938 CPUs utilized          
                 0      context-switches:u        #    0.000 K/sec                  
                 0      cpu-migrations:u          #    0.000 K/sec                  
               797      page-faults:u             #    0.034 M/sec                  
        55,886,823      cycles:u                  #    2.392 GHz                    
       178,004,119      instructions:u            #    3.19  insn per cycle         
        25,496,983      branches:u                # 1091.251 M/sec                  
            17,252      branch-misses:u           #    0.07% of all branches        

       0.024910654 seconds time elapsed

$ perf stat ./avx512.out > /dev/null 

 Performance counter stats for './avx512.out':

         23.689379      task-clock:u (msec)       #    0.941 CPUs utilized          
                 0      context-switches:u        #    0.000 K/sec                  
                 0      cpu-migrations:u          #    0.000 K/sec                  
               797      page-faults:u             #    0.034 M/sec                  
        48,138,632      cycles:u                  #    2.032 GHz                    
        78,004,148      instructions:u            #    1.62  insn per cycle         
        12,996,993      branches:u                #  548.642 M/sec                  
            17,461      branch-misses:u           #    0.13% of all branches        

       0.025174319 seconds time elapsed
```

You can see that the CPU frequency decreases as the width of the SIMD register increases.

## License

The source codes in this repository are licensed under [the MIT License](https://opensource.org/licenses/MIT).