.PHONY: fib_pthreads fib_tbb clean

fib_pthreads:
	clang fib_pthreads.c -o fib_pthreads

fib_tbb:
	clang++ -std=c++20 -ltbb fib_tbb.cpp -o fib_tbb

fib_omp:
	clang++ -std=c++20 fib_omp.cpp -o fib_omp

# Set up:
# - Download OpenCilk binaries
# - Export CILK_PATH to OpenCilk directory
# - Download, build and install cilkrts
fib_cilk:
	${CILK_PATH}/bin/clang++ -std=c++20 -fcilkplus fib_cilk.cpp -o fib_cilk

clean:
	rm -f fib_pthreads fib_tbb fib_omp fib_cilk
