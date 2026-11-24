# User Guide

Start with [Construct values](construction.md) if you are preparing inputs.
This guide moves from operations on one value to elementwise operations
on vectors and functions of whole matrices.

## Scalar calculations

Use ordinary Julia arithmetic and functions with the extended types.
[Scalar operations](capabilities.md) summarizes available operations and
[Special Functions](special.md) covers Bessel, gamma, and other functions.

```@example scalar_functions
using DoubleFloats

x = df64"1e-20"
println("log1p(x) = ", string(log1p(x)))
println("expm1(x) = ", string(expm1(x)))
```

Use `log1p(x)` for `log(1 + x)` and `expm1(x)` for `exp(x) - 1`
when `x` is small. These scalar functions avoid rounding away the
small difference in the intermediate result. For a worked validation,
see [Choosing and checking precision](appropriate.md).

For `Double64`, `exp` overflows near an input of 709.78 and rounds
to zero near −745.13. The exponential kernels account for subnormal
rounding. Near a rounding midpoint they may use a higher-precision
fallback. A `Double32` result can have a subnormal low component
even when its high component is normal. The
[Accuracy Report](accuracy_report.md) shows when this absolute
rounding step dominates the relative working-precision score.
See the [Technical Guide](technicalguide.md#Elementary-function-algorithms)
for details and the [Benchmark Report](benchmark_report.md) for timings.

The faster Double64 and Double32 paths apply automatically in their
input ranges. Small Double64 `sinh` and `tanh` arguments use direct
approximations. Ordinary Double32 arguments can use a single Float64
evaluation when it retains the input's low component. See the
technical sections on [Double64](technicalguide.md#Faster-Double64-elementary-kernels)
and [Double32](technicalguide.md#Faster-Double32-elementary-kernels)
for the ranges and how these paths handle sensitive inputs.

## Elementwise operations on vectors

Ordinary Julia broadcasting applies a scalar function to each element.
Use `y = sin.(x)` to allocate a result, or `y .= sin.(x)` to write into
an existing array. For vector batches try `DoubleFloats.simdmap!`, which
reuses a destination and can use specialized kernels. It returns the
destination.

### Evaluate a batch of angles

The broadcast version produces one tuple per angle. The batch version
writes those tuples into a reusable vector. The grid uses exactly
representable binary fractions at its endpoints.

```@example evaluate_angles
using DoubleFloats

angles = Double64.(range(0.25, 2; length=4096))
reference = sincos.(angles)

pairs = Vector{Tuple{Double64,Double64}}(undef, length(angles))
DoubleFloats.simdmap!(sincos, pairs, angles)

max_error = maximum(zip(pairs, reference)) do (got, want)
    max(abs(got[1] - want[1]), abs(got[2] - want[2]))
end

@assert max_error < df64"1e-29"
println("Processed ", length(angles), " angles")
```

### Inputs, outputs, and execution order

The batch API takes one or two input vectors. Power also accepts a
single scalar exponent for the whole batch. With `angles` and `pairs`
from above, related calls include these.

```@example evaluate_angles
values = similar(angles)
other = reverse(angles)

DoubleFloats.simdmap!(^, values, angles, 5)
DoubleFloats.simdmap!(atan, values, angles, other)
DoubleFloats.simdmap!(hypot, values, angles, other)
DoubleFloats.simdmap!(DoubleFloats.normalize, pairs, angles, other)
nothing
```

Every vector must have the same axes (valid indices) as the destination.
A mismatch throws `DimensionMismatch` before any writes. The operation
uses elementwise indexing without broadcast expansion. Paired normalization stores one
`(x/h, z/h)` tuple per element for ordinary finite inputs, using the
pair's hypotenuse `h`. Assignment uses the destination's
usual conversion rules. For example, a `cis` call on a real NaN produces
a real NaN, which is then converted if the destination holds complex values.
Overlapping inputs, including exact in-place and shifted overlaps, are
read from their values at entry. Snapshots can
allocate. Custom vector storage also uses snapshots when overlap cannot be
ruled out.

By default the operation is serial. If a scalar call or assignment throws,
earlier elements have been written and later elements keep their original
values. Dense, disjoint `Double64`, `ComplexDF64`, and `Double32` vectors
can use SIMD for supported operations and input ranges. For example,
dense `Double32` input with angles between 0.125 and 0.5 radians can use
a native `tan` kernel.

```julia
angles32 = Double32.(range(0.125, 0.5; length=4096))
tangents = DoubleFloats.simdmap!(tan, similar(angles32), angles32)
```

Views, other precisions, unsupported result types, and out-of-range
blocks use scalar methods. A native kernel can round differently from
the scalar call because it uses a different evaluation formula.

Pass `threaded=true` to allow eligible operations to run on multiple Julia
threads. Run Julia with multiple threads, for example `julia -t 4`. Threading
requires sufficiently long, disjoint dense vectors and works for many
functions that use scalar arithmetic internally. Custom callables still
run in index order. If a worker fails, the call can raise a task exception
after other chunks have written to the destination. Keep the default
when the order of writes on failure matters.

See the [Technical Guide](@ref elementary-vector-kernels) for SIMD coverage
and measured performance.

## Work with matrices

Load `LinearAlgebra` for standard operations such as `norm`, `eigen`,
and matrix factorizations. Use `A \ b` to solve a system and `A * B`
for matrix multiplication.

A dot changes the operation. `exp.(A)` applies the scalar exponential
to each entry, while `exp(A)` computes the exponential of the matrix
using matrix algebra. For example, `exp.(A)` replaces every zero entry
with one, while the matrix exponential of a triangular matrix retains
its triangular structure. See [Linear Algebra](linearalgebra.md) for a
worked example and the supported function families.
