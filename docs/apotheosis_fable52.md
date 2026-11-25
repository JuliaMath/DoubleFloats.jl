# DoubleFloats.jl at its apotheosis

An independent assessment of how the package is presented, how that differs
from what the package is, and what its finished form looks like. Based on
`src/`, `test/`, `perf/`, the manual under `docs/src/`, the generated reports,
and live probes on Julia 1.13.3 against version 1.13.3 of the package.

Notation: `u` is the unit roundoff of the underlying type (`2^-53` for
`Float64`). The reports' working unit for `Double64` is `ε_D = 2^-104 = 4u²`.
`RN` is round-to-nearest.

## 1. Thesis

The package presents itself as a faster, more accurate number type whose
story is told through its history: which kernels got faster, by how much,
since which revision. Its finished form presents something else: **a number
type that carries a contract**. Every public operation states what it
guarantees, on which inputs, by which route, and with what evidence, and
that statement is the same object the code dispatches on, the tests check,
and the manual prints.

The engineering needed for this mostly exists. What is missing is the single
source of truth that binds it. Today the same fact (for example, "`exp` takes
the fast route for heads in `[-670, 700]`") lives in four places: a guard in
the source, a prose table in the Technical Guide, a fixture in `perf/`, and a
range in a test. Nothing forces them to agree.

## 2. The current realization

What is there, stated plainly.

- **Core.** `DoubleFloat{T}` is an immutable pair `(hi, lo)` of `IEEEFloat`s
  whose value is the unevaluated sum. About 8,300 lines of source, 2,900 of
  tests, 67 exported names.
- **Arithmetic.** Error-free transformations (`two_sum`, `two_prod` via `fma`)
  under double-word kernels that cite Joldes, Muller, and Popescu (2017) in
  source comments: addition below `3u²`, multiplication at most `7u²`.
  Division is a variant with no cited bound.
- **Elementary functions.** Table-driven reductions with double-word
  coefficients generated at load time from 256-bit `BigFloat`. Guarded fast
  routes for bounded head ranges, wider fallbacks, and MPFR-assisted rounding
  at the underflow lattice. `Float128` from Quadmath carries `asin`, `acos`,
  two-argument `atan`, `sinpi`, `cospi`, `sin` and `cos` for `|x| ≥ 6.28125`,
  the top band of `sinh` and `cosh`, and `string`.
- **Batches.** `DoubleFloats.simdmap!` (not exported) selects per-block among
  native kernels, sparse lane repair, and the scalar loop. Selection is
  already data: `_BatchKernel(eligible, evaluate)`.
- **Linear algebra.** Factorizations route to GenericLinearAlgebra and
  GenericSchur. Matrix functions have dedicated triangular, symmetric,
  diagonal, and blocked routes with admission checks on size and norm.
- **Evidence.** Generated accuracy and benchmark reports, a crossover model
  for trading speed against error, a 550-line linked glossary.

This is strong work. The sampled worst errors for `Double64` scalar functions
are mostly below one working unit, and the batch kernels are measured against
matched scalar baselines with zero warmed allocations.

## 3. Compare and contrast

| Axis | Current realization | Apotheosis |
|:--|:--|:--|
| Organizing idea | History: "faster kernels", before → after | Contract: guarantee, domain, route, evidence |
| Representation invariant | Described in prose; raw constructor is public | Enforced: every public value is normalized or explicitly non-finite |
| Accuracy claim | Sampled maxima (250 points) and a 2.2-unit test threshold | Three named tiers: exact, proved bound, sampled bound |
| Route selection | Guards in code, retold as prose tables | One route registry read by dispatch, tests, docs, benchmarks |
| Admission ranges | A mix of mathematical validity and fixture windows | Validity range and measured range stated separately |
| Benchmarks | Several Julia versions and revisions inside the Technical Guide | One pinned toolchain per report; history in a changelog |
| `Base` conformance | Mostly correct, with verified gaps (§4) | A conformance suite that the gaps cannot pass |
| Dependencies | Four hard dependencies, including Quadmath | Arithmetic core with no numerical dependencies; the rest as extensions |
| Type family | `Double64` first-class; `Double32` partly; `Double16` forwarded | Each type has a stated support level |
| Manual | Sixteen pages; the Technical Guide carries algorithms, tables, and changelogs | Four layers: use, contract, mechanism, evidence |

## 4. Findings

Each finding is verified against the code or by execution.

### 4.1 Contract defects

**F1. `hash` disagrees with `isequal`.**
`isequal(Double64(1.0), 1.0)` is `true` and `hash(Double64(1.0)) == hash(1.0)`
is `false`. Consequently `haskey(Dict(1.0 => 1), Double64(1.0))` is `false`.
`Base` requires `isequal(a, b) ⇒ hash(a) == hash(b)`. The method in
`src/Double.jl` computes `hash(hi, h) ⊻ hash(lo)`, and two further methods
ignore the seed `h` altogether.

**F2. The normalization invariant is not enforced.**
`DoubleFloat{Float64}(1.0, 1.0)` constructs a value with `hi = lo = 1.0`.
It compares unequal to `Double64(2.0)` and less than `Double64(1.5)`.
Comparison, hashing, `floor`, and every kernel with a `|lo| ≤ ulp(hi)/2`
precondition assume normalized input, so one public call produces a value on
which the package's own ordering is wrong.

**F3. Mixed-type `isapprox` throws.**
`isapprox(Double64(1), Double32(1))` raises a `MethodError`: the method in
`src/extras/misc.jl` forwards an undeclared `norm=norm` keyword.

**F4. Integer construction is lossy without notice.**
`Double64(2^62 + 1)` is not equal to `2^62 + 1`, although the value needs 63
bits and `Double64` holds 106. The `Integer` method rounds through `Float64`
first. `Double64(big(2)^70 + 1)` is exact because `BigInt` takes the generic
`Real` path. The same number is exact or inexact depending on its integer type.

**F5. `floatmin` names a point where the contract no longer holds.**
`floatmin(Double64)` returns `floatmin(Float64) = 2^-1022`. A value with
leading bit `2^e` has its 106th bit at `2^(e-105)`, which is on the `Float64`
grid only when `e - 105 ≥ -1074`. Full precision therefore requires
`|x| ≥ 2^-969 = floatmin(Float64) · 2^53` (about `2.0e-292`). The package
states this threshold three ways: the Technical Guide says about `4e-292`,
the Accuracy Report uses `Δ / eps(Double64) = 2^-970`, and the type's
reflection functions do not expose it at all.

**F13. `NaN == NaN` is `true`.**
`Double64(NaN) == Double64(NaN)` returns `true` and `!=` returns `false`.
`==` compares components with `===`, which is bitwise. IEEE 754 and `Base`
require `false`.

**F14. `isless` and `isequal` do not follow `Base`.**
`isless(Double64(1), Double64(NaN))` is `false` (`Base`: `true`, NaN sorts
last). `isequal(Double64(-0.0), Double64(0.0))` is `true` and `isless` of
the same pair is `false` (`Base`: `false` and `true`). Consequence:
`sort([1, NaN, 0, -1])` as `Double64` returns `[1.0, NaN, -1.0, 0.0]`.

**F15. Comparison with `Rational` is inexact.**
`Double64(1)/3 == 1//3` is `true`. `Base` compares floats with rationals
exactly (`1/3 == 1//3` is `false`). The method converts the rational to
`Double64` first.

**F16. `Base.decompose` is defined and broken.**
`Base.decompose(::Double64)` calls an unqualified `decompose` and throws
`UndefVarError`. The `Double32` and `Double16` method goes through `Float64`
and is inexact for a sparse low word. `decompose` is what `Base`'s generic
`hash(::Real)` and exact rational conversion rely on.

**F17. Non-finite values have no canonical form.**
`Double64(Inf)` stores `(Inf, Inf)`; `floatmax(Double64) * 2` stores
`(Inf, 0.0)`. `==` special-cases infinities, which hides the difference;
hashing and `reinterpret` do not.

### 4.2 Structural tensions

**F6. Admission ranges conflate two different things.** The batch table
admits `Double64` `asinh` for heads in `0.005–0.045` and `acoth` in `40–100`.
These are windows that were benchmarked and validated, not the intervals on
which the kernels are mathematically valid. A reader cannot tell which
bounds are numerical necessity and which are the edge of the evidence.

**F7. The accuracy claim has no tier.** Addition has a proved bound in a
source comment (`3u² = 0.75 ε_D`). `exp` has a sampled maximum of `0.72 ε_D`
over 250 points. The tests accept `2.2 ε_D`. Matrix identities reach
`12.2 ε_D`. The manual presents all of these in the same table format, so a
theorem and a sample of 250 look equally strong.

**F8. The Technical Guide is three documents interleaved.** It holds
algorithm descriptions (durable), admission tables (must track the code),
and before/after timings tied to four revisions and two Julia versions
(historical). The durable part is hard to find and the historical part
ages the whole page.

**F9. Presentation is built by string surgery.** `docs/make.jl` rewrites
more than a dozen link targets by literal replacement, parses the glossary with a
regular expression, and copies files from `docs/` into `docs/src/`. Rendered
build output (51 files under `docs/build` and `docs/build-local`) is tracked.
Planning notes in `docs/` are linked from the published manual as sources of
record.

**F10. Verification does not match the declared support.** `Project.toml`
declares `julia = "1.10"`; `CI.yml` tests only the latest release, and its
push trigger names `master` while the default branch is `main`. The compat
entry `GenericLinearAlgebra = "0.3 - 0.6"` admits 0.4.0, which fails to
precompile on Julia 1.13 (method overwrite during precompilation).

**F11. Support levels are implicit.** `Double16` and most `Double32`
elementary functions are computed in `Double64` and rounded
(`templated.jl`). Methods exist for `DoubleFloat{Double32}`, a nested type
that no constructor produces; `convert` to a nested type overflows the stack. Special functions for all three types pass
through `Float128`. None of this is wrong, but the manual's type table
presents the three types as equals.

**F18. Quadmath sits on core paths.** The functions listed in §2 and
`string` itself call `Float128`. Removing Quadmath from the core is therefore
not a packaging change: it requires native kernels or `BigFloat` fallbacks
for each of them. `Float128(x)` also rounds away a sparse low word, so these
routes do not honour the full input.

**F12. Minor.** A comment for a different algorithm is fused into a code
line in `sub_dddd_dd`. `test/README.md` is a list of empty headings.

## 5. Mechanisms

Six mechanisms. Each removes a class of finding rather than one instance.

### M1. Make the invariant a fact of the type

Define normalization once, for finite values:

```math
\mathcal{N}(h, l):\quad h = \mathrm{RN}(h + l).
```

When `h` is not finite the value is `h` and `l` is ignored: equality,
ordering, hashing, and display read only `h`. This matches what arithmetic
already produces (F17) without an extra canonicalizing branch on hot paths.
A zero value keeps the sign of `h`.

- Every public constructor establishes `𝒩`. `Double64(hi, lo)` normalizes;
  on an already normalized pair `two_sum` returns the same two words, so
  valid stored data is unaffected.
- The raw pair constructor becomes internal (`unsafe_double`, on the
  precedent of `Base.unsafe_rational`, which likewise skips normalization).
  Kernels that have established `𝒩` use it.
- `isnormalized(x)` is public for clients who build values from stored pairs.
- `𝒩` is asserted on kernel outputs by the test suite, for every route, not
  by a run-time mode in the library. A global checking switch would put
  mutable state on hot paths.

Resolves F2 and F17. Makes every later bound well-posed, since each
published bound assumes `𝒩` on inputs.

### M2. Three tiers of guarantee

Every public operation is assigned exactly one tier per route.

| Tier | Meaning | Statement form | Examples |
|:--|:--|:--|:--|
| **E** exact | Result equals the mathematical value | `hi + lo = a ∘ b` | `two_sum`, `two_prod`, `add2`, `mul2`, conversion from `Float64` |
| **B** bounded | Relative error has a proved bound | `\|ŷ − y\| ≤ c·u²·\|y\|` with a citation or proof | `+`, `−`, `*` |
| **S** sampled | Bound observed on a stated sample; no proof | `max ≤ m` in a named metric on `n` points of a named distribution | `/`, elementary functions, matrix functions |

Preconditions for tiers E and B, stated once: inputs satisfy `𝒩`, rounding
is to nearest, no intermediate overflows, and no intermediate underflows
(for `two_prod`, the exponents of the factors sum to at least
`e_min + p − 1`). Outside these the operation is still defined; the tier
does not apply.

Constants as coded, to be confirmed against the papers before publication:

| Operation | Kernel | Algorithm in Joldes, Muller, Popescu (2017) | Bound | In units of `ε_D` |
|:--|:--|:--|:--|:--|
| `+`, `−` | `add_dddd_dd` | Algorithm 6, AccurateDWPlusDW | `3u² + 13u³` | 0.75 |
| `*` | `mul_dddd_dd` | Algorithm 10, DWTimesDW1 | `7u²`; reported tightened to `5u²` by Muller and Rideau (2022) | 1.75, or 1.25 |
| `/` | `dvi_dddd_dd` | A variant; not the published DWDivDW2 | none | tier S until proved |
| `sqrt` | to be identified | | | |

The source comment for addition says "`< 3u²`"; the published bound is
`3u²/(1 − 4u)`, slightly larger.

Rules that keep the tiers honest:

1. A tier-B constant must name the algorithm in the cited paper and the
   line of code that implements it. A kernel that deviates from the published
   algorithm is tier S until proved. Division is the present example.
2. A tier-S statement carries its metric, sample size, and distribution.
   The reports already use three metrics and they are not interchangeable:
   forward relative error in units of `ε_D`; absolute error in steps of the
   underflow lattice `Δ`; and identity residuals for matrix functions.
3. A sampled maximum is not a worst case. With `n` independent draws from a
   distribution and none above a level `m`, the 95% upper confidence bound
   on the probability that a further draw from the same distribution
   exceeds `m` is `3/n`: 1.2% for `n = 250`, `3·10⁻⁶` for `n = 10⁶`. It says
   nothing about inputs the distribution does not reach.
4. Tier-S routes therefore add structured adversarial points to the random
   ones: reduction boundaries, table midpoints, both signs of `lo` at each
   branch switch. The boundary tests already do this for `exp` and `log`.
5. Composite operations inherit the weakest tier of their parts.

Resolves F7. Converts the test threshold of `2.2 ε_D` from a private
constant into the published tier-S ceiling for scalar elementary functions
in the forward-error metric.

### M3. A route registry

A route is a concretely typed, immutable record:

```julia
@enum Tier exact bounded sampled
@enum Metric forward lattice residual

struct Route{A,K}
    name::String                  # "128-entry table, degree 9"
    admits::A                     # predicate on inputs; branch-free where batched
    kernel::K
    valid::NTuple{2,Float64}      # heads on which the kernel is mathematically valid
    measured::NTuple{2,Float64}   # heads on which evidence exists; within `valid`
    tier::Tier
    metric::Metric
    bound::Float64                # in units of the metric
    identical::Bool               # batch kernels: same bits as the scalar route
end
```

The registry is a function, not a table. Each operation declares its chain
as a tuple, most specific route first, fallback last:

```julia
routes(::typeof(exp), ::Type{Double64}) = (EXP_TABLE128, EXP_TABLE16, EXP_WIDE)

@inline evaluate(rs::Tuple{Route}, x) = first(rs).kernel(x)
@inline evaluate(rs::Tuple, x) =
    first(rs).admits(x) ? first(rs).kernel(x) : evaluate(Base.tail(rs), x)

Base.exp(x::Double64) = evaluate(routes(exp, Double64), x)
```

Tuple recursion over concrete types compiles to the same guarded branch
chain that is written by hand today: a three-route prototype inlines fully,
with no calls and no allocation. There is no global mutable table, no
`@generated` function reading one, and no run-time lookup. The existing
`_BatchKernel(eligible, evaluate)` is this record with the metadata
missing; batch routes are a second method, `routes(f, T, Batch())`.

One registry, four consumers:

- **Dispatch.** `evaluate(routes(f, T), x)`, as above. Each converted
  function is benchmarked against its hand-written form before the old code
  is removed.
- **Tests.** For each route: sample inside `measured`, probe both sides of
  each endpoint of `admits`, assert the result is within `bound` and that
  `𝒩` holds. The suite iterates over every `routes` method, so a route
  without metadata or with a failing fixture fails CI.
- **Manual.** The admission tables in the Technical Guide are printed from
  the registry. They cannot drift.
- **Benchmarks.** Fixtures are drawn from `measured`, so the benchmark and
  the accuracy claim refer to the same inputs.

Two invariants the registry makes checkable:

- **Totality.** For each `(op, type, shape)` the route chain ends in a route
  with `admits ≡ true`.
- **Seam continuity.** At every boundary between adjacent routes, both
  routes are evaluated on the shared boundary points and must agree within
  the sum of their bounds. This is the general form of the unbounded-guard
  defect recorded in the contributor guide, where a `cos` kernel valid for
  `|r| ≤ π/32` was reachable from an interval it was never valid on.

Resolves F6 (two intervals, named) and the drift risk behind F8.

The block-eligibility model already in the manual belongs here as a derived
quantity: for a whole-block kernel of width `m` with per-element admission
rate `p`, the native fraction is `p^m` (`0.99³² ≈ 0.725`, measured 0.723).
With `admits` in the registry, `p` can be estimated for a user's own data by
one call.

### M4. Base-contract conformance suite

A test file that states the `AbstractFloat` contract as properties and runs
them over all three types, including non-finite, zero, and subnormal values.

- **Equality.** `NaN != NaN`; `-0.0 == 0.0`; infinities equal by sign
  whatever their low word (F13, F17).
- **Order.** `isless` is a strict total order with `-0.0` before `0.0` and
  NaN last; `isequal` distinguishes the zeros and equates NaNs; `sort`
  agrees with sorting the exact values (F14).
- **Mixed comparison is exact.** `x == y` and `x < y` against `Rational`,
  `BigFloat`, and integers agree with comparing exact values (F15).
- **Hash.** `isequal(a, b) ⇒ hash(a, h) == hash(b, h)` across `DoubleFloat`,
  `Float64`, `BigFloat`, `Rational`, and integers (F1).
- **Construction.** `T(x)` is exact whenever `x` is representable in `T`,
  for every `Real` subtype (F4).
- **Round trips.** `parse(T, string(x)) == x`; `nextfloat(x) > x`;
  `prevfloat(nextfloat(x)) == x`.
- **Keywords.** Every keyword-accepting method is called with each keyword
  (F3).

Reference definitions, verified against the cases above:

```julia
==(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T} =
    (x.hi == y.hi) & ((x.lo == y.lo) | !isfinite(x.hi))

isequal(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T} =
    isequal(x.hi, y.hi) & ((x.lo == y.lo) | !isfinite(x.hi))

isless(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T} =
    isless(x.hi, y.hi) | (isequal(x.hi, y.hi) & isfinite(x.hi) & (x.lo < y.lo))
```

The hash must agree with `Base`'s generic `hash(::Real, h)`, which is built
on `decompose`. That requires two repairs, in order:

1. Make `decompose` exact (F16). For finite `x`, combine the integer
   decompositions of `hi` and `lo` on their common power of two, using
   `BigInt` when the exponent gap exceeds 64 bits; for non-finite `x`,
   return `decompose(x.hi)`.
2. Define `hash(x, h)` as `hash(x.hi, h)` when `lo` is zero or `hi` is not
   finite, and otherwise defer to the generic method. Delete the three
   current methods, two of which belong to the unconstructible nested type.

For F5, add `floatmin_full(T) = floatmin(F) * 2^precision(F)` (`2^-969` for
`Double64`), document `floatmin` as the smallest normal head, and use the
one threshold in the Technical Guide and the Accuracy Report.

### M5. Sculpt the dependency surface

| Layer | Contents | Dependencies |
|:--|:--|:--|
| Core | type, invariant, arithmetic, elementary functions, I/O, batches | `Base`, `Printf`, `Random`, `LinearAlgebra` |
| Extension: linear algebra | `eigen`, `schur`, `svd`, matrix functions | GenericLinearAlgebra, GenericSchur |
| Extension: special functions | `erf`, `gamma`, Bessel | SpecialFunctions, Quadmath |

Julia 1.10 supports package extensions, so the declared minimum already
permits this. The core row is only true once Quadmath is off the core
paths (F18). That needs, in the core and without `Float128`: digit
generation for `string`; a rescaled `exp` for the top band of `sinh` and
`cosh`; exact reduction modulo 2 for `sinpi` and `cospi`; `asin`, `acos`,
and two-argument `atan` composed from the existing `atan` and `sqrt`
kernels; and a large-argument reduction for `sin` and `cos`, by `BigFloat`
(which is part of `Base`) until a native one exists.

An extension cannot add exports to its parent. That is harmless here:
`erf`, `gamma`, and the Bessel names belong to SpecialFunctions, and `eigen`
and `schur` to LinearAlgebra, so a client who loads those packages has the
names. A `Double64` matrix passed to `eigen` without the extension loaded
should produce an error hint naming the packages to load. It is a breaking change for users who rely on `gamma` or
`eigen` arriving with `using DoubleFloats`, so it belongs to 2.0, with an
upgrade-guide entry naming the package to load for each function. It also
removes the class of failure in F10, where a transitive package breaks
loading of the arithmetic core.

Independently of extensions: test the declared minimum (`1.10`) and the
current release in CI, trigger on `main`, and raise compat lower bounds to
versions that are actually tested.

### M6. An evidence pipeline with provenance

- Each generated report records Julia version, CPU target, package
  revision, seed, and sample size in a header, and one report uses one
  toolchain.
- Before/after comparisons move to a changelog (`NEWS.md`), keyed by
  release. The manual shows the current state only.
- Planning notes leave the published path. What they established moves into
  the registry (as bounds and ranges) or the changelog (as decisions).
- `docs/make.jl` stops rewriting links. Pages that the manual needs live in
  `docs/src/`; cross-references use Documenter `@ref` and `@id`. Build output
  is untracked.
- State support levels in the type table: `Double64` native; `Double32`
  native on listed routes, otherwise computed in `Double64`; `Double16`
  computed in `Double64`.

Resolves F8, F9, F11.

## 6. The re-presented package

### Manual, in four layers

| Layer | Question answered | Pages |
|:--|:--|:--|
| **Use** | How do I compute with it? | Overview; construct, display, parse; scalars, vectors, matrices |
| **Contract** | What is promised? | Invariant and representation limits; guarantee tiers; per-operation contract table (generated); `Base` conformance |
| **Mechanism** | How is the promise kept? | Error-free transformations; reduction and reconstruction; route selection; adding a route |
| **Evidence** | How do I know? | Accuracy report; benchmark report; crossover model; reproduction |

The contract layer is new. The other three exist and are re-sorted. The
current "Adding New Functions" page becomes "Adding a route": a new function
is a route plus a kernel plus a fixture, and the checklist is what CI
rejects.

The first page changes its opening claim from capability to contract:

> `Double64` is a pair of `Float64` values holding 106 significand bits.
> Addition and multiplication carry proved error bounds. Elementary
> functions carry measured bounds below 2.2 working units on documented
> ranges. Every operation says which.

### Source tree

```
src/
  core/        type, invariant, constructors, conversion, comparison, hash
  eft/         error-free transformations (tier E)
  arith/       double-word kernels with cited bounds (tier B)
  routes/      Route type, `routes` methods, `evaluate`
  elementary/  kernels only; guards live in the registry
  batch/       driver, block selection, repair
  io/          string, show, parse
ext/
  DoubleFloatsLinearAlgebraExt/
  DoubleFloatsSpecialFunctionsExt/
```

The split that matters is `elementary/` from `routes/`: kernels state their
precondition, the registry owns admission. Today both are fused inside
functions such as `exp`, which is why the ranges must be transcribed by hand.

## 7. Sequence

Everything in this document ships in 2.0. The 1.x line receives no changes
from this plan. The steps are stages of the 2.0 development cycle, ordered
so that each is reviewable on its own and later stages build on earlier ones.

| Step | Work | 2.0 stage | Resolves |
|:--|:--|:--|:--|
| 1 | Conformance suite; equality, order, hash, `decompose`, mixed `isapprox`, exact construction and rational comparison | alpha 1 | F1, F3, F4, F13–F16 |
| 2 | Normalizing constructors; raw constructor internal; non-finite rule; `isnormalized`; delete nested-type methods | alpha 1 | F2, F11, F17 |
| 3 | CI on `main`, on Julia 1.10 and current; tighten compat; untrack build output | alpha 1 | F9, F10 |
| 4 | Tier, metric, and bound on reports; raise sample sizes; one `floatmin_full` | beta 1 | F5, F7 |
| 5 | Route type; batch kernels converted; batch admission table generated | beta 1 | F6 (batch) |
| 6 | Scalar routes converted, each benchmarked against its predecessor; seam and totality tests | beta 1 | F6, F8 |
| 7 | Manual re-layered; history to `NEWS.md` | beta 1 | F8, F9, F11 |
| 8 | Quadmath off core paths: native or `BigFloat` routes for the functions in F18 | beta 2 | F18 |
| 9 | Extensions for linear algebra and special functions, with error hints | beta 2 | M5 |

The invariant (step 2) moves ahead of the registry because every bound the
registry records assumes normalized inputs. Stage names match the migration
table in `apotheosis_from_fable52.md`, whose alpha 2 stage covers display.

## 8. Acceptance criteria

The apotheosis is reached when each of these is mechanically true.

1. No public constructor accepts an unnormalized pair without normalizing
   it, and every route's test asserts `𝒩` on its outputs.
2. The conformance suite passes for `Double64`, `Double32`, and `Double16`.
3. Every exported operation has a tier and a bound in a generated table,
   and a test that fails if the bound is exceeded.
4. Every admission range printed in the manual is emitted from the registry.
5. Every route boundary has a seam test, and every route chain is total.
6. Each report names one toolchain, one revision, one seed, and its sample
   sizes.
7. `using DoubleFloats` loads no package outside the standard library, and
   no core route calls `Float128`.
8. CI exercises the oldest declared Julia version.

All eight are release criteria for 2.0.

## 9. Revision record

This document was reviewed against the code after first writing. Changes:

| Item | Was | Now |
|:--|:--|:--|
| Hash remedy (M4) | Relied on `decompose`, "already defined" | `decompose` is broken (F16); repair it first |
| Comparison (M4) | Listed total order as a property to test | Three verified violations added (F13–F15) with reference definitions |
| Invariant (M1) | Required `lo = hi` or NaN for non-finite values | Non-finite low word is ignored; matches both stored forms (F17) |
| Checked mode (M1) | Run-time global switch | Removed; `𝒩` is asserted by route tests |
| Route record (M3) | Abstract fields, an undefined `Interval`, dispatch through `@generated` | Concrete record, `routes` as a method, tuple recursion; prototype verified to inline |
| Tier B constants (M2) | `c = 3`, `c = 7` | Published forms, preconditions, division reclassified, items to confirm marked |
| Sampling rule (M2) | "Bound on the failure probability" | States what `3/n` does and does not bound; metrics named |
| Full-precision threshold (F5) | `2^-969`, then `2^-970` | `2^-969`, derived; the package's three inconsistent statements noted |
| Dependencies (M5) | Core described as free of numerical dependencies | Quadmath is on core paths (F18); the required kernels are listed |
| Export count (§2) | 68 | 67 (the module name was counted) |
| Nested types (F11) | Unused methods | Also a stack overflow in `convert` |

