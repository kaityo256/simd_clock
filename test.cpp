#include <cstdio>
#include <iostream>
#include <x86intrin.h>

const int N = 100000;
const int M = 1000;
__attribute__((aligned(64))) double z[N] = {};

void func(){
  for(int i=0;i<N;i++){
    z[i] = z[i] * z[i] + z[i];
  }
}

void func_avx2(){
  for(int i=0;i<N;i+=4){
    __m256d zi = _mm256_load_pd(z+i);
    zi = zi * zi + zi;
    _mm256_store_pd(z+i, zi);
  }
}

void func_avx512(){
  for(int i=0;i<N;i+=8){
    __m512d zi = _mm512_load_pd(z+i);
    zi = zi * zi + zi;
    _mm512_store_pd(z+i, zi);
  }
}

int main(){
  for(int i=0;i<M;i++){
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
