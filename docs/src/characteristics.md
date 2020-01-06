# Characteristics

This package provides extended precision versions of `Float64`, `Float32`, `Float16`.

----

| type name  | significand | exponent | ◊ | base type | significand | exponent |
|:-----------|:-----------:|:--------:|:-:|:----------|:-----------:|:--------:|
| `Double64` |  106 bits   | 11 bits  | ◊ | `Float64` |   53 bits   | 11 bits  |
| `Double32` |   48 bits   |  8 bits  | ◊ | `Float32` |   24 bits   |  8 bits  |
| `Double16` |   22 bits   |  5 bits  | ◊ | `Float16` |   11 bits   |  5 bits  |

## Representation


> `Double64` is a magnitude ordered, nonoverlapping pair of `Float64`
>
> `Double32` is a magnitude ordered, nonoverlapping pair of `Float32`
>
> `Double16` is a magnitude ordered, nonoverlapping pair of `Float16`

- (`+`, `-`, `*`) are error-free, (`/`, `sqrt`) are least-error
- elementary functions are quite accurate
    - often better than C "double-double" libraries

----

> `ComplexDF64` is a (real, imag) pair of `Double64`
>
> `ComplexDF32` is a (real, imag) pair of `Double32`
>
> `ComplexDF16` is a (real, imag) pair of `Double16`

- elementary functions are quite accurate
    - functions and their inverses round-trip well

----
## Accuracy

For `Double64` arguments within 0.0..2.0

- expect the `abserr` of elementary functions to be 1e-30 or better
- expect the `relerr` of elementary functions to be 1e-28 or better

----

When used with reasonably sized values, expect successive DoubleFloat ops to add no more than 10⋅𝘂²
to the cumulative relative error (𝘂 is the relative rounding unit, usually `𝘂 = eps(x)/2`).
Relative error can accrue steadily. After 100,000 DoubleFloat ops with reasonably sized values,
the `relerr` could approach 100,000 * 10⋅𝘂². In practice these functions are considerably
more resiliant: our algorithms come frome seminal papers and extensive numeric investigation.

----

### Absolute and Relative Error



results for f(x), x in 0..1
 

| function |   abserr   |   relerr   |
|:--------:|:----------:|:----------:|
|   exp    |  1.0e-31   |   1.0e-31  |
|   log    |  1.0e-31   |   1.0e-31  |
|          |            |            |
|   sin    |  1.0e-31   |   1.0e-31  |
|   cos    |  1.0e-31   |   1.0e-31  |
|   tan    |  1.0e-31   |   1.0e-31  |
|          |            |            |
|  asin    |  1.0e-31   |   1.0e-31  |
|  acos    |  1.0e-31   |   1.0e-31  |
|  atan    |  1.0e-31   |   1.0e-31  |
|          |            |            |
|   sinh   |  1.0e-31   |   1.0e-29  |
|   cosh   |  1.0e-31   |   1.0e-31  |
|   tanh   |  1.0e-31   |   1.0e-29  |
|          |            |            |
|  asinh   |  1.0e-31   |   1.0e-29  |
|  atanh   |  1.0e-31   |   1.0e-30  |


results for f(x), x in 1..2
 

| function |   abserr   |   relerr   |
|:--------:|:----------:|:----------:|
|   exp    |  1.0e-30   |   1.0e-31  |
|   log    |  1.0e-31   |   1.0e-31  |
|          |            |            |
|   sin    |  1.0e-31   |   1.0e-31  |
|   cos    |  1.0e-31   |   1.0e-28  |
|   tan    |  1.0e-30   |   1.0e-30  | 
|          |            |            |
|  atan    |  1.0e-31   |   1.0e-31  |
|          |            |            |
|   sinh   |  1.0e-30   |   1.0e-31  |
|   cosh   |  1.0e-30   |   1.0e-31  |
|   tanh   |  1.0e-31   |   1.0e-31  |
|          |            |            |
|  asinh   |  1.0e-31   |   1.0e-31  |
