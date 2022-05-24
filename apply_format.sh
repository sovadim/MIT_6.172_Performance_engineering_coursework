#!/bin/bash

find lec* hw* -iname "*.h" -o -iname "*.c" | xargs clang-format -i
