# Apothecary

The design archetype for DoubleFloats 2.0. It melds the reviewed assessment
(`apotheosis_fable52.md`) with the client experience
(`apotheosis_from_fable52.md`) into one specification: what the package
promises, what the client sees, how it is built, and how each claim is
checked. Where this document and those two differ, this one governs.

## 0. How to use this document

- **Normative sections** (§3–§10) say what 2.0 does. Each rule carries the
  defects it resolves and the property that tests it.
- **Rulings** (§2) are the choices that belonged to the arbiter. All are
  made; each records what was chosen and what was rejected.
- **The work plan** (§11) lists items by stage with the files they touch.
- **The ledger** (§12) is every verified defect with its remedy and stage.

Every defect cited was reproduced on package version 1.13.3 with Julia
1.13.3. Every code sketch marked *verified* was executed against the
package and behaved as stated. Items marked *confirm* rest on recollection
of the literature or on platforms not available here, and must be checked
before they are published.

Notation: `F` is the underlying float type and `p` its precision (53 for
`Float64`). `u = 2^-p` is the unit roundoff. `ε_D = 4u²` is the working unit
(`2^-104` for `Double64`, `2^-46` for `Double32`). `RN` is round-to-nearest.
`Δ` is the least positive subnormal of `F`.

## 1. Paradigm

`Double64` is a number type that carries a contract. Each operation states
what it guarantees, on which inputs, by which route, with what evidence.
That statement is one object in the source. Dispatch, tests, the manual, and
the benchmarks all read it.

Four laws follow.

1. **One invariant.** Every value a client can hold is normalized.
2. **`Base` is the interface.** Everything true of `Float64` in generic
   Julia code is true of `Double64`, or the difference is documented and
   throws rather than misleads.
3. **Every claim has a tier.** Exact, proved, or sampled; never unlabelled.
4. **One source per fact.** A range, bound, or route appears once in the
   source and is generated everywhere else.

## 2. Rulings

### 2.1 Made

| # | Ruling |
|:--|:--|
| R1 | Everything ships in 2.0. The 1.x line receives no changes from this plan. |
| R2 | Display changes (digits, compact form, `repr`) ship in 2.0 with the rest. |
| R3 | `Float128` leaves the core one function at a time (was D6). `string`, `sinpi`, and `cospi` are replaced unconditionally. Every other replacement kernel ships only if it passes the gate of §8.1; a kernel that misses stays on `Float128` in 2.0, tier `sampled`, with the 113-bit precondition stated. Quadmath becomes a weak dependency when the last such kernel passes, in 2.0 or a later 2.x. |
| R4 | The minimum Julia is 1.12 (was D11), set in `Project.toml`. `public` is used directly, with no version guard. Releases after 1.13.3 are not offered to Julia 1.10 or 1.11. |
| R5 | Branch model (D14 of `apothic.md`): `release-1.13` is cut from the present default branch, and the default branch becomes `2.0.0-DEV`. |
| R6 | The source tree is rearranged first (D15), as `move` commits proved bit-identical by the golden corpus, so every later change lands in its final file. |
| R7 | The pair constructor writes `lo = 0` when the sum is non-finite (D16). No function may read the low word of a non-finite value; D1 is unaffected. |
| R8 | Every remaining recommendation is accepted (2026-11-25): D1–D5, D7–D10, D12, and D13 are ruled at the option the table of §2.2 lists as chosen. |

### 2.2 Ruled by question

No ruling is open. The sections below cite these by their D numbers. The
last column names the items each one governs.

| # | Question | Chosen | Rejected alternative | Affects |
|:--|:--|:--|:--|:--|
| D1 | Low word of a non-finite value | Ignored: only `hi` is read | Canonical `lo = hi`, enforced on every result | §3.2, W1.2 |
| D2 | Raw pair constructor | Internal `unsafe_double`; `Double64(hi, lo)` normalizes | Keep raw and public, document the hazard | §3.3, W1.3 |
| D3 | Promotion | Never narrows, including `Double64` with `Float128` | Keep present rules | §4.4, W1.8 |
| D4 | `repr` of a scalar | `df64"…"`, bare digits inside typed containers | Bare digits everywhere, as `BigFloat` | §5.1, W2.2 |
| D5 | Compact display | Six significant digits of the value | Present behaviour: all digits of the head | §5.1, W2.3 |
| D6 | Quadmath on core paths | Ruled: see R3 | | §8.1, W4.1–W4.5 |
| D7 | Linear algebra packaging | Extension, with error hints | GenericLinearAlgebra and GenericSchur stay hard dependencies | §8.2, W4.6 |
| D8 | Implicit broadcast fast path | Ship only for kernels proved bit-identical to scalar | Explicit `simdmap!` only | §7, W4.8 |
| D9 | Unicode operators `⊕ ⊖ ⊗ ⊘` | `public`, not exported | Keep exported | §9 |
| D10 | `Double16` | Supported as "computed in `Double64`", stated in the manual | Remove the type | §9, W3.7 |
| D11 | Minimum Julia | Ruled: see R4 | | W1.10, W3.5 |
| D12 | Deprecated names | Kept through 2.x with `depwarn`, removed in 3.0 | Removed at 2.0 | §9 |
| D13 | Sample sizes | 10⁶ per scalar route in the report job, 10⁴ in CI | Other | §6.3 |

R3 bounds the largest cost in the plan: each of W4.1 and W4.3–W4.5 either
passes its gate or is deferred without blocking 2.0.

## 3. The value

### 3.1 Representation

`DoubleFloat{F}` is an immutable pair `(hi, lo)` of `F <: IEEEFloat`. A
finite value is the exact sum `hi + lo`, and is **normalized** when

```math
\mathcal{N}(hi, lo):\quad hi = \mathrm{RN}(hi + lo).
```

Normalization implies `|lo| ≤ ulp(hi)/2`. It does not fix the precision:
the low word may sit far below the high word, so a normalized pair can
carry more than `2p` bits. `precision(Double64) = 106` is the guaranteed
minimum for values at or above `floatmin_full`.

### 3.2 Special values

| Value | Stored | Rule |
|:--|:--|:--|
| `±0` | `(±0.0, 0.0)` | The sign is the sign of `hi` |
| `±Inf` | `hi = ±Inf`, `lo` unspecified | Only `hi` is read (D1); the constructor writes `lo = 0` (R7) |
| `NaN` | `hi = NaN`, `lo` unspecified | Only `hi` is read (D1); the constructor writes `lo = 0` (R7) |

Today `Double64(Inf)` stores `(Inf, Inf)` and `floatmax(Double64) * 2`
stores `(Inf, 0.0)` (F17). Under D1 both are valid and indistinguishable
through any public function. Clients who serialize words must not compare
non-finite values bitwise; the manual says so.

### 3.3 Constructors

| Form | Behaviour |
|:--|:--|
| `DoubleFloat(hi::F, lo::F)`, `Double64(hi, lo)` | Normalize with `two_sum`, except that a zero low word leaves the pair as given (so `-0.0` survives) and a high word that is not finite is the value, with the low word stored as zero. Bit-for-bit identity on a normalized pair, checked by the golden corpus. |
| `DoubleFloat{F}(x::Real)` | Exact if representable, else correctly rounded pair: `hi = F(x)`, `lo = F(x − hi)` evaluated exactly |
| `unsafe_double(F, hi, lo)` | Internal. No check. For kernels that have established `𝒩`. |
| `isnormalized(x)` | Public predicate |

One generic method replaces the per-type copies in `src/Double.jl`. For
`Integer` and `Rational` arguments the subtraction `x − hi` is carried out
in integer or rational arithmetic, so `Double64(2^62 + 1)` and
`Double64(typemax(Int64))` are exact (F4). The nested-type methods
(`DoubleFloat{Double32}`) are deleted: no constructor produces the type and
`convert` to it overflows the stack (F11).

### 3.4 Reflection

| Function | 2.0 value for `Double64` | Note |
|:--|:--|:--|
| `precision(T)` | 106 | Guaranteed minimum |
| `eps(T)` | `2^-104` | Unchanged |
| `eps(x)`, `ulp(x)` | Spacing of the stored pair | Unchanged; depends on `lo` by design |
| `floatmin(T)` | `2^-1022` | Smallest normal head; precision already reduced |
| `floatmin_full(T)` | `2^-969` | New, public: `floatmin(F) · 2^p` |
| `floatmax(T)` | Unchanged | |

Derivation of `floatmin_full`: a value with leading bit `2^e` has its 106th
bit at `2^(e−105)`, representable in `Float64` only when `e − 105 ≥ −1074`.
The Technical Guide (about `4e-292`) and the Accuracy Report (`2^-970`) are
brought to this one value (F5).

## 4. The Base contract

### 4.1 Equality, order, hash

Reference definitions (*verified* on NaN, signed zeros, both infinity
forms, and adjacent values; `sort` then orders
`[-1, -0.0, 0.0, 1/3, 1, Inf, NaN]` correctly):

```julia
Base.:(==)(x::DoubleFloat{F}, y::DoubleFloat{F}) where {F} =
    (x.hi == y.hi) & ((x.lo == y.lo) | !isfinite(x.hi))

Base.isequal(x::DoubleFloat{F}, y::DoubleFloat{F}) where {F} =
    isequal(x.hi, y.hi) & ((x.lo == y.lo) | !isfinite(x.hi))

Base.isless(x::DoubleFloat{F}, y::DoubleFloat{F}) where {F} =
    isless(x.hi, y.hi) | (isequal(x.hi, y.hi) & isfinite(x.hi) & (x.lo < y.lo))

Base.:(<)(x::DoubleFloat{F}, y::DoubleFloat{F}) where {F} =
    (x.hi < y.hi) | ((x.hi == y.hi) & isfinite(x.hi) & (x.lo < y.lo))
```

All four are branch-free. Resolves F13 (`NaN == NaN`), F14 (`isless`,
`isequal`, `sort`).

Mixed comparison is exact. Against `IEEEFloat` and `Integer`, widen the
other operand exactly and compare pairs. Against `Rational` and `BigFloat`,
compare exact values (for `Rational`: cross-multiply the exact numerator
from `decompose`). Resolves F15.

`decompose` is exact (F16). Sketch, *verified*: with it, the hash below
agrees with the hash of the exact `BigFloat` value on positive, negative,
sparse, extreme, zero, and non-finite inputs, and with `Rational`. The sign
is carried by the third element, as `Base.decompose` does:

```julia
function Base.decompose(x::DoubleFloat)
    isfinite(x.hi) || return Base.decompose(x.hi)
    iszero(x.lo)   && return Base.decompose(x.hi)
    n1, p1, s1 = Base.decompose(x.hi)
    n2, p2, s2 = Base.decompose(x.lo)
    q = min(p1, p2)
    n = s1 * (big(n1) << (p1 - q)) + s2 * (big(n2) << (p2 - q))
    return abs(n), q, sign(n)
end
```

Hash:

```julia
Base.hash(x::DoubleFloat, h::UInt) =
    (iszero(x.lo) | !isfinite(x.hi)) ? hash(x.hi, h) :
                                        invoke(hash, Tuple{Real,UInt}, x, h)
```

The fast arm covers every value equal to an `F`; the slow arm allocates a
`BigInt` and is reached only by values no `Float64` equals. Resolves F1.

**Property P-ORD.** For all pairs drawn from finite, zero, infinite, NaN,
subnormal, and adjacent values, across `DoubleFloat`, `Float64`, `BigFloat`,
`Rational`, `Int`: `==`, `<`, `isless`, `isequal` agree with the same
operation on exact values, and `isequal(a, b) ⇒ hash(a, h) == hash(b, h)`.

### 4.2 Conversion out

| Call | Rule | Resolves |
|:--|:--|:--|
| `Float64(x)`, `Float32(x)` | Correctly rounded | Already true for `Double64` |
| `BigFloat(x)` | Exact, at precision sufficient for the pair | |
| `Int64(x)`, `convert(Integer, x)` | Exact, or `InexactError` | C1 |
| `round(Int, x)`, `trunc`, `floor`, `ceil` | The rounding forms | |
| `rationalize(x; tol = eps(x))` | Honours `tol` | C11 |
| `Rational(x)` | Exact, via `decompose` | F16 |

### 4.3 Parsing

```julia
function Base.tryparse(::Type{DoubleFloat{F}}, s::AbstractString; base::Integer = 10) where {F}
    prec = max(4 * precision(F) + 64, ceil(Int, ncodeunits(s) * log2(base)) + 64)
    b = tryparse(BigFloat, s; base, precision = prec)
    b === nothing ? nothing : DoubleFloat{F}(b)
end
```

- `parse` is `tryparse` or `ArgumentError`. `Double64(::AbstractString)`
  is `parse`. Both throw `ArgumentError` on bad text (C2, C3).
- No call to the global `setprecision` (C4). The precision grows with the
  input length so long digit strings round-trip.
- String macros call `parse` at expansion time, unchanged.
- `tryparse(BigFloat, s; precision)` was run on Julia 1.13.3; the CI job
  on 1.12 (R4) covers the minimum.

### 4.4 Promotion

**Rule: the result type contains both operand types, to rounding.**

| Operands | Today | 2.0 |
|:--|:--|:--|
| `Double64` with `IEEEFloat`, `Integer`, `Rational`, `Irrational` | `Double64` | `Double64` |
| `Double32` with `Float32`, `Float16` | `Double32` | `Double32` |
| `Double32` with `Float64` | `Double32` | `Double64` |
| `Double16` with `Float32` | `Double16` | `Double32` |
| `Double16` with `Float64` | `Double16` | `Double64` |
| `Double64` with `Float128` (Quadmath extension) | `Double64` | `Float128` |
| Any with `BigFloat` | `BigFloat` | `BigFloat` |

`Double32` holds 48 bits and the `Float32` exponent range; `Float64` holds
53 and a wider range. Neither contains the other, and `Double64` contains
both (C10).

### 4.5 Errors

- `DomainError(x, "message")` with the offending value first.
- `InexactError` and `ArgumentError` where `Base` uses them.
- `Base.Experimental.register_error_hint` for a `MethodError` on a
  `DoubleFloat` matrix passed to `eigen`, `schur`, `svd`, or on `erf`,
  `gamma`, and the Bessel functions, naming the packages that provide them.
- No public function reads or writes global state.

## 5. Text and exchange

### 5.1 Display

| Call | Job | `Double64(1)/3` |
|:--|:--|:--|
| `print`, `string` | Human text | `0.333333333333333333333333333333332` |
| `show(io, x)`, `repr` | Reconstructing Julia code | `df64"0.333333333333333333333333333333332"` |
| `show` with `:typeinfo` equal to the type | Inside typed containers | bare digits |
| `show` with `:compact => true` | Tables, matrices | `0.333333` |
| `showtyped(x)` | Both words, lossless | `Double64(0.3333333333333333, 1.850371707708594e-17)` |

**Digits.** Emit the fewest significant decimal digits `d` for which
`parse(T, text) === x`. Prototype (*verified*): form the exact value in
`BigFloat`, generate `d` digits with MPFR, test the round trip, increase
`d` until it holds. Measured on 2,000 random `Double64` values: 29 to 37
digits, mean 32.9. A sparse low word takes more (`Double64(1.0, 1e-40)`
takes 41) and is then exact, which today's output is not (C6). `Double32`
values take about 16 instead of the 35 printed now (C7). The search starts
at `⌈2p·log₁₀2⌉` digits and a production version should bisect.

The earlier statement that 33 digits always suffice was wrong: the
precision of a normalized pair is not fixed at `2p` bits.

**Precedent for D4.** `repr(Float16(0.1))` is `Float16(0.1)` and
`repr([Float16(0.1)])` is `Float16[0.1]`. The same rule gives a `repr` that
round-trips (C5) and containers that stay readable. Complex values follow
component-wise.

**Compact.** Six significant digits of the value, for vectors and matrices
alike (C8). Remove the one-argument `show(x)` methods; `Base` provides them.

### 5.2 Printf

`Printf` converts arguments through `Printf.tofloat`, which defaults to
`Float64`. Define `Printf.tofloat(x::DoubleFloat) = BigFloat(x)`, as
Quadmath does for `Float128`, and delete the `ini_dec` and `fix_dec`
overloads, which narrow to `Float64` (C9). `tofloat` is not public API, so a
test pins `@sprintf("%.30f", x)` on every supported Julia version.

### 5.3 Exchange

- **Text:** `parse(T, string(x)) === x` for every finite normalized `x`.
- **Words:** `reinterpret(Float64, v)` and
  `reinterpret(reshape, Float64, v)` expose the pairs without copying; the
  inverse reconstructs. This is the documented lossless storage format.
- **Logs:** `showtyped`.

**Property P-TXT.** Over random, sparse, subnormal, extreme, and special
values: `parse(T, string(x)) === x`; `eval(Meta.parse(repr(x))) === x`;
`reinterpret` round trip is bitwise.

## 6. Guarantees

### 6.1 Tiers and metrics

| Tier | Meaning |
|:--|:--|
| `exact` | The result is the mathematical value |
| `bounded` | Relative error has a proved bound, with a citation or proof |
| `sampled` | A bound observed on a stated sample; no proof |

| Metric | Unit | Used for |
|:--|:--|:--|
| `forward` | `ε_D` relative | Finite results at or above `floatmin_full` |
| `lattice` | Steps of `Δ` absolute | Results in the underflow band |
| `residual` | `ε_D` scaled as the Accuracy Report defines | Matrix identities and factorizations |

Preconditions for `exact` and `bounded`: inputs satisfy `𝒩`; rounding is to
nearest; no intermediate overflow; no intermediate underflow. Outside them
the operation is defined and the tier does not apply.

### 6.2 Arithmetic assignments

| Operation | Kernel | Published algorithm | Tier | Bound |
|:--|:--|:--|:--|:--|
| `two_sum`, `two_prod`, `add2`, `sub2`, `mul2` | `errorfree.jl` | Knuth; FMA product | exact | |
| `+`, `−` | `add_dddd_dd` | Joldes, Muller, Popescu (2017), Algorithm 6 | bounded | `3u² + 13u³` = 0.75 `ε_D` |
| `*` | `mul_dddd_dd` | Same paper, Algorithm 10 | bounded | `7u²` = 1.75 `ε_D`; *confirm* the `5u²` of Muller and Rideau (2022) |
| `/` | `dvi_dddd_dd` | A variant of the published division | sampled | Until proved, or replaced by the published algorithm with its bound |
| `sqrt`, `inv`, `fma`, mixed `DoubleFloat`–`F` forms | | To be identified | sampled | Until identified |

Each `bounded` entry cites the algorithm and the source line. W3.2 audits
every arithmetic kernel against the paper and either records the match or
drops the entry to `sampled`.

### 6.3 Sampling rules

1. A `sampled` statement carries metric, sample size, distribution, seed,
   and toolchain.
2. With `n` independent draws and none above `m`, the 95% upper bound on
   the probability that another draw from the same distribution exceeds `m`
   is `3/n`. It says nothing about inputs the distribution does not reach.
3. Each route therefore also runs structured points: both sides of every
   admission endpoint, table midpoints, both signs and several magnitudes
   of `lo`, and special values.
4. Sizes (D13): 10⁶ random points per scalar route in the scheduled report
   job; 10⁴ in CI.
5. The ceiling for scalar elementary routes in the `forward` metric is
   `2.2 ε_D`, the threshold the tests already apply. A route that exceeds it
   is not admitted.
6. A composite operation takes the weakest tier of its parts.

### 6.4 Determinism

Scalar results are a function of the input words alone: the kernels use
correctly rounded `fma`, and no `@fastmath` or reassociation. Batch kernels
flagged `identical` return the scalar bits. Other batch kernels may round
differently and say so in their route. *Confirm* on a target without
hardware FMA that results match, and record the cost there.

## 7. Routes

### 7.1 The record

```julia
@enum Tier exact bounded sampled
@enum Metric forward lattice residual

struct Route{A,K}
    name::String
    admits::A                     # predicate; branch-free where batched
    kernel::K
    valid::NTuple{2,Float64}      # heads where the kernel is mathematically valid
    measured::NTuple{2,Float64}   # heads where evidence exists; within `valid`
    tier::Tier
    metric::Metric
    bound::Float64
    identical::Bool               # batch only: same bits as the scalar route
end
```

`valid` and `measured` are separate so that a narrow admission window (the
present `asinh` batch range of 0.005–0.045, for example) is visibly the
edge of the evidence and not of the mathematics (F6).

### 7.2 Declaration and dispatch

```julia
routes(::typeof(exp), ::Type{Double64}) = (EXP_TABLE128, EXP_TABLE16, EXP_WIDE)
routes(::typeof(exp), ::Type{Double64}, ::Batch) = (EXP_BATCH128,)

@inline evaluate(rs::Tuple{Route}, x) = first(rs).kernel(x)
@inline evaluate(rs::Tuple, x) =
    first(rs).admits(x) ? first(rs).kernel(x) : evaluate(Base.tail(rs), x)

Base.exp(x::Double64) = evaluate(routes(exp, Double64), x)
```

A three-route prototype of this pattern compiles to an inlined branch chain
with no calls and no allocation (*verified*). There is no mutable table and
no generated function. Each conversion is accepted only when its benchmark
matches the hand-written predecessor within noise (W3.4).

Batch selection reuses the same record; the present
`_BatchKernel(eligible, evaluate)` supplies `admits` and `kernel`, and
block selection, repair, and threading in `simd.jl` are unchanged.

### 7.3 Invariants checked for every route

| Property | Statement |
|:--|:--|
| P-TOTAL | Every chain ends in a route whose `admits` is always true |
| P-NORM | Every output satisfies `𝒩` |
| P-BOUND | On `measured`, error in the route's metric is within `bound` |
| P-SEAM | At each boundary between adjacent routes, both kernels evaluated on the boundary points agree within the sum of their bounds |
| P-IDENT | A route flagged `identical` returns the scalar bits on every admitted input tested |
| P-ADMIT | `admits` implies the head lies in `valid` |

The suite iterates over all `routes` methods, so a route with missing
metadata or a failing fixture fails CI.

### 7.4 Asking the type

```julia
DoubleFloats.guarantee(f, T)        # -> Guarantee: tier, metric, bound, measured, samples, source
DoubleFloats.route(f, x)            # -> the Route that evaluates f(x)
DoubleFloats.route(f, v::AbstractVector)   # -> admitted fraction per batch route
```

`guarantee(f, T)` reports the weakest tier and largest bound across the
chain, and `guarantee(f, T, route)` reports one. A downstream package can
derive a tolerance from it instead of hard-coding one. For a whole-block
batch kernel of width `m` and per-element admission rate `p`, the native
fraction is `p^m`; `route(f, v)` measures `p` on the client's data.

### 7.5 Arrays

| Path | Client writes | Condition | Guarantee |
|:--|:--|:--|:--|
| Scalar broadcast | `y .= f.(x)` | Always | Scalar route per element |
| Transparent batch (D8) | `y .= f.(x)` | Route `identical`; dense, disjoint `Vector`s; a single call, not a fused expression | Same bits as scalar, by P-IDENT |
| Explicit batch | `DoubleFloats.simdmap!(f, y, x)` | Any batch route | The batch route's own tier and bound |
| Explicit, allocating | `DoubleFloats.simdmap(f, x)` | Same | Same |
| Threaded | `simdmap!(…; threaded = true)` | Above the route's length threshold | Same values; write order on failure unspecified |

Candidates for the transparent path are the eleven `Double64` kernels the
Technical Guide reports as producing identical words: `exp`, `exp2`,
`expm1`, `log`, `log2`, `log1p`, `atan`, `tan`, `sinh`, `cosh`, `tanh`. The
six native `Double32` kernels have higher sampled error than scalar and
stay explicit.

The transparent path is one `copyto!` method on a `Broadcasted` whose
function and single `Vector{D}` argument are the package's own. It is the
last item in the plan and is dropped without consequence if P-IDENT fails
on any supported target or if it causes invalidations.

## 8. Structure

### 8.1 `Float128` leaves the core by gate (R3)

`Float128` is on these core paths today (F18). It holds 113 significand
bits; a `Double64` can span more, and `Float128(x)` rounds the excess away.

Measured on 2026-11-25 (x86_64, Julia 1.13.3; 50 000 uniform samples per
row; maximum relative error in units of `ε_D = 2^-104`; "wide" inputs have
a low word reaching below bit 113):

| Route | Time | Error, inputs within 113 bits | Error, wide inputs |
|:--|--:|--:|--:|
| `sin` on [0, 6], native | 60 ns | 0.78 | 0.74 |
| `sin` on [7, 100], `Float128` | 435 ns | 0.13 | 5.5 |
| `asin`, `acos` on [−1, 1], `Float128` | 440–460 ns | 0.13 | 0.13 |
| `sinpi` on [0, 2], `Float128` | 357 ns | 105 | 114 |
| `sinh` near 709, `Float128` | 530 ns | not measured | not measured |
| `atan(y, x)`, `Float128` | 393 ns | not measured | not measured |

Uniform sampling does not find the worst wide inputs. By construction:

| Call | Returned | True value |
|:--|:--|:--|
| `acos(Double64(1.0, -2.0^-120))` | `0.0` | `1.23e-18` |
| `sinpi(Double64(1.0, 2.0^-120))` | `8.67e-35` | `-2.36e-36` |
| `string(Double64(1.0, 2.0^-200))` | `"1"` | does not round-trip |

Two facts follow, and R3 rests on both. On inputs that fit 113 bits the
`Float128` routes are the most accurate in the package, so a replacement
can lose accuracy. On wide inputs at ill-conditioned points they are
wrong, sometimes completely, so they cannot carry a bound.

**Unconditional replacements.** These are defects however the gate falls.

| Function | Present route | 2.0 route | Item |
|:--|:--|:--|:--|
| `string` | `string(Float128(x))` | Shortest-digit generation, §5.1 | W2.1 |
| `sinpi`, `cospi` | `Float128` | Exact reduction modulo 2 on the pair, then the `sin`/`cos` kernels on `π·r` with triple-word `π` | W4.2 |

**Gated replacements.**

| Function | Present route | Candidate route | Item |
|:--|:--|:--|:--|
| `sinh`, `cosh` above 709 | `exp(Float128(x)) / 2` | `exp(x − ln2)` with a two-word `ln2`, or `(exp(x/2))² / 2` with rescaling | W4.1 |
| `asin`, `acos`, `acsc`, `asec`, `acot` | `Float128` | Composed from the `atan` and `sqrt` kernels with exact differences near ±1 | W4.3 |
| `atan(y, x)` | `Float128` | Quotient, unary `atan` kernel, quadrant correction with two-word `π` | W4.4 |
| `sqrt` of a `ComplexDF64` | `ComplexF128` | The real `sqrt` and `hypot` kernels, as the generic `Complex{DoubleFloat}` method already does | W4.9 |
| `sin`, `cos` for `abs(x) ≥ 6.28125` | `Float128` | `BigFloat` reduction modulo `π/2` at precision set by the exponent, then the kernels; native Payne–Hanek later | W4.5 |

The complex square root was found by the golden corpus: on ARM macOS with
Julia 1.12.0 its bits differ from every other platform and Julia version
tested, which is what a route through the platform's libquadmath risks.

`erf`, `gamma`, and the Bessel functions keep `Float128` inside the
special-functions extension and are outside this ruling.

**The gate.** A candidate replaces its `Float128` route only if all hold,
at the report-job sample size of D13:

1. On inputs representable in `Float128`, maximum relative error is at
   most `1 ε_D`.
2. On wide inputs, maximum relative error is within the `2.2 ε_D` ceiling.
   The sample includes inputs placed next to each zero, pole, and domain
   endpoint of the function, and the constructed cases above as named
   regression tests.
3. P-SEAM holds against the neighbouring routes.
4. It is not slower than the route it replaces (release criterion 7).

A candidate that passes enters as a `sampled` route. The `BigFloat`
reduction of W4.5 allocates and is the candidate most likely to miss
condition 4; a native reduction is then the way to pass.

**A kernel that misses the gate** stays on `Float128` in 2.0, and:

- its route is tier `sampled`, with the precondition "the input is
  representable in `Float128`" in its guarantee record, so
  `guarantee(f, T)` and the generated tables show it;
- its docstring states the precondition and gives one wide-input example;
- P-BOUND is tested on the precondition's domain only;
- the candidate and its gate results are kept in the report job, so the
  next attempt starts from numbers.

**Dependency consequence.** Quadmath moves to `[weakdeps]` only when no
core route calls `Float128`. If any gated kernel is retained, Quadmath
stays in `[deps]` for 2.0, the contents of the Quadmath extension (§8.2)
stay in the core, and the move happens in the 2.x release where the last
kernel passes. That move is not breaking: the extension loads whenever
the client's environment has Quadmath. It is the one stated exception to
R1.

*Confirm* whether Quadmath is available on every platform the package
claims (the CI matrix requests `x64` on macOS). If it is not, a retained
kernel is a portability defect on that platform and the gate cannot be
used to defer it there.

### 8.2 Extensions (D7)

```toml
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[weakdeps]
GenericLinearAlgebra = "14197337-ba66-59df-a3e3-ca00e7dcff7a"
GenericSchur = "c145ed77-6b09-5dd9-b285-bf645a82121e"
Quadmath = "be4d8f0f-7fa4-5f49-b795-2f01399ab2dd"
SpecialFunctions = "276daf66-3868-5448-9aa4-cd146d93841b"

[extensions]
DoubleFloatsGenericLinearAlgebraExt = ["GenericLinearAlgebra", "GenericSchur"]
DoubleFloatsQuadmathExt = "Quadmath"
DoubleFloatsSpecialFunctionsExt = ["SpecialFunctions", "Quadmath"]
```

This is the end state. Under R3, Quadmath stays in `[deps]` and
`DoubleFloatsQuadmathExt` does not yet exist while any core route still
calls `Float128` (§8.1).

- An extension cannot add exports to its parent. None are needed: `erf`,
  `gamma`, `ellipk`, and the Bessel names belong to SpecialFunctions;
  `eigen`, `schur`, `svd` to LinearAlgebra. `agm` and `agm1` are the
  package's own and stay in the core.
- `lu`, `qr`, and `\` use LinearAlgebra's generic kernels and work with the
  core alone. Matrix functions that need a Schur form live in the
  extension; the scaling-and-squaring and triangular routes that do not can
  stay in the core.
- The Quadmath extension holds conversion to and from `Float128` and the
  promotion rule of §4.4.
- Each extension has a `PrecompileTools` workload (C17).
- Compat lower bounds are raised to versions tested on current Julia;
  standard libraries get compat entries; the nonstandard `desc`, `keywords`,
  `license`, and `repo` keys are removed; test dependencies move to
  `test/Project.toml` (F10).

### 8.3 Source tree

```
src/
  DoubleFloats.jl     module, exports, public declarations
  core/               type, constructors, conversion, comparison, hash, promotion, reflection
  eft/                error-free transformations                    (tier exact)
  arith/              double-word kernels with cited bounds         (tier bounded)
  routes/             Route, Tier, Metric, evaluate, guarantee, route
  elementary/         one file per family: kernels, then its routes(...) methods
  batch/              simdmap!, block selection, repair, threading
  io/                 digits, show, parse, printf
  random/
ext/
  DoubleFloatsGenericLinearAlgebraExt/
  DoubleFloatsQuadmathExt/
  DoubleFloatsSpecialFunctionsExt/
```

Kernels state a precondition and nothing else. Admission lives in the
`Route` beside them. Today both are fused inside functions such as `exp`,
which is why ranges are transcribed into the manual by hand.

### 8.4 Source practice

- One parametric method on `DoubleFloat{F}` in place of `@eval` loops that
  stamp a method per type; one docstring in place of three.
- Internal names take a leading underscore; anything else is supported.
- Coefficient tables are built with `setprecision(BigFloat, 256) do … end`,
  as now.
- `@inline` is kept where a benchmark shows it matters.
- One formatter configuration, applied once in its own commit.
- The misplaced algorithm comment inside `sub_dddd_dd` is repaired (F12).

## 9. Surface

| Disposition | Names |
|:--|:--|
| Exported | `DoubleFloat`, `Double64`, `Double32`, `Double16`, `ComplexDF64`, `ComplexDF32`, `ComplexDF16`, `@df64_str`, `@df32_str`, `@df16_str`, `HI`, `LO`, `HILO`, `ulp`, `square`, `cube`, `add2`, `sub2`, `mul2`, `div2`, `agm`, `agm1` |
| Public, qualified | `simdmap!`, `simdmap`, `guarantee`, `route`, `isnormalized`, `floatmin_full`, `showtyped`, `stringtyped`, `intpart`, `fracpart`, `randpm`, `normalize`, `⊕`, `⊖`, `⊗`, `⊘` (D9), `MultipartFloat` |
| Deprecated, removed in 3.0 (D12) | `nan`, `inf`, `posinf`, `neginf` → `T(NaN)`, `T(Inf)`, `T(-Inf)`; `showall` → `print`; `isposinf`, `isneginf` → comparison with `Inf`; `@via_df64`, `@via_df32` → the broadcast they expand to |
| Document or remove (W3.6) | `fmod`, `sld`, `tld`, `signs`, `spread`, `isnonzero`, `ispositive`, `isnegative`, `isnonpositive`, `isnonnegative`, `isfractional`, `isnormal`, `issquare` |

`HI`, `LO`, and `HILO` keep their capitals: `lo` and `hi` are the customary
argument names of `clamp` and of every bounds pair, and lowercase accessors
would be shadowed constantly. 29 of the 67 exported names have no docstring
today (C15); the last row is where most of them are, and each is either
given a docstring with a tested example or removed.

**Support levels**, stated in the manual's type table (F11, D10):

| Type | Arithmetic | Elementary functions |
|:--|:--|:--|
| `Double64` | Native | Native routes |
| `Double32` | Native | Native on listed routes; otherwise computed in `Double64` |
| `Double16` | Native | Computed in `Double64` |

**Random numbers.** `rand(rng, T)` is uniform on `[0, 1)` over the grid
`2^-2p`, built as `DoubleFloat(u₁, 2^-p · u₂)` from two uniform draws of `F`
(*verified* exact for `Float64`, whose draws are multiples of `2^-53`).
`randpm` accepts any `AbstractRNG` (C12). `randn` states its method and
tier.

## 10. Documentation and evidence

### 10.1 Manual

| Layer | Question | Pages |
|:--|:--|:--|
| Use | How do I compute with it? | Overview; construct, display, exchange; scalars; arrays; matrices; upgrade guide |
| Contract | What is promised? | Representation and special values; `Base` conformance; tiers and metrics; per-operation table (generated) |
| Mechanism | How is it kept? | Error-free transformations; reduction and reconstruction; routes; adding a route |
| Evidence | How do I know? | Accuracy report; benchmark report; crossover model; reproduction |

- Admission and guarantee tables are generated from `routes` during the
  docs build.
- Before/after timings and rollout notes move to `NEWS.md`. Planning notes
  in `docs/` leave the published path (F8, F9).
- `docs/make.jl` stops rewriting links and copying files; pages live in
  `docs/src/`; cross-references use `@ref` and `@id`. Build output is
  untracked. `makedocs` runs with `checkdocs = :exports`, `doctest = true`,
  and no `warnonly`.
- Reports carry Julia version, CPU target, revision, seed, and sample
  sizes, and one report uses one toolchain.

### 10.2 Docstring template

````julia
"""
    exp(x::DoubleFloat)

Compute the natural exponential of `x`.

# Examples
```jldoctest
julia> exp(df64"1")
2.7182818284590452353602874713526646
```

# Extended help

## Guarantee
(generated from `routes(exp, T)`: one row per type with tier, metric,
bound, and measured range)
"""
````

`?exp` shows the summary; `??exp` shows the guarantee. The example output
above is what 1.13.3 prints and will be regenerated under the 2.0 digit
rule.

## 11. Work plan

Stages are pre-releases of 2.0. Each item names what it resolves. An item
is done when its property or gate passes in CI.

### Stage 1 — 2.0-alpha 1: correctness

| Item | Work | Files | Resolves |
|:--|:--|:--|:--|
| W1.1 | Conformance suite: P-ORD and the conversion, keyword, and round-trip properties, over all three types | `test/conformance.jl` | Finds the rest |
| W1.2 | `==`, `<`, `isless`, `isequal`; exact mixed comparison; non-finite rule | `src/type/compare.jl` | F13, F14, F15, F17 |
| W1.3 | Normalizing constructors; `unsafe_double`; one generic `Real` constructor; exact integers; delete nested-type methods | `src/Double.jl`, `src/type/constructors.jl`, `src/type/convert.jl`, `templated.jl` | F2, F4, F11 |
| W1.4 | Exact `decompose`; `hash` | `src/Double.jl` | F1, F16 |
| W1.5 | `tryparse`, `parse`, string constructors without global precision | `src/type/parse.jl` | C2, C3, C4 |
| W1.6 | `InexactError` on lossy integer conversion; `rationalize` | `src/type/constructors.jl`, `src/extras/misc.jl` | C1, C11 |
| W1.7 | `isapprox` keywords; `randpm` on `AbstractRNG`; `rand` grid; `@via_df32` | `src/extras/` | F3, C12, C13 |
| W1.8 | Promotion table of §4.4 | `src/type/promote.jl` | C10 |
| W1.9 | `Aqua.test_all`; resolve 12 ambiguities; review `Base.lerpi` and `clamp` methods for piracy | `test/aqua.jl` | C16 |
| W1.10 | CI on `main`, Julia 1.12 and current; compat bounds; untrack `docs/build*` | `.github/`, `Project.toml`, `.gitignore` | F9, F10 |

Gate: conformance suite and Aqua pass on the full matrix.

### Stage 2 — 2.0-alpha 2: text

| Item | Work | Files | Resolves |
|:--|:--|:--|:--|
| W2.1 | Shortest round-trip digits; `string`, `print` | `src/io/digits.jl` | C6, C7 |
| W2.2 | `show`: `repr` form, `:typeinfo`, complex | `src/type/show.jl` | C5 |
| W2.3 | Compact rule | same | C8 |
| W2.4 | `Printf.tofloat`; remove `ini_dec`, `fix_dec` | same | C9 |
| W2.5 | Exchange section and `showtyped` in shortest form | docs | |

Gate: P-TXT passes.

### Stage 3 — 2.0-beta 1: contract

| Item | Work | Files | Resolves |
|:--|:--|:--|:--|
| W3.1 | `Route`, `Tier`, `Metric`, `evaluate`, `guarantee`, `route` | `src/routes/` | F6, F7 |
| W3.2 | Audit arithmetic kernels against the cited paper; assign tiers | `src/math/ops/`, `errorfree.jl` | §6.2 |
| W3.3 | Batch kernels as routes; batch table generated | `src/math/elementary/simd.jl` | F6 |
| W3.4 | Scalar chains as routes, one family per change, each benchmarked | `explog.jl`, `trig.jl`, `hyptrig.jl`, … | F6, F8 |
| W3.5 | Route properties P-TOTAL … P-ADMIT; `public` declarations | `test/routes.jl`, `src/DoubleFloats.jl` | C14 |
| W3.6 | Docstrings for every exported and public name; rule on the last row of §9 | all | C15 |
| W3.7 | Reports with provenance, metrics, raised sample sizes; `floatmin_full`; support-level table | `docs/reports/` | F5, F7, F11 |
| W3.8 | Manual re-layered; `make.jl` simplified; history to `NEWS.md` | `docs/` | F8, F9 |

Gate: docs build with `checkdocs = :exports` and doctests; every route
passes its properties; no scalar benchmark regresses beyond noise.

### Stage 4 — 2.0-beta 2: structure

| Item | Work | Resolves |
|:--|:--|:--|
| W4.0 | Gate harness: both input classes, endpoint-biased sampling, the constructed regression cases, timing against the `Float128` route | R3 |
| W4.1 | `sinh`, `cosh` top band without `Float128` (gated) | F18 |
| W4.2 | `sinpi`, `cospi` by exact reduction (unconditional) | F18 |
| W4.3 | `asin`, `acos`, and relatives from `atan` and `sqrt` (gated) | F18 |
| W4.4 | Two-argument `atan` (gated) | F18 |
| W4.5 | Large-argument `sin`, `cos` by `BigFloat` reduction (gated) | F18 |
| W4.9 | `sqrt` of a `ComplexDF64` without `Float128` (gated) | F18 |
| W4.6 | Extensions; error hints; precompile workloads | C17, D7 |
| W4.7 | Reduced exports; deprecations with `depwarn` | §9 |
| W4.8 | Transparent broadcast path, if P-IDENT holds everywhere | D8 |

Gate: `string`, `sinpi`, and `cospi` do not call `Float128`; every other
core route that does is on the retained list of R3 with its gate results
recorded; `using DoubleFloats` loads only standard libraries, and Quadmath
if that list is not empty; first-call time for each documented entry point is under
half a second.

### Stage 5 — 2.0-rc

Upgrade guide with one before-and-after line per behaviour change;
`NEWS.md`; dependents tested against the candidate; the *confirm* items of
this document closed.

## 12. Ledger

Verified defects, their remedy, and where it lands.

| ID | Defect | Remedy | Item |
|:--|:--|:--|:--|
| F1 | `hash` disagrees with `isequal`; `Dict` lookup fails | §4.1 | W1.4 |
| F2 | Raw constructor yields unnormalized values that compare wrongly | §3.3 | W1.3 |
| F3 | Mixed-type `isapprox` throws | Remove stray keyword | W1.7 |
| F4 | `Double64(2^62 + 1)` and `Double64(typemax(Int64))` inexact | §3.3 | W1.3 |
| F5 | Full-precision threshold unexposed and stated three ways | §3.4 | W3.7 |
| F6 | Admission ranges mix validity with evidence | §7.1 | W3.1–W3.4 |
| F7 | Accuracy claims carry no tier or metric | §6 | W3.1, W3.7 |
| F8 | Technical Guide interleaves algorithm, tables, history | §10.1 | W3.8 |
| F9 | Link rewriting; tracked build output; planning notes published | §10.1 | W1.10, W3.8 |
| F10 | CI on `master` and latest Julia only; loose compat | §8.2 | W1.10 |
| F11 | Support levels implicit; dead nested-type methods | §9, §3.3 | W1.3, W3.7 |
| F12 | Misplaced comment; empty `test/README.md` | §8.4 | W3.4 |
| F13 | `NaN == NaN` is `true` | §4.1 | W1.2 |
| F14 | `isless`, `isequal` wrong on NaN and zeros; `sort` misorders | §4.1 | W1.2 |
| F15 | `Double64(1)/3 == 1//3` is `true` | §4.1 | W1.2 |
| F16 | `Base.decompose` throws; inexact for `Double32` | §4.1 | W1.4 |
| F17 | Two stored forms of infinity | §3.2 | W1.2 |
| F18 | `Float128` on core paths | §8.1: replaced where the gate passes, labelled where it does not | W2.1, W4.0–W4.5 |
| C1 | `Int64(Double64(2.5))` returns 2 | §4.2 | W1.6 |
| C2 | `tryparse` throws on bad text | §4.3 | W1.5 |
| C3 | `parse` and the string constructor throw different errors | §4.3 | W1.5 |
| C4 | A failed parse leaves `precision(BigFloat)` changed | §4.3 | W1.5 |
| C5 | `repr` does not round-trip | §5.1 | W2.2 |
| C6 | `string` drops a sparse low word | §5.1 | W2.1 |
| C7 | `Double32` prints 35 digits | §5.1 | W2.1 |
| C8 | Vectors and matrices follow different display rules | §5.1 | W2.3 |
| C9 | `@sprintf` prints `Float64` digits | §5.2 | W2.4 |
| C10 | Promotion narrows (`Double32` with `Float64`; `Double64` with `Float128`) | §4.4 | W1.8 |
| C11 | `rationalize(Double64(1)/3)` returns `1//4` | §4.2 | W1.6 |
| C12 | `randpm` accepts only `MersenneTwister` | §9 | W1.7 |
| C13 | Three-argument `@via_df32` returns `Float64` | Fix, then deprecate | W1.7 |
| C14 | `simdmap!` neither exported nor public | §9 | W3.5 |
| C15 | 29 of 67 exports undocumented | §9 | W3.6 |
| C16 | 12 method ambiguities | Aqua | W1.9 |
| C17 | First matrix `exp` takes 1.5 s | §8.2 | W4.6 |

## 13. Release criteria

2.0 is released when each holds in CI on Julia 1.12 and current.

1. P-ORD, P-TXT, and the conversion properties pass for all three types.
2. P-TOTAL, P-NORM, P-BOUND, P-SEAM, P-ADMIT pass for every route, and
   P-IDENT for every route flagged `identical`.
3. Every exported and public name has a docstring with a passing doctest,
   and `guarantee(f, T)` returns a value for every supported operation.
4. Every admission and guarantee table in the manual is generated.
5. `Aqua.test_all` passes without exclusions; no public function touches
   global state.
6. `using DoubleFloats` loads only standard libraries, and no core route
   calls `Float128`; or, under R3, the only exceptions are Quadmath and
   the retained kernels, each labelled `sampled` with its precondition.
7. No scalar or batch benchmark is slower than 1.13.3 beyond noise, except
   where a correctness fix requires it and the upgrade guide says so.
8. Every *confirm* item is closed, and every ruling in §2.2 is recorded.
