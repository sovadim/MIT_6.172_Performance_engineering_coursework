// Copyright (c) 2012 MIT License by 6.172 Staff

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void print_size(char* type, size_t size) {
    printf("size of %s : %zu bytes \n", type, size);
}

int main() {
    // Please print the sizes of the following types:
    // int, short, long, char, float, double, unsigned int, long long
    // uint8_t, uint16_t, uint32_t, and uint64_t, uint_fast8_t,
    // uint_fast16_t, uintmax_t, intmax_t, __int128, and student

    // Here's how to show the size of one type. See if you can define a macro
    // to avoid copy pasting this code.
    print_size("int", sizeof(int));
    print_size("short", sizeof(short));
    print_size("long", sizeof(long));
    print_size("char", sizeof(char));
    print_size("float", sizeof(float));
    print_size("double", sizeof(double));
    print_size("unsigned int", sizeof(unsigned int));
    print_size("long long", sizeof(long long));
    print_size("uint8_t", sizeof(uint8_t));
    print_size("uint16_t", sizeof(uint16_t));
    print_size("uint32_t", sizeof(uint32_t));
    print_size("uint64_t", sizeof(uint64_t));
    print_size("uint_fast8_t", sizeof(uint_fast8_t));
    print_size("uint_fast16_t", sizeof(uint_fast16_t));
    print_size("uintmax_t", sizeof(uintmax_t));
    print_size("intmax_t", sizeof(intmax_t));
    print_size("__int128", sizeof(__int128));
    // e.g. PRINT_SIZE("int", int);
    //      PRINT_SIZE("short", short);

    // Alternatively, you can use stringification
    // (https://gcc.gnu.org/onlinedocs/cpp/Stringification.html) so that
    // you can write
    // e.g. PRINT_SIZE(int);
    //      PRINT_SIZE(short);

    // Composite types have sizes too.
    typedef struct {
        int id;
        int year;
    } student;

    student you;
    you.id = 12345;
    you.year = 4;


    // Array declaration. Use your macro to print the size of this.
    int x[5];

    // You can just use your macro here instead: PRINT_SIZE("student", you);
    printf("size of %s : %zu bytes \n", "student", sizeof(you));

    return 0;
}
