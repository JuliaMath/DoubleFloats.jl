This package provides versions of the standard floating point types with extended precision significands.

| type name   | significand precision | exponent precision | base type |
|:------------|:---------------------:|:------------------:|:----------|
| `Double64`  | 106 bits              | 11 bits            | `Float64` |
| `Double32`  | &nbsp;48 bits         | &nbsp;8 bits       | `Float32` |
| `Double16`  | &nbsp;22 bits         | &nbsp;5 bits       | `Float16` |


- arithmetic (`+`, `-`, `*`, `/`) is exact
- elementary functions are quite accurate
- often better than C "double-double" libraries

----

For Double64 arguments within 0.0..2.0   
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; _except tan(x), cot(x) as they approach ±Inf_
- expect the `abserr` to be 1e-30 or less
- expect the `relerr` to be 1e-28 or less

