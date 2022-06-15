#!/bin/bash

# C++
find lec* hw* proj* -iname "*.h" -o -iname "*.c" -o -iname "*.cpp" | xargs clang-format -i

# Python
python3 -m black .
