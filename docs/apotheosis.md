# DoubleFloats at its best

DoubleFloats is most valuable when a small correction carries a
large part of the answer. Its high word carries the scale of a
number, and its low word carries information that ordinary
floating-point arithmetic might discard. The strongest realization
of the package would make that extra information easy to preserve
from input through result, easy to verify where it matters, and
inexpensive where the algorithm can safely take a shorter route.

This perspective shifts the unit of comparison from the function
call to the numerical task. How long does it take to produce an
answer that meets the application's accuracy and domain
requirements? A ratio against `Float64` describes the cost of a
call. It describes the cost of competing solutions only when both
calls contribute to an acceptable answer.

## What the current package already does

`Double64`, `Double32`, and `Double16` store pairs of `Float64`,
`Float32`, and `Float16` words, respectively. Decimal string
literals and the usual Julia arithmetic let users keep extra
precision without changing the structure of a calculation.
The component format sets the exponent scale, and spacing
changes near underflow. Precision selection therefore involves
both the significant digits the calculation needs and the range
of its intermediate values. [Representation](src/technicalguide.md#Representation-as-an-unevaluated-sum)

| Level | Current realization | Strongest realization |
| --- | --- | --- |
| Scalar | Function-specific guards select shorter reductions, local approximations, or wider intermediates. For selected `Double32` functions, the `Float64) route requires the sum of the two input words to survive conversion exactly. | Explain accuracy by input regime, including the origin of the input, cancellation around roots, and the representable grid at the range limits. |
| Vector | `DoubleFloats.simdmap!` selects kernels using the operation, storage, size, and inputs. Some native `Double32` batches have different rounding from scalar calls. | Show which workloads benefit and what agreement users can expect. Measure homogeneous and mixed inputs, including the overhead of guards and fallback. |
| Matrix | Dedicated methods exploit diagonal, triangular, and symmetric structure. The generic `matrixfunction(f, A)` uses eigendecomposition and requires a diagonalizable matrix. | Present structure, branch, and conditioning as part of the problem. Judge the result with a branch-sensitive reference or a residual appropriate to the matrix function. |

The scalar and vector distinction already matters in practice.
On one matched dense `Double32` fixture, `tanh` took 8.57 ns
per element on the scalar route and 3.17 ns on the batch route.
The sampled maximum rose from 0.139 to 0.518 in the report's
relative working-precision units. With scattered replacements,
the speedup fell from 2.70× to 1.70×. These results describe the
tested distributions and machine. A workload with a different
mix of inputs can reach a different balance, and a sampled
maximum supplies evidence for the tested inputs. [Matched comparison](src/multifulcrum.md)

## A correction that changes the problem

Consider a two-equation system. Its exact solution is `[1, 2]`.
The second equation distinguishes the two unknowns through a
coefficient increment of `2^-60`. Converting the coefficients
and right-hand side to `Float64` rounds that increment away
and produces a singular system. Constructing the data in
`Double64` retains the increment.

```julia
using DoubleFloats, LinearAlgebra

d = Double64(0x1p-60)
u = one(Double64)
A = [u u; u u + d]
b = [Double64(3), Double64(3) + 2d]
x = A \ b

A64, b64 = Float64.(A), Float64.(b)
@assert A64 == ones(2, 2) && b64 == [3.0, 3.0]

setprecision(BigFloat, 256) do
    Aref, bref, xcomputed = BigFloat.(A), BigFloat.(b), BigFloat.(x)
    residual = norm(bref - Aref * xcomputed, Inf)
    forward_error = norm(xcomputed - BigFloat[1, 2], Inf)
    @show residual forward_error
end
```

Both checks give zero for this constructed example. The residual
checks the equations for the supplied data. The forward error
checks the answer against the known solution. In general, a
small residual can coexist with a large forward error when the
matrix is ill-conditioned. This system is deliberately sensitive
to perturbations, so the example shows the importance of
retaining the input perturbation. If the coefficient is already
rounded to `1.0` when it reaches the package, widening it
preserves that rounded value. [Choosing and checking precision](src/appropriate.md)

## What would make the difference visible

The existing guards show how to specialize an operation while
keeping a general route available. The next step would be to
apply that discipline at the level of an entire calculation.
For example, a solver could retain the original coefficients,
try a cheaper factorization when it is usable, and recompute the
residual in higher precision. It could refine the solution
when the correction solves converge and use a wider
factorization when they fail. In the example above the narrow
factorization is singular, so the first viable factorization
needs the retained coefficient increment. When forward error is
the requirement, the residual check also needs a conditioning
estimate or an independent reference.

The current guides explain how to call the methods, and the
reports describe measured accuracy and speed. A few complete
workloads could connect those pieces. Each would state the
tolerance and domain, construct the inputs at the intended
precision, compare viable routes, and check the result
independently.

- **For a scalar correction,** show the effect of input rounding
  separately from function evaluation. Near a zero, choose an error
  measure meaningful for the application's output. At underflow,
  compare absolute error and zero or nearest-grid agreement.
  [Accuracy Report](src/accuracy_report.md)
- **For a batch,** compare scalar and vector routes on the same
  data and include representative outliers and layouts. Report
  elapsed time alongside error and output agreement. Include
  allocation or copying when the application pays for it.
  [Vector API](src/userguide.md#Elementwise-operations-on-vectors)
- **For a matrix,** preserve known structure and check the intended
  branch. For instance, a small residual for `X * X = A` alone
  cannot identify the principal square root. Use a trusted
  reference when the forward error or branch is in question.
  [Matrix domains and branches](src/linearalgebra.md#Supported-domains-and-branches)

For a given task, the decisive comparison is elapsed time among
routes that meet its numerical requirements. Count conversion,
fallback, and any checks paid for in production. Use a wider
reference while validating a workload, and time it as part of
the route if it also runs in production. The package's strongest
claim is that it can preserve decisive low-order information
inside ordinary Julia code, with specialized arithmetic where
the workload justifies it and evidence that lets users judge
the result.
