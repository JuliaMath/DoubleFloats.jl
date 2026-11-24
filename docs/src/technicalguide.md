# Technical Guide

How DoubleFloats represents numbers and which algorithms sit behind the
public functions.  For guidance on extending the package, see
[Adding New Functions](addingfunctions.md).

## Representation: unevaluated sums

A `DoubleFloat{T}` holds two floats, `hi` and `lo`, whose *unevaluated
sum* is the represented value:

```
value = hi + lo,   with   |lo| ≤ ulp(hi)/2
```

`hi` is the value rounded to `T`; `lo` is the leading part of the
rounding error.  For `Double64` this yields a 106-bit significand
(2 × 53), about 32 decimal digits, with one ulp ≈ `2⁻¹⁰⁴` relative.

Two structural consequences matter throughout the package:

- **The exponent range is that of `T`.**  Overflow and underflow happen
  where `Float64` overflows and underflows.
- **Precision degrades near the bottom of the range.**  When
  `|value| < ~4e-292`, the `lo` word is subnormal and the effective
  precision tapers below 106 bits; below `~1e-308` only `Float64`
  precision remains.  This is a *representation* limit — visible, for
  example, in `exp(x)` for `x < -670` — and no algorithm returning a
  `Double64` can beat it.

## Error-free transformations

All arithmetic reduces to a handful of exact building blocks
(`src/math/errorfree.jl`):

- `two_sum(a, b)` / `two_hilo_sum(a, b)`: `hi + lo == a + b` exactly.
- `two_prod(a, b)`: `hi + lo == a * b` exactly, using `fma`.
- Division and square root use these plus one Newton-like correction
  (`src/math/ops/`), giving faithfully rounded (≤ 1 ulp) results.

A subtlety worth knowing: a **zero `lo` word does not mean a value is
exact**, and no fast path may skip the correction step because of it
(`inv` once did, and silently returned `Float64`-quality reciprocals for
inputs like `Double64(3.0)`).

## Elementary function algorithms

**Exponential functions** (`src/math/elementary/explog.jl`). The shared
base-2 kernel reduces the exponent to `n + 8r` with `|r| ≲ 1/16`.
It evaluates a tapered polynomial for `2^r` using fused Horner steps,
squares three times, and reconstructs with a split power-of-two scale.
`exp` and `exp10` use three-limb base conversion on the native path.

Inputs safely below the zero-rounding threshold bypass the polynomial.
In the underflow band, both reduced limbs contribute to rounding on the
target format's subnormal grid. If the error bound overlaps a rounding
midpoint, the fallback evaluates the original input with directed MPFR
rounding and increases precision until the bounds agree. An exact input
sum lets one downward evaluation and its next representable MPFR value
bound an inexact result. The fallback compiles on first use. Ordinary
`Double32` calls to `exp` promote through `Double64`, with direct
rounding to the `Float32` grid in the underflow band.

**Logarithms**. The `log2` kernel decomposes a positive input into an
exponent and a mantissa. It uses 32 exact table centers `c` and a
polynomial in `t²`, where `t = (m-c)/(m+c)` for mantissa `m`.
Near one it uses `t = (x-1)/(x+1)` directly to preserve the small
result. The table path rescales tiny inputs and checks both source and
destination exponent fields before adjusting the low limb's exponent.
This matters even when the low limb starts out normal. `log` and
`log10` convert the `log2` result to their respective bases.

**`log1p` and `expm1`**. Near zero, `log1p` uses
`log(1+x) = 2·atanh(x/(2+x))`. `expm1` evaluates a Taylor series on
a scaled argument and reconstructs with the doubling identity
`expm1(2t) = expm1(t)·(expm1(t) + 2)`.

**Cube root and fused multiply-add**. Scalar `cbrt` returns a
`DoubleFloat`. For extreme `Double64` inputs it scales both limbs by
`2^(-3k)` before Newton refinement and scales the root by `2^k`
afterward. This keeps intermediate products in range and retains the
input's low-limb contribution at working precision. Near cancellation,
`fma` and `muladd` for three `Double64` operands refine the result
with an allocation-free expansion. Its tuple capacity grows one slot
at a time as product and addend terms are inserted.

**Trigonometric functions** (`trig.jl`): argument reduction by `mod2pi`,
then circle-splitting into `[0, π/32]` segments with tabulated
`sin`/`cos` anchor values and short Taylor kernels.  Reductions near the
roots (`x - π/2`, `x - π`) carry a triple-double π so cancellation does
not eat the low word.  Branch windows must be *bounded*: each Taylor
kernel is only valid for `|r| ≤ π/32`.

**Hyperbolics**: from `exp(±x)`; `sinh`/`cosh` switch to a `Float128`
route above 709 where `exp` alone would overflow although they remain
finite (through `ln(2·floatmax) ≈ 710.476`).

**Inverse hyperbolics** (`archyptrig.jl`): formulated to keep relative
precision at their sensitive points, and to avoid squaring overflow:

| function | small/near-1 form | large-argument form (`≥ 4/eps`) |
|:---------|:------------------|:--------------------------------|
| `asinh` | `log1p(x + x²/(1+√(1+x²)))` | `log(x) + ln2` |
| `acosh` | `log1p(u + √(u(2+u)))`, `u = x-1` exact | `log(x) + ln2` |
| `atanh` | `½·log1p(2x/(1-x))` | `½·(log1p(x) - log1p(-x))` for `x > ½` |

`acsch`, `asech`, `acoth` delegate with exactly-formed intermediates
(e.g. `acoth = ½·log1p(2/(x-1))`), never through a bare `inv(x)` where
that would lose `1/x - 1`.

**agm / ellipk** (`src/math/special/`): the AGM iteration stops when the
gap `|a-b|` *stops shrinking* — its quadratic convergence ends exactly at
the roundoff floor — rather than testing a fixed tolerance, which cannot
be chosen correctly in advance for all operand scales.

**erf, erfc, gamma, Bessel**: computed via `Float128` (Quadmath), whose
113-bit significand slightly exceeds `Double64` working precision.

## [Elementary vector kernels](@id elementary-vector-kernels)

The [User Guide](userguide.md#Elementwise-operations-on-vectors) describes
`DoubleFloats.simdmap!`, including axes, overlapping inputs, and exceptions.
The driver checks storage and element types once per call. The batch kernels
reuse the scalar coefficients and error-free transforms without reassociation
or `@fastmath`. They operate on the ordinary interleaved arrays of high and
low limbs.

For a native route, the driver checks both limbs in 32-element blocks,
or 64-element blocks for operations with sparse repair. The intervals
below bound the high word. The low word must be
finite and at most half the high word's binade ulp in magnitude. The
bounds leave room for the low limb and nested intermediate operations.
Vectors shorter than 64 elements take the scalar path.

| Input type and operations | Native ranges and result |
|:---|:---|
| `Double64` `exp2` | Heads on −1021 to −0.001 or 0.001 to 1023, where the high word of the result stays normal. |
| `Double64` `exp`, `exp10` | Absolute head from 0.001 to 32, with three-limb base conversion. |
| `Double64` `log2`, `log`, `log10` | Direct regime strictly between 15/16 and 17/16. Table regime at or above `2^-915` outside the direct interval, up to the largest finite head. |
| `Double64` `log1p`, `expm1` | `log1p` on 0.005–0.05. `expm1` uses four doublings on 0.032–0.06 and ordinary exponential subtraction when the absolute head is 0.5–32. |
| `Double64` power | Scalar `Int` exponent `5` with bases on 0.5–1.5, or vector `Double64` exponents on 0.2–0.9 with bases on 1.1–1.5. |
| `Double64` `sin`, `cos`, `tan`, `sincos`, `cis` | Absolute head from 0.005 to 0.09 radians. `sincos` writes a tuple, `cis` writes a complex number. |
| `Double64` `cot`, unary `atan` | Positive heads on 0.005–0.09 and 0.005–0.19, respectively. |
| `Double64` hyperbolic functions | `sinh`, `cosh`, `tanh`, `csch`, `sech`, and `coth` on 1.1–5. |
| `Double64` inverse hyperbolic functions | `asinh` on 0.005–0.045, `acosh` on 1.00002–1.001, `atanh` on 0.005–0.025, `acsch` on 30–50, `asech` on 0.999–0.99998, and `acoth` on 40–100. |
| `ComplexDF64` `square`, `abs2`, `exp`, `sinh`, `cosh` | Real head on 1.1–5 and imaginary head on 0.005–0.09. `abs2` writes a real result. |
| `ComplexDF64` `sin`, `cos`, `tan`, `cot`, `DoubleFloats.csc`, `DoubleFloats.sec` | Imaginary head on 1.1–5. Real head on 0.005–0.09 for `sin` and `cos`, or 0.005–0.045 for the other four. |
| `ComplexDF64` `tanh`, `coth`, `csch`, `sech` | Real head on 1.1–5 and imaginary head on 0.005–0.045. |

Mixed blocks normally use the scalar loop, which preserves exception
order. For `exp2`, `sin`, `cos`, and `tan`, a block with at most one eighth
of its lanes excluded can SIMD-evaluate safe substitute inputs and then
repair those lanes with the original scalar calls. This requires every
excluded input to pass a wider check that makes the scalar calls and
assignments safe. Blocks containing a potential domain error go through
the scalar loop before any element of the block is written.

The pi-scaled trig functions, binary `atan` and `DoubleFloats.atanxy`,
and the inverse circular functions other than unary `Double64` `atan`
use the existing scalar algorithms inside the batch. The same applies
to complex `sqrt`, `log`, and the inverse complex functions. This preserves
special values, signed zeros, argument quadrants, and complex branch cuts.
Threaded calls use contiguous chunks. Most supported operations are
eligible from 4,096 elements, and integer power from 65,536 elements.

### Batch benchmarks

The table reports median microseconds per 4,096 elements from 11 interleaved
measurements. It uses the bounded fixtures in `perf/bench_simd_elementary.jl`,
seed `0x5eed`, Julia 1.13.3, and native AVX2/FMA targeting on an Intel Core
i9-14900K. The baseline is preallocated scalar broadcast from revision
`d68a1c0c`. The batch column includes dispatch and lane checks.

| Operation | Baseline broadcast (µs) | Serial batch (µs) | Speedup |
|:---|---:|---:|---:|
| `sin` | 135.0 | 34.5 | 3.9× |
| `sincos` | 149.7 | 41.4 | 3.6× |
| Unary `atan` | 375.4 | 79.5 | 4.7× |
| `exp2` | 112.9 | 34.7 | 3.3× |
| Fixed-binade `expm1` | 360.0 | 93.9 | 3.8× |
| Table `log` | 110.9 | 33.1 | 3.3× |
| Power with scalar exponent `5` | 41.9 | 5.9 | 7.1× |
| `ComplexDF64` `exp` | 430.6 | 71.2 | 6.0× |

These batch runs used zero heap allocations after compilation. LLVM's
native-target output showed loop vectorization across elements in the
admitted kernels. Julia 1.10.10 with the Haswell target used scalar loops
for some of the same compositions, including tuple-output `sincos` and
vector-exponent power. Performance depends on the compiler and target.
With 1% shuffled out-of-window inputs, sparse repair gave 2.2–2.7×
over scalar broadcast for `sin`, `cos`, `tan`, and `exp2`. The same
fixtures gave 1.4–1.6× when entire mixed blocks used the scalar loop.
Clustered exclusions leave more eligible blocks intact. Fully excluded
fixtures ran near scalar speed. In the separate Julia 1.10.10 exponential
tests, zero-only `exp2` was about 0.9× and MPFR midpoint repair took
about 9.7 ms for 4,096 elements in both the scalar and serial batch runs.
On a general-range run with 65,536 elements per case, the median across
all 71 cases was 1.0× for serial batching and 2.0× with four workers
relative to scalar broadcast. A caller-managed threaded scalar loop
also gave 2.0× on that run.

Run the driver from the package root. Its output includes the measured
range, storage, seed, Julia and CPU versions, CPU target, thread count,
revision, median and spread, allocations, and first-use time. For a
pre-change comparison, run the same driver with `--baseline` and the
older checkout as the active project.

```sh
julia --project -t4 perf/bench_simd_elementary.jl
SIMD_RANGE=general SIMD_SIZE=65536 julia --project -t4 perf/bench_simd_elementary.jl
SIMD_MIXTURE=0,0.01,0.1,0.5,1 SIMD_FILTER='^(sin|exp2|log)$' \
    julia --project perf/bench_simd_elementary.jl
```

Set `SIMD_CLUSTERED=1` for clustered mixtures, `SIMD_LOG_REGIMES=1` for
repeated table indices and direct/table mixtures, or `SIMD_RANGE=special`
for poles, exponential underflow, and MPFR midpoint repair. The driver
also supports comma-separated sizes, `SIMD_STORAGE=strided`, `narrow`, or
`alias`, alternative whole-block widths via `SIMD_BLOCK_SIZES`, and native
IR dumps into the directory given by `SIMD_LLVM`.

## Linear algebra

LAPACK covers only `Float32/64` and their complexes, so DoubleFloats
routes dense factorizations through pure-Julia generic implementations:

- `lu`, `qr`, `\`: LinearAlgebra's generic kernels.
- `eigen`, `eigvals`, `schur`, `hessenberg`: GenericSchur (QR iteration).
  DoubleFloats owns explicit `eigen`/`eigvals` methods
  (`src/math/linearalgebra/eigen.jl`) that pin this routing, detect
  hermitian input (tridiagonalization + symmetric QR: real eigenvalues,
  orthonormal vectors), and normalize output conventions to match the
  LAPACK route (real `Eigen` for a real spectrum, `(real, imag)` sorting,
  unit-norm vectors).
- `svd`: GenericLinearAlgebra.
- `sylvester`/`lyap` (`sylvester.jl`): Bartels–Stewart — Schur
  factorizations of both operands, triangular back-substitution,
  transform back.
- `lq`: the generic Householder QR of the adjoint, repackaged as an
  `LQ` factorization (`A = L·Q ⟺ A′ = Q_qr·R`), with the missing
  `LQPackedQ` materialization/multiplication kernels supplied for
  DoubleFloat element types.

## Matrix functions

`src/math/linearalgebra/matfun.jl`; all correct for defective matrices:

- **exp**: scaling-and-squaring; scale to `‖A‖₁ ≤ 1`, a 34-term Taylor
  approximant (truncation < 1/35! ≈ 1e-40) evaluated by
  Paterson–Stockmeyer (≈ 11 matrix products), then repeated squaring.
  Real input never leaves real arithmetic.
- **sqrt**: complex Schur + the Björck–Hammarling recurrence on the
  triangular factor; hermitian-PSD input shortcuts through `eigen`.
- **log**: complex Schur + inverse scaling-and-squaring — repeated
  triangular square roots until `‖T - I‖₁ ≤ ¼`, then the atanh series
  (re-using `inv_oddint`), then multiply by `2^s`.
- **trig/hyperbolic**: one shared-power series pair in `Y = B²` plus
  double-angle recurrences (`cos(2X) = 2cos²X - I`, `sin(2X) = 2 sin X cos X`
  — and the *same* formulas for cosh/sinh), entirely in the input's
  arithmetic, so real matrices never touch complex intermediates.
- **hermitian input** (exact `ishermitian`) short-circuits exp, trig, and
  hyperbolic functions through one symmetric eigen-decomposition — the
  orthonormal eigenvectors make that transform perfectly conditioned.
- **triangular input** skips the Schur factorization entirely for
  `sqrt`/`log` (the recurrences apply directly; `tril` maps to `triu`
  through the transpose identity).
- Real results that acquire ~`1e-32` imaginary roundoff dust from a
  complex intermediate are stripped back to real (with a tolerance
  guard), matching LAPACK-route behavior.

`cbrt`, `sinpi`/`cospi`, and matrix inverse-trig/hyperbolic functions
still use eigen-diagonalization (`matrixfunction`), which requires a
diagonalizable argument and loses accuracy in proportion to `cond(V)`.
