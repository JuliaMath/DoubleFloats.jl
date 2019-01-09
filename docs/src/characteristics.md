This package provides extended precision versions of `Float64`, `Float32`, `Float16`.

| type name   | significand precision | exponent precision | | base type |significand precision  | exponent precision |
|:------------|:---------------------:|:------------------:|-|:----------|:---------------------:|:------------------:|
| `Double64`  | 106 bits              | 11 bits            |◊| `Float64` | 53 bits               | 11 bits            |
| `Double32`  | &nbsp;48 bits         | &nbsp;8 bits       |◊| `Float32` | 24 bits               | &nbsp;8 bits       |
| `Double16`  | &nbsp;22 bits         | &nbsp;5 bits       |◊| `Float16` | 11 bits               | &nbsp;5 bits       |

----

- arithmetic (`+`, `-`, `*`, `/`) is exact
- elementary functions are quite accurate
- often better than C "double-double" libraries

----

For `Double64` arguments within 0.0..2.0   
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _except tan(x), cot(x) as they approach ±Inf_
- expect the `abserr` of elementary functions to be 1e-30 or less
- expect the `relerr` of elementary functions to be 1e-28 or less

When used with reasonably sized values, expect computations to limit the accrual of relative error to 10⋅𝘂²
(where 𝘂 is the relative rounding unit, the unit_in_the_last_place of the significand, often `eps(x)/2`).

It is possible to accrue relative error steadily; so some experimentation has guided algorithmic selection.
A sequence of 100_000 arithmetic and elementary functions may evince a relative error of 100_000 * 10⋅𝘂²,
this is a conservative bound and reasonably unlikely.
