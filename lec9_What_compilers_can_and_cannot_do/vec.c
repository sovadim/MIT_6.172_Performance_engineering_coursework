#include <stdio.h>

typedef struct vec_t
{
    double x, y;
} vec_t;

static vec_t vec_add(vec_t a, vec_t b)
{
    vec_t sum = {a.x + b.x, a.y + b.y};
    return sum;
}

static vec_t vec_scale(vec_t v, double a)
{
    vec_t scaled = {v.x * a, v.y * a};
    return scaled;
}

static double vec_length2(vec_t v)
{
    return v.x * v.x + v.y * v.y;
}

int main()
{
    vec_t v1 = {0.1, 0.1};
    vec_t v2 = {0.2, 0.2};

    v1 = vec_add(v1, v2);
    v1 = vec_scale(v1, 2.0);
    v1.y = vec_length2(v1);

    printf("%lf %lf\n", v1.x, v1.y);
    printf("%lf %lf\n", v2.x, v2.y);
}
