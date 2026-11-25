# Accelerating matrix functions in DoubleFloats

Start with the polynomial products in triangular `log` and the blocked
triangular square root. Add a shared triangular multiply for `exp`,
the circular and hyperbolic functions, and fractional powers. Ship the
diagonal and half-power shortcuts as independent changes. Tune the
symmetric/Hermitian dispatch after those paths have their own benchmarks.

The initial native kernels target dense `Matrix{Double64}` and
`Matrix{ComplexDF64}`, including dense matrices with exact triangular
structure. Keep the public entry points in
[matfun.jl](../src/math/linearalgebra/matfun.jl) and
[matrixfunction.jl](../src/math/linearalgebra/matrixfunction.jl).
Check which methods Julia selects for structured wrappers separately.
The [Technical Guide](src/technicalguide.md) describes the current
matrix algorithms.

## Implementation record

- The triangular logarithm materializes the factor after its
  triangular solve for eligible inputs. For larger triangles the
  resulting polynomial uses the shared triangular multiply.
- The blocked square-root path uses 12-element blocks from size 96
  in the near-identity envelope. Rectangular updates pack views into
  a reused workspace. At 256×256 the complex root allocates about
  5.6 MB, down from about 52 MB in the initial blocked implementation
  with copied subblocks.
- The polynomial drivers share the triangular multiply across
  `exp`, the circular and hyperbolic families, and fractional powers.
  The real diagonal shortcut, guarded half-power route, and modest-norm
  symmetric selector are active in the public matrix methods. The
  small-norm real exponential also uses degree 15.
- General `sqrt` and `log` use complex Schur with a packed
  reconstruction for eligible factors. Real Schur, parallel dense
  multiplication, and the single reversed solves for `cot` and `coth`
  are described as follow-on candidates.

The [benchmark driver](../benchmark/studies/bench_matrix_functions.jl) reproduces
the fixtures. The [Technical Guide](src/technicalguide.md) records
the public-path timings and size thresholds.

## Evidence and rollout order

These are warmed prototypes on an Intel Core i9-14900K with Julia
1.10.10. The baseline for the matrix work was revision `9b4a13cf`.
The table uses one Julia thread and one BLAS thread. Some prototypes
time a candidate after its caller has established the input structure.
Measure the complete public call, including guards, before adopting a
route.

| Operation | Fixture | Current → prototype | Gain |
| --- | --- | ---: | ---: |
| Triangular `log` | 64×64 real | 15.58 → 4.22 ms | 3.69× |
| Triangular `log` | 64×64 complex storage | 36.53 → 11.62 ms | 3.14× |
| Triangular `sqrt` | 256×256 real | 29.44 → 7.10 ms | 4.14× |
| Triangular `sqrt` | 256×256 with nonzero imaginary entries | 65.26 → 18.35 ms | 3.56× |
| Triangular `exp` and `cos` | 256×256 real | 91.41 → 36.87 ms and 67.61 → 22.09 ms | 2.48× and 3.06× |
| `A^0.25` with faster triangular `log` and `exp` | 256×256 real | 1,043 → 253 ms | 4.12× |
| `A^0.5` using the existing `sqrt` | Same nonsingular real triangle | 1,036 → 29.44 ms | 35.2× |
| Dense diagonal `exp`, including the structure check | 64×64 real | 4,197 → 7.83 µs | 536× |
| Symmetric `exp`, `sin`, and `cos` | 64×64 real with one-norm about 0.8 | 10.24 → 2.45 ms, 13.07 → 2.54 ms, and 10.23 → 1.48 ms | 4.17×, 5.15×, and 6.90× |

Start from `MersenneTwister(0x328)` for each size. For triangular
`log`, generate a dense real normal matrix `R`, convert to `Double64`,
and form `triu(0.8I + 0.35R/opnorm(R, 1))`. Convert that fixture to
`ComplexDF64` for the complex-storage `log` comparison. For complex
`sqrt`, add an independent upper-triangular imaginary normal matrix
scaled by `0.02/n`. For the symmetric fixture, form `H = (R + R')/2`,
scale it to one-norm 0.3, and add `0.5I`. The diagonal fixture is the
dense diagonal of that `H`. Generate coefficients in the working type
and record their construction in the driver. Reproduce these fixtures
before using wider distributions.

Land the work in this order.

1. Speed up triangular `log` using dense products after its triangular
   solve. Measure Schur reconstruction independently.
2. Add blocked triangular `sqrt`, then reuse it in inverse scaling
   for `log`.
3. Add a private triangular multiply. Give each consuming function a
   separate admission decision.
4. Add the diagonal and half-power shortcuts in separate changes.
   They can land earlier when their compatibility tests pass.
5. Tune the symmetric/Hermitian selector. Treat general real Schur
   and parallel dense multiplication as follow-on work.

## Dispatch and numerical contract

- Keep the public signatures, square checks, input ownership, return
  shapes, and result types. Matrix functions return new results.
  Perform structural selection outside inner loops and carry the
  information through operations that preserve it. Keep unsupported
  storage and precisions on their existing routes. Preserve the
  `Double16` promotion and demotion used by `sqrt` and `log`.
- Recognize structure conservatively. A zero high limb alone is
  insufficient because the raw two-limb constructor can carry a
  nonzero low limb. For the initial structure checks, require both
  limbs of each skipped real component to be zero. Apply this to both
  components of complex entries. Use transpose to map a lower
  triangle to an upper triangle, including for complex inputs.
- Preserve existing branch choices and errors for singular, nonfinite,
  and borderline inputs. Capture representative results and exception
  indices before changing dispatch. A Julia 1.10.10 baseline check
  found different behavior for real and complex empty inputs. It also
  found NaN entries in the square root of a 2×2 complex zero matrix,
  whereas the real zero matrix returned zeros. Keep these cases on
  their existing paths during the acceleration.
- Use the same working precision and existing compensated transforms.
  Avoid `@fastmath`. Matrix products and blocked recurrences can
  change accumulation order. Compare against independent references
  and use the numerical criteria below. Check result type and
  principal-branch conventions separately from numerical tolerances.

## 1. Accelerate triangular `log`

In `_log_uppertri`, retain inverse scaling by repeated triangular
square roots. Keep the existing norm test, iteration cap, coefficients,
and rescaling in the first change. Continue to check zero diagonal
entries in the original order in public triangular and Schur callers.

1. Form `G = (T - I)/(T + I)` using the current triangular right
   solve. Materialize the solved factor once as a dense
   `Matrix{E}` at the chosen size crossover. Keep `G * G`,
   the Paterson–Stockmeyer products, and the final `G * S`
   on the existing dense SIMD multiplication path. Use the natural
   `Matrix` result type and preserve the existing `2^s` rescaling.
   Verify the product dispatch on each supported Julia version.
2. Apply the fast path after confirming the scaled factor has
   reached the ordinary near-identity regime and its intermediates
   are suitable for packed multiplication. If
   `opnorm(T - I, 1) <= 1/4`, the exact `opnorm(G, 1)` is at
   most `1/7` by the bound on the inverse of `2I + (T - I)`.
   Keep the current path when the iteration cap is reached outside
   that regime, when the factor is exceptional, or when the
   dense materialization costs more than the wrapper products.
   Record the same scaling count and check the final result on
   inputs near the norm cutoff. Reuse the final shifted matrix
   for the right solve when that saves a pass. The logarithm literature motivates
   preserving the inverse scaling and approximation as a unit.
   [Al-Mohy and Higham (2012)](src/references.md#al-mohy-and-higham-2012).
3. Benchmark Schur reconstruction as a separate change in
   `_matlog_schur` and `_matsqrt_schur`. Compare the existing
   lazy `Z'` with a single materialized `Matrix(adjoint(Z))`,
   routing the resulting products through the packed kernel.
   Include the copy, check complex conjugation, and keep
   `_strip_imag_dust` on the same public real-input paths. At
   64×64 the prototype gained about 7.7× in the transform alone
   and 1.36× end to end for general real `log` when combined with
   the faster triangular polynomial.

Measure dense products again after the triangular multiply lands.
Keep the faster option per size and type using the full `log` timing.

## 2. Block the triangular square root

Keep the point recurrence in `_sqrt_uppertri` as the leaf kernel and
fallback. On safely admitted triangles, partition into contiguous
diagonal blocks and compute each diagonal root with the point
recurrence. Fill block columns from left to right. Within column
`j`, visit block rows `i = j-1, ..., 1`. Use the already computed
blocks in the Sylvester equation

```text
R[i,i] * R[i,j] + R[i,j] * R[j,j]
    = T[i,j] - sum(R[i,k] * R[k,j] for k in i+1:j-1).
```

The right-hand update can be one rectangular product over the
intervening block indices. Use the packed dense kernel for that
product. This ordering makes both dependencies available when
solving each block.
[Deadman, Higham, and Ralha (2013)](src/references.md#deadman-higham-and-ralha-2013).

- Start with finite triangular inputs close to identity, for example
  a safely verified `opnorm(T - I, 1) <= 0.625`, with finite
  ordinary limbs. Compute the same scalar diagonal roots and verify
  that their real parts are bounded away from zero. This gives
  positive, separated real parts in sums of diagonal roots. Keep the
  point path for zero or near-cancelling denominators, branch cuts,
  extreme magnitudes, and unsafe intermediates. Check product and
  solve headroom before using unchecked kernels as the range widens.
- Reuse the triangular solve arithmetic in
  [sylvester.jl](../src/math/linearalgebra/sylvester.jl). The public
  Sylvester solver has a zero-denominator exception. Check block
  admission before invoking that helper, and discard private work
  and restart with the existing point route when a guard fails.
  Preserve the public Sylvester behavior if the helper is shared.
- Begin with block sizes 12, 24, and 32 and cover ragged blocks.
  Benchmark copying subblocks into dense work buffers against packing
  directly from views into reusable per-call storage. Benchmark the
  actual dispatch on rectangular products. Small blocks often need the
  point route. At 64×64 the prototypes gained only about 1.4–1.6×.
- After the public triangular paths pass, use the same blocked helper
  for the triangular factors inside `log` and complex Schur
  reconstruction. Check admissibility at each root step. Preserve
  the original scalar square-root branch and the norm stopping rule.
  Measure the gains together with the polynomial change.

## 3. Share triangular multiplication across functions

Add a private packed multiply in
[ddmatmul.jl](../src/math/linearalgebra/ddmatmul.jl).
Prove the operands are upper triangular at the matrix-function entry
point or know their structure from the preceding computation. Carry
that information through scaling, powers, polynomial sums, and
squaring. Keep the internal product separable from the public
`LinearAlgebra.mul!` dispatch.

- For two upper triangles, visit output columns `j`, then
  `k in 1:j`, and accumulate over contiguous rows `i in 1:k`.
  Use `_dd_fma_acc` and both stored limbs. Keep ascending `k`
  for each output entry, zero the lower triangle, and use disjoint
  destination and scratch buffers. Preserve the current complex
  product ordering when extending from the measured real kernel.
- Treat finite inputs and finite arithmetic as separate checks.
  Skipped zero products can affect exceptional results, and even
  finite operands can overflow a packed dot product. Use bounds on
  both limbs and on the number of products to leave headroom for
  each product, correction, and partial sum. Recheck newly produced
  operands when scaling or squaring can leave the bound. Route
  an unsafe product through the existing multiply if its inputs
  are still valid. Restart the matrix function from the original
  input when a branch or intermediate-result guard fails.
  Include all guards and repacking in the benchmark.
- Parameterize the product inside the existing polynomial
  evaluators and doubling loops, or share a private helper that
  gives the same coefficient and multiplication order. Start with
  `exp` and `cos`, then measure `cosh`, `sin`, `sinh`,
  and `sincos`. The pair driver should still compute its power
  stack once. Keep the small and unsupported cases on the measured
  faster path. Measure the crossovers between triangular packed,
  dense packed, and wrapper-based products.
- When the cosine or cosh factor is safely invertible, compare
  triangular right division for `tan` or `tanh` with the existing
  solve. Keep the existing route near poles and when conditioning
  or error behavior is uncertain. The combined prototypes gained
  about 1.5× at 256×256. Treat `cot` and `coth` as separate
  candidates. Replacing the inverse of a quotient with one reversed
  solve requires both original factors and the original quotient to
  be safe, with equivalent singular behavior.
- Let the existing `exp(p * log(A))` route for noninteger powers
  benefit from both accelerated stages. Prove that both stages
  retain triangular structure before selecting their multiply.
  Preserve the overloads, exponent conversion, and realification in
  [matrixfunction.jl](../src/math/linearalgebra/matrixfunction.jl).

## 4. Admit diagonal and half-power shortcuts

For dense diagonal inputs, check square shape and capture the empty
case before attempting structure detection. Start with finite real
diagonals of ordinary magnitude. Evaluate the scalar function at
each diagonal entry and allocate the dense result once, with exact
off-diagonal zeros. The scalar evaluations are linear in matrix size.
Structure detection and dense result construction still do quadratic
work.

Start with `exp`, the circular and hyperbolic pairs and their single
members, and strictly positive `sqrt` and `log`. For paired outputs
preserve each result matrix type and component order. Measure the
structure check on nondiagonal inputs with the first nonzero at early
and late positions. Extend to complex values only after verifying
scalar branch choices, complex output, and realification for the
corresponding public overload. Keep nonfinites and branch-sensitive
diagonals on their original paths. Preserve the first singular index
for `log` and powers with zero diagonal entries.

For `A^0.5`, begin in the real matrix/real exponent overload.
Recognize exact one-half in the working type after the existing
exponent conversion, including a zero low limb. Use `sqrt(A)`
only for finite, nonsingular triangular matrices with safely positive
diagonal and bounded intermediates. Validate consistency with the
current principal-branch result on that envelope, including its return
type. Send singular matrices through the current logarithm route so
`SingularException` and its index are preserved. Treat semidefinite
matrices, negative real spectrum, complex exponents, and nearby
exponents as separate cases. Test values immediately on either side
of one-half in the low limb.

## 5. Choose a symmetric/Hermitian route

Keep diagonal detection ahead of the symmetric/Hermitian selector.
For dense, exactly symmetric `Double64` inputs of modest norm,
compare the polynomial path with the existing eigendecomposition
for `exp`, `sin`, `cos`, `sinh`, `cosh`, and `sincos`.
Use the existing `_matexp`, `_mat_pair`, and `_mat_even`
drivers. Count products and doublings for each operation. A shared
pair is useful for `sincos`, while `cos` and `cosh` already
have a cheaper even-only path.

Start near the measured one-norm of 0.8. Use size, type, and a
conservative bound on the scaling steps to choose the route. Reuse
the norm in the selected driver. Sweep small matrices, modest and
large norms, and matrices with cancellation in individual output
entries. The polynomial choice needs independent forward-accuracy
checks. Check complex Hermitian inputs separately before enabling
them. Preserve the spectral routes for `sqrt` and `log` and their
domain checks in this stage. For functions that still use
`matrixfunction`, an orthonormal Hermitian reconstruction with
one function evaluation per eigenvalue is a separate candidate.
Retain callback and complex-return behavior when testing it.

## Follow-on work

A lower-degree polynomial for very small-norm dense `exp` measured
2.0× at 64×64 on a fixture with one-norm about 0.0055. Evaluate degree
15 as a separate change. For degree `d` and a conservative one-norm
bound `η`, bound the Taylor tail by
`exp(η) * η^(d+1) / factorial(d+1)`. Leave margin for rounding and
any later squaring. A four-thread dense exponential prototype measured
2.1× at 256×256. If threading is pursued, partition disjoint output
columns or tiles, preserve each accumulation order, and measure
scheduling, packing, nested calls, and compilation. Tune the thread
crossover separately from the matrix size crossover.

A real Schur factorization at 64×64 was about 3.8× faster than the
complex factorization alone. A real matrix-function path must retain
the 1×1 and 2×2 diagonal blocks of the upper quasi-triangular factor.
Use branch-aware block evaluation and Sylvester solves, including
for the repeated roots and the right solve in `log`. Reconstruct
with the real orthogonal factor. Validate near-coalescing conjugate
pairs, separation from the closed negative real axis, and cases
that need complex results. Use the existing complex Schur path when
block or branch admission fails. Measure the entire public call
before enabling real Schur.
[Al-Mohy, Higham, and Relton (2013), §6](src/references.md#al-mohy-higham-and-relton-2013).

## Correctness and performance acceptance

Extend [matrix-function tests](../test/matrixfunctions.jl) and
[multiplication tests](../test/matmul.jl). Record dispatch, type,
shape, exact preserved structure, error type and index, and input
ownership. Cover empty and nonsquare inputs, scalar-sized matrices,
both triangle orientations, real and complex storage, existing
precision promotions, nearly triangular matrices, and raw
zero-headed entries with a nonzero low limb. Include repeated and
clustered eigenvalues, defective Jordan blocks, nonnormal strictly
triangular parts, singular and near-singular diagonals, both sides
of the negative real axis, repeated zero roots, large norms, and
nonfinite limbs.

- Use analytic diagonal and nilpotent Jordan fixtures and independent
  high-precision references. For small matrices near identity,
  construct the `BigFloat` input from the two limbs and evaluate
  convergent reference series for `log` and `sqrt`. For the entire
  functions use a separate high-precision series with a remainder
  bound on admitted norms. Use a closed form or a validated block
  reference for branch-sensitive fixtures.
- Record both forward error against the reference and residuals.
  For `sqrt` use `opnorm(R*R - A, 1)` scaled by the input and
  root norms. For `log` check the exponential residual and the
  branch separately. A round trip can agree for more than one
  branch. Check normwise and componentwise error on well-conditioned
  cases, using absolute error when a reference element is near
  zero. Compare with the existing path at the same precision and
  account for conditioning on difficult fixtures. Set fixture
  tolerances from the working precision, product count, and
  reference conditioning before selecting performance thresholds.
  Include a
  fixture that actually enters each fast path and one that
  exercises its fallback.
- Run the full suite on Julia 1.10 and a current supported Julia.
  Compare on a second CPU target where available. Confirm that
  fallback behavior and ordinary dense multiplication survive
  helper extraction.

Add a repeatable driver in [perf](../perf/). Save measurements at the
implementation baseline and compare identical fixtures with the new
public calls. Include n = 0, 1, 16, 32, 64, 128, 256, and a larger
case, plus sizes around each crossover and block boundary. Benchmark
positive and complex diagonals, upper and lower triangles, symmetric
and general matrices, varying norms, and paths that fail structural
or numerical guards. Use separate stage measurements for factorization,
triangular solve, products, reconstruction, and allocations.

Keep matrix creation, correctness checks, and scratch resets outside
timed regions. Include structure scans, required copies, packing,
and output allocation in end-to-end timings. Use repeated interleaved
measurements and record median, spread, allocations, first-call time,
revision, Julia version, CPU and target, seed, input shape, and Julia
and BLAS thread counts. Admit each route only where its full public
call improves repeatably and passes the numerical checks. Retain a
measured size or norm threshold where the existing route is faster.
After each admitted change, update the [User Guide](src/userguide.md),
[Technical Guide](src/technicalguide.md), and
[Linear Algebra guide](src/linearalgebra.md) with the actual coverage
and checked performance.
