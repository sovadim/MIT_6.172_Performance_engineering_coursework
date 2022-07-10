# High Performance in Dynamic Languages

**Dynamic languages for interactive math**

The two-language approach:

High-level dynamic language for productivity\
\+ low-level language (C, Fortran, Cython,...) for performance-critical code.\
= Huge jump in complexity, loss of generality.

**Julia**

As high-level and interactive as Matlab ot Python+IPython,\
as general-purpose as Python,\
as productive for technical work as Matlab or Python+SciPy,\
but as fast as  C.

**Special Functions in Julia**

Pure Julia ```erfinv(x)```\
3-4x faster than Matlab's and 2-3x faster than SciPy's.

Pure Julia ```polygamma(m, z)```\
2x faster than Scipy's for real z

Julia code can be faster than typical optimized C code,
by using techniques (metaprogramming/codegen) that are
hard in a low-level language.

// Here was a lot of demonstration in jupyter
