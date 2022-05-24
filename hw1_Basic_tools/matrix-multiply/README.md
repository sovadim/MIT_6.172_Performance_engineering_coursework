## Debugging matrix_multiply

```bash
$ gdb --args ./matrix_multiply
(gdb) run
(gdb) p A->values[i][k]
(gdb) p B->values[k][j]
(gdb) p B->values[k]
```

## Build in debug mode

```bash
$ make DEBUG=1
```

## Build with ASAN

```bash
$ make ASAN=1
```

## Running with valgrind

```bash
$ valgrind ./matrix_multiply -p
$ valgrind --leak-check=full ./matrix_multiply -p
```

## Coverage

```bash
$ make DEBUG=1
$ ./matrix_multiply -p
$ llvm-cov gcov testbed.c
$ llvm-cov gcov matrix_multiply.c
```
