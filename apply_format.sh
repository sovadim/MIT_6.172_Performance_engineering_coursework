#!/bin/bash

# C++
find lec* hw* -iname "*.h" -o -iname "*.c" | xargs clang-format -i

# Python
python3 -m black .
