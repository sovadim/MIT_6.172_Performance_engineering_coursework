# python3 matrix_mult.py

import random
from time import *

n = 4096

A = [[random.random() for row in range(n)] for col in range(n)]
B = [[random.random() for row in range(n)] for col in range(n)]
C = [[random.random() for row in range(n)] for col in range(n)]

start = time()

for i in range(n):
    for j in range(n):
        for k in range(n):
            C[i][j] += A[i][k] * B[k][j]

end = time()

print("%0.6f" % (end - start))  # Running time is supposed to be about 6 hours


"""

2n^3 = 2(2^12)^3 = 2^37 floating-point operations
Running time = 21042 seconds
Python gets 2^37 / 21041 ~ 6.25 MFLOPS

"""
