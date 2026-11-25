# Apothic

The transformation plan for DoubleFloats 2.0. `apothecary.md` says what the
package becomes. This document says how the present source is turned into
it: the target architecture at three levels, the order of work, and for
every work item what changes, what is tested first, and when it is done.

Where the two documents differ on *what* 2.0 does, `apothecary.md` governs.
Where they differ on *order, file paths, or method*, this one governs.

## 0. Reading this document

### 0.1 The goal

The finished tree should read as if it had been designed this way from the
first commit. Concretely:

- no file, name, or comment refers to an "old" and a "new" way;
- no compatibility layer exists except the deprecations of apothecary §9,
  which live in one file;
- no fact (a range, a bound, a constant) is stated in two places;
- every public behaviour has a test that would fail without it;
- the history is a sequence of small commits, each of which builds, passes
  its tests, and does one kind of thing.

A reader who compares the released 2.0 with this plan should find the same
files, the same signatures, and the same order of dependencies.

### 0.2 Standing

- Rulings R1–R8 of apothecary §2.1 are applied. R5–R7 are this plan's
  D14–D16, approved on 2026-11-25.
- No ruling is open. D1–D5, D7–D10, D12, and D13 were accepted at their
  recommended option on 2026-11-25 (R8).

### 0.3 Evidence labels

- *Verified*: executed on 2026-11-25 against package 1.13.3 with Julia
  1.13.3 on x86_64, as a prototype beside the package.
- *Sketch*: written to the design, not executed.
- *Confirm*: rests on recollection or on a platform not available here.

### 0.4 Notation

`F` is the word type and `p` its precision. `u = 2^-p`. `ε_D = 4u²`. `𝒩` is
the normalization invariant `hi = RN(hi + lo)`. Work items keep the
identifiers of apothecary §11 (W1.1 … W4.8); items added here are numbered
W0.x and W5.x.

## 1. Method

### 1.1 Four kinds of commit

Every commit is exactly one of these. The kind is the first word of the
commit subject.

| Kind | Changes | Proof it is safe |
|:--|:--|:--|
| `move` | Where code lives, how it is named, how it is factored | The golden corpus (§1.2) is bit-identical before and after |
| `fix` | A result a client can observe | A test written first, shown failing, then passing; one line in the upgrade guide; corpus entries updated in the same commit |
| `add` | New API or new internal mechanism, nothing existing altered | New tests; corpus unchanged |
| `drop` | Removes code or a name | Corpus unchanged, or a deprecation test |

A commit that needs two kinds is two commits. This is the rule that keeps
the history readable and makes every regression findable by bisection.

### 1.2 The golden corpus

Refactoring floating-point code is safe only when "same result" means "same
bits". The corpus makes that checkable.

- **Inputs.** For every public function and type: a fixed list of structured
  points (special values, both sides of every route boundary, subnormal and
  extreme heads) plus 4,096 pseudo-random points. The generator is a
  SplitMix64 written in the test file, so the stream does not depend on
  Julia's `Random` implementation.
- **Record.** For each (function, type, block of 256 inputs), a CRC-32 of
  the output words. Stored as one text file, `test/golden/corpus.toml`,
  small enough to diff.
- **Baseline.** Generated once from the head of `release-1.13` (commit
  `b186e440`, version 1.13.3). No `v1.13.3` tag exists: versions 1.13.0 to
  1.13.3 were never pushed or registered, and the remote default branch is
  at 1.12.0.
- **Use.** `test/golden.jl` recomputes and compares on every CI run.
- **Diagnosis.** `test/golden/diff.jl` takes two revisions and prints the
  first differing inputs with both outputs.

A `move` commit must leave the file untouched. A `fix` commit edits exactly
the entries its upgrade-guide line predicts. An unexpected change in the
corpus is a defect in the commit, found before review.

Threaded and batch kernels are in the corpus too, compared element by
element with the batch entry points.

### 1.3 Test first, in three steps

For each `fix` item:

1. Add the property test, marked `@test_broken`. CI stays green and the
   defect is now on record in the suite.
2. Make the change. The test passes, so `@test_broken` itself fails; flip
   it to `@test` in the same commit.
3. A stage gate is "no `@test_broken` remains for this stage".

### 1.4 Choices this plan raised, now ruled

| # | Question | Ruling | Recorded as |
|:--|:--|:--|:--|
| D14 | Branch model | Cut `release-1.13` from the present default branch; the default branch becomes `2.0.0-DEV` | R5 |
| D15 | When the source tree is rearranged | First (Stage 0), as `move` commits proved by the corpus, so every later change lands in its final file | R6 |
| D16 | Constructor result for a non-finite sum | `lo = 0`, so values built by a client have one stored form | R7 |

D15 is what makes the history read as native development: `git log` on any
final file shows its real evolution, and `git mv` keeps blame.

D16 does not contradict D1. D1 says no function may *read* the low word of
a non-finite value. D16 says the constructor happens to *write* zero.
Kernels remain free to leave anything there.

### 1.5 Definition of done for an item

1. Its tests exist and pass on the full matrix.
2. The corpus is unchanged (`move`, `add`, `drop`) or changed as predicted
   (`fix`).
3. The benchmark job shows no regression beyond noise against the 1.13.3
   baseline, or the regression is a stated consequence of a `fix`.
4. Docstrings for any name it adds or changes are present with a doctest.
5. The ledger row in apothecary §12 is marked done with the commit range.

## 2. High-level design

### 2.1 Layers

One module. Layers are directories, loaded in this order. A layer may use
only the layers above it in the table.

| # | Layer | Directory | Holds | Tier it can carry |
|:--|:--|:--|:--|:--|
| 1 | Error-free transformations | `eft/` | `two_sum`, `two_prod`, and relatives on plain `F` | exact |
| 2 | Value | `core/` | The type, the sealed constructor, accessors, reflection, predicates | |
| 3 | Arithmetic | `arith/` | Double-word kernels on tuples; `Base` operators; rounding; `fma` | bounded or sampled |
| 4 | Base contract | `contract/` | Conversion, comparison, `decompose`, `hash`, promotion | exact |
| 5 | Routes | `routes/` | `Route`, `Tier`, `Metric`, `evaluate`, `guarantee`, `route` | |
| 6 | Constants | `constants/` | Two- and three-word constants; coefficient tables | |
| 7 | Elementary | `elementary/` | Kernels and their `routes` methods, one file per family | sampled |
| 8 | Batch | `batch/` | `simdmap!`, block selection, repair, threading | per route |
| 9 | Text | `io/` | Digits, `show`, `parse`, `Printf` hook | exact |
| 10 | Random | `random/` | `rand`, `randn`, `randpm` | |
| 11 | Matrices | `linalg/` | Compensated products, matrix functions not needing Schur | residual |
| 12 | Surface | `DoubleFloats.jl`, `deprecated.jl` | Exports, `public`, deprecations | |
| | Extensions | `ext/` | Schur-based linear algebra, special functions, `Float128` | |

Two observations fix the order.

- `eft/` comes before the type. Error-free transformations are functions
  of machine floats and know nothing of `DoubleFloat`. Placing them first
  lets the constructor use `two_sum`, which is what makes law 1 structural
  (§4.1).
- `contract/` comes after `arith/`. Exact mixed comparison and exact
  construction from integers need exact subtraction, and `decompose` needs
  the accessors.

### 2.2 The dependency rule, checked

`test/layering.jl` loads the include list one prefix at a time into a fresh
module and requires each prefix to load. This catches a type, constant, or
macro used above its layer. It does not catch a function called above its
layer, because Julia resolves calls late; a second check scans each
directory for identifiers defined in a later one. The scan is a lint with
an allow-list, not a proof, and the document says so.

### 2.3 How the four laws map to structure

| Law (apothecary §1) | Structural carrier |
|:--|:--|
| One invariant | The struct has no public inner constructor; only `unsafe_double` can make an unnormalized value, and it is internal (§4.1) |
| `Base` is the interface | `contract/` and `io/` are the only places `Base` generic functions on the value are defined outside arithmetic; `test/conformance.jl` mirrors them file for file |
| Every claim has a tier | A function reaches a kernel only through `evaluate(routes(f, T), x)`; a kernel without a `Route` is unreachable |
| One source per fact | Ranges and bounds are fields of `Route` constants; the manual tables and the tests read them |

### 2.4 What does not change

The numerical kernels. With the exceptions listed in §6 (Stage 4), every
kernel keeps its arithmetic, its coefficients, and its bits. The
transformation moves them, names them, wraps them in routes, and repairs
what surrounds them.

## 3. Mid-level design

### 3.1 Final source tree

```
src/
  DoubleFloats.jl          module, includes, exports, public
  deprecated.jl
  eft/
    sums.jl                two_sum, two_diff, two_hilo_sum, three_sum, ...
    products.jl            two_prod, two_square, ...
    quotients.jl           least-error division helpers
  core/
    type.jl                MultipartFloat, DoubleFloat, unsafe_double, aliases
    constructors.jl        normalizing pair constructor; from Real
    accessors.jl           HI, LO, HILO, isnormalized, normalize
    reflection.jl          precision, eps, ulp, floatmin, floatmin_full, floatmax
    predicates.jl          iszero, isnan, isinf, isinteger, signbit, ...
    specialvalues.jl       zero, one, typemin, typemax
  arith/
    kernels.jl             add_dddd_dd, mul_dddd_dd, dvi_dddd_dd, ... on tuples
    operators.jl           +, -, *, /, inv, sqrt, cbrt, ^ on DoubleFloat and mixed
    fma.jl
    rounding.jl            floor, ceil, trunc, round, modf, intpart, fracpart
    divrem.jl              div, rem, mod, fld, cld, divrem, fldmod
    hypot.jl
  contract/
    convert.jl             to and from IEEEFloat, Integer, BigFloat, Rational
    decompose.jl           Base.decompose, Rational, rationalize
    compare.jl             ==, <, <=, isless, isequal; exact mixed forms
    hash.jl
    promote.jl
    approx.jl              isapprox
  routes/
    types.jl               Tier, Metric, Route, Batch, Guarantee
    evaluate.jl            evaluate
    guarantee.jl           routes fallback, guarantee, route
  constants/
    double.jl              two-word constants
    triple.jl              three-word type and constants used for reduction
    tables.jl              coefficient tables built in BigFloat at load
  elementary/
    exp.jl                 exp, exp2, exp10, expm1
    log.jl                 log, log2, log10, log1p
    pow.jl                 ^ with DoubleFloat exponent
    reduce.jl              modulo pi/2, modulo 2 (for the pi forms)
    trig.jl                sin, cos, tan, cot, sincos, cis
    trigpi.jl              sinpi, cospi, tanpi, sincospi, cispi
    arctrig.jl             atan, atan(y, x), asin, acos, acsc, asec, acot
    hyperbolic.jl          sinh, cosh, tanh, csch, sech, coth
    archyperbolic.jl       asinh, acosh, atanh, acsch, asech, acoth
    double32.jl            Double32 native routes
    complex.jl
    agm.jl
  batch/
    blocks.jl              snapshot, overlap, block selection, repair
    simdmap.jl             simdmap!, simdmap, threading
    broadcast.jl           the transparent path (W4.8), if it ships
  io/
    digits.jl              shortest round-trip digit generation
    string.jl              string, print, stringtyped
    show.jl                show, repr form, compact, showtyped
    parse.jl               tryparse, parse, string macros
    printf.jl              Printf.tofloat
  random/
    rand.jl
  linalg/
    matmul.jl              compensated products
    matfun.jl              matrix functions without a Schur form
    sylvester.jl
ext/
  DoubleFloatsGenericLinearAlgebraExt/   eigen, schur, svd, Schur-based matrix functions
  DoubleFloatsSpecialFunctionsExt/       erf, gamma, Bessel, ellipk
  DoubleFloatsQuadmathExt/               Float128 conversion and promotion
test/
  Project.toml
  runtests.jl
  support/                 SplitMix64, exact reference, generators
  golden.jl  golden/corpus.toml  golden/diff.jl
  conformance/             one file per file of src/contract and src/io
  routes.jl                P-TOTAL, P-NORM, P-BOUND, P-SEAM, P-IDENT, P-ADMIT
  gate.jl                  the R3 gate harness
  layering.jl  quality.jl  (Aqua, JET, ExplicitImports)
  unit/                    the present per-topic files
benchmark/
  benchmarks.jl            the suite, in the layout PkgBenchmark expects
  baseline-1.13.3.json
```

### 3.2 File map, present to final

Every present file has one destination. Files marked *split* are divided
by `move` commits before any content changes.

| Present | Final | Note |
|:--|:--|:--|
| `Double.jl` | `core/type.jl`, `core/constructors.jl`, `core/reflection.jl`, `contract/hash.jl`, `contract/decompose.jl` | *split* |
| `math/errorfree.jl`, `math/leasterror.jl` | `eft/sums.jl`, `eft/products.jl`, `eft/quotients.jl` | *split* |
| `type/constructors.jl`, `type/intraconstructors.jl` | `core/constructors.jl` | merged |
| `type/convert.jl` | `contract/convert.jl` | |
| `type/compare.jl` | `contract/compare.jl` | |
| `type/promote.jl` | `contract/promote.jl` | |
| `type/predicates.jl` | `core/predicates.jl` | |
| `type/specialvalues.jl` | `core/specialvalues.jl`; `nan`, `inf`, … to `deprecated.jl` | *split* |
| `type/string.jl` | `io/string.jl` | |
| `type/show.jl` | `io/show.jl` | |
| `type/parse.jl` | `io/parse.jl` | |
| `type/quadmath.jl` | `ext/DoubleFloatsQuadmathExt/` | only when R3's retained list is empty |
| `math/ops.jl`, `ops/op_*_dd.jl` | `arith/kernels.jl` | ten files become two |
| `ops/op_*_db.jl`, `ops/arith.jl`, `arithmetic/mixedarith.jl` | `arith/operators.jl` | |
| `math/prearith/prearith.jl` | `core/predicates.jl`, `arith/rounding.jl` | *split* |
| `prearith/floorceiltrunc.jl` | `arith/rounding.jl` | |
| `prearith/divrem.jl` | `arith/divrem.jl` | |
| `arithmetic/fma.jl` | `arith/fma.jl` | |
| `arithmetic/modpi.jl` | `elementary/reduce.jl` | |
| `arithmetic/normalize_hypot.jl` | `core/accessors.jl` (`normalize`), `arith/hypot.jl` | *split* |
| `arithmetic/complex/pow.jl` | `elementary/complex.jl` | |
| `doubletriple/double_consts.jl` | `constants/double.jl` | |
| `doubletriple/triple*.jl` | `constants/triple.jl` | three files become one |
| `elementary/sequences.jl` | `constants/tables.jl` | |
| `elementary/explog.jl`, `fast_explog.jl` | `elementary/exp.jl`, `log.jl`, `pow.jl` | *split*; the nested `include` is removed |
| `elementary/trig.jl` | `elementary/trig.jl`, `trigpi.jl`; constants to `constants/double.jl` | *split* |
| `elementary/local_hyperbolic.jl` | `elementary/hyperbolic.jl`, `trig.jl` | *split* by function |
| `elementary/hyptrig.jl` | `elementary/hyperbolic.jl` | |
| `elementary/arctrig.jl` | `elementary/arctrig.jl` | |
| `elementary/archyptrig.jl` | `elementary/archyperbolic.jl` | |
| `elementary/templated.jl` | deleted | nested-type methods (F11) |
| `elementary/double32.jl` | `elementary/double32.jl` | |
| `elementary/complex.jl` | `elementary/complex.jl` | |
| `elementary/simd.jl` | `batch/blocks.jl`, `batch/simdmap.jl` | *split* |
| `linearalgebra/ddmatmul.jl` | `linalg/matmul.jl` | |
| `linearalgebra/matfun.jl`, `matrixfunction.jl`, `support.jl` | `linalg/matfun.jl`; Schur-based parts to the extension | *split* |
| `linearalgebra/sylvester.jl` | `linalg/sylvester.jl` or the extension | decided by whether it needs Schur |
| `linearalgebra/eigen.jl` | `ext/DoubleFloatsGenericLinearAlgebraExt/` | |
| `special/agm.jl` | `elementary/agm.jl` | |
| `special/bessel.jl`, `elliptic.jl`, `gamma_erf.jl`, `specialfunctions.jl` | `ext/DoubleFloatsSpecialFunctionsExt/` | |
| `extras/random.jl` | `random/rand.jl` | |
| `extras/misc.jl` | by content: `contract/approx.jl`, `contract/decompose.jl`, others | *split* |
| `extras/macros.jl` | `deprecated.jl` | |
| `perf/*.jl` | `benchmark/benchmarks.jl` | |

The destination of each function in a *split* file is settled when the
split is made, by this test: a function goes to the lowest layer that
contains everything it calls.

### 3.3 Subsystem contracts

Each layer has a stated interface to the layers below it. Nothing else
crosses.

**`eft/`.** Pure functions `(F...) -> NTuple{N,F}`. No `DoubleFloat`. Each
has a docstring giving the identity it satisfies (`a + b = s + e` exactly)
and its preconditions (no overflow; for `two_hilo_sum`, `|a| ≥ |b|`). Tier
exact. Tested against `BigFloat` on random and structured words.

**`core/`.** Provides the type and the only two ways to make a value:
`DoubleFloat{F}(hi, lo)` (normalizes) and `unsafe_double(F, hi, lo)` (does
not). Provides `HI`, `LO`, `HILO`. Everything above constructs results with
`unsafe_double` when the kernel has established `𝒩`, and with the
constructor otherwise.

**`arith/`.** Two sublayers. `kernels.jl` works on tuples `(hi, lo)` and
returns tuples; it is where the cited algorithms live, one function per
algorithm, each with its citation, bound, and preconditions in a docstring.
`operators.jl` defines `Base` operators by unpacking, calling a kernel, and
repacking, with non-finite handling. Batch code calls the tuple kernels
directly; this is the present design and is kept.

**`contract/`.** Everything a generic Julia program assumes about a `Real`.
No numerical approximation anywhere in this layer: each function is exact
or throws.

**`routes/`.** Three types, three functions. Knows nothing of any
particular function. Detailed in §4.4.

**`elementary/`.** One file per family, in a fixed internal order:
constants specific to the family; kernels (`_name_region`), each stating a
precondition and nothing about admission; `Route` constants; `routes`
methods; the `Base` method, which is one line. A reader can open any family
file and read it top to bottom.

**`batch/`.** Takes a tuple of batch `Route`s and vectors. Owns overlap
detection, block selection, scalar repair of non-admitted blocks, and
threading. Knows nothing of any particular function.

**`io/`.** `digits.jl` is the only place that turns a value into decimal
digits. `string.jl`, `show.jl`, and `printf.jl` format what it returns.
`parse.jl` is the only place that turns text into a value.

**Extensions.** Each adds methods to functions owned by another package
for types owned by this one. None defines a new name.

### 3.4 Test architecture

| Suite | File | Asserts | Runs |
|:--|:--|:--|:--|
| Golden | `test/golden.jl` | Bits equal the recorded corpus | Every CI run |
| Conformance | `test/conformance/*.jl` | P-ORD, P-TXT, conversion, parsing, promotion | Every CI run |
| Routes | `test/routes.jl` | The six route properties, iterating `methods(routes)` | Every CI run, 10⁴ samples |
| Gate | `test/gate.jl` | R3's four conditions per candidate | On demand and in the report job |
| Quality | `test/quality.jl` | Aqua, JET on the public entry points, ExplicitImports | Every CI run |
| Layering | `test/layering.jl` | §2.2 | Every CI run |
| Unit | `test/unit/*.jl` | The present per-topic tests | Every CI run |
| Report | `docs/reports/*.jl` | Regenerates accuracy and benchmark reports at 10⁶ | Scheduled |
| Downstream | CI job | Dependents' own tests against the branch | Scheduled and on release candidates |

`test/support/reference.jl` holds the single exact reference used by every
suite: a value's exact `BigFloat` (precision chosen from the words), and
`relerr(f, x)` in units of `ε_D`. The present `test/runtests.jl` redefines
`Base.isapprox` for all `IEEEFloat` pairs; that is type piracy inside the
test process and is replaced by a named helper in `support/`.

### 3.5 Continuous integration

| Job | Matrix | Purpose |
|:--|:--|:--|
| `test` | Julia 1.12, current, pre-release; Linux, macOS, Windows | All suites |
| `docs` | current | `checkdocs = :exports`, doctests, generated tables |
| `benchmark` | current, Linux | Compare against `baseline-1.13.3.json`; comment on the pull request |
| `invalidations` | current | Already present; kept |
| `report` | current, scheduled | 10⁶-sample reports with provenance |
| `downstream` | current, scheduled | Reverse-dependency tests |

*Confirm* the macOS architecture question of apothecary §8.1 here: hosted
macOS runners are ARM, and the present matrix asks for `x64`.

## 4. Low-level design

Signatures and reference bodies for the parts that are new or rebuilt.
Kernels that only move are not repeated.

### 4.1 The value (`core/type.jl`, `core/constructors.jl`)

*Verified* on a stand-in type: the pattern compiles, the default
constructors are suppressed, a wrong-typed call is a `MethodError`, and the
normalizing constructor allocates nothing.

```julia
abstract type MultipartFloat <: AbstractFloat end

struct DoubleFloat{F<:IEEEFloat} <: MultipartFloat
    hi::F
    lo::F
    # The only way to build a pair without normalizing. Internal.
    global unsafe_double(::Type{F}, hi::F, lo::F) where {F<:IEEEFloat} = new{F}(hi, lo)
end

@inline function DoubleFloat{F}(hi::F, lo::F) where {F<:IEEEFloat}
    s, e = two_sum(hi, lo)
    return unsafe_double(F, s, ifelse(isfinite(s), e, zero(F)))   # D16
end
DoubleFloat(hi::F, lo::F) where {F<:IEEEFloat} = DoubleFloat{F}(hi, lo)

const Double64 = DoubleFloat{Float64}
const Double32 = DoubleFloat{Float32}
const Double16 = DoubleFloat{Float16}
```

Consequences:

- `F<:IEEEFloat` in the struct makes `DoubleFloat{Double32}` impossible to
  name, which removes F11 at the type level.
- Every internal site that today writes `DoubleFloat{T}(hi, lo)` after a
  kernel becomes `unsafe_double(T, hi, lo)`. This is a mechanical `move`
  commit; the corpus proves that no site depended on the missing
  normalization.
- `isnormalized(x) = (x.hi + x.lo == x.hi) | !isfinite(x.hi)`.

From a `Real` (*verified* for the integer method: exact on `2^62 + 1`,
`typemax(Int64)`, `typemin(Int64)`, `typemax(UInt64)`, `Int128(2)^100 + 1`,
`big(2)^105 + 1`; 1.13.3 is inexact on the first two):

```julia
DoubleFloat{F}(x::F) where {F<:IEEEFloat} = unsafe_double(F, x, zero(F))
DoubleFloat{F}(x::IEEEFloat) where {F<:IEEEFloat} = _from_exact(F, x)

function DoubleFloat{F}(x::Integer) where {F<:IEEEFloat}
    hi = F(x)
    isfinite(hi) || return unsafe_double(F, hi, zero(F))
    return DoubleFloat{F}(hi, F(_exact_diff(x, hi)))
end
_exact_diff(x::Base.BitInteger64, hi) = Int128(x) - Int128(hi)
_exact_diff(x::Integer, hi) = big(x) - big(hi)
```

`Rational`, `BigFloat`, and `Irrational` follow the same shape: `hi = F(x)`,
then `lo = F(x − hi)` with the subtraction carried out exactly in the
argument's own arithmetic. One method per argument kind replaces the
per-type copies and the `@eval` loop in `Double.jl`.

### 4.2 The contract (`contract/`)

Same-type comparison, `decompose`, and `hash` are as apothecary §4.1 gives
them, *verified*.

Exact comparison with a `Rational` (*verified* against exact rational
arithmetic on 20,000 random pairs; `Double64(1)/3 == 1//3` becomes `false`):

```julia
function Base.:(==)(x::DoubleFloat, q::Rational)
    isfinite(x.hi) || return false
    n, e, s = Base.decompose(x)            # x == s * n * 2^e exactly
    m = s * n
    return e >= 0 ? (m << e) * denominator(q) == numerator(q) :
                    m * denominator(q) == (big(numerator(q)) << -e)
end
```

`<` has the same body with `<`. Comparison with `IEEEFloat` and `Integer`
widens the other operand exactly with §4.1 and compares pairs, so it does
not allocate. Comparison with `BigFloat` compares against the exact
`BigFloat` of the pair.

Conversion to an integer (*verified*: `typemax(Int64)` round-trips;
`Int64(Double64(2.5))` and `Int64(Double64(2.0)^70)` throw `InexactError`):

```julia
function (::Type{T})(x::DoubleFloat) where {T<:Base.BitInteger64}
    (isfinite(x.hi) & isinteger(x.hi) & isinteger(x.lo)) ||
        throw(InexactError(nameof(T), T, x))
    return T(Int128(x.hi) + Int128(x.lo))
end
```

`Int128`, `UInt128`, and `BigInt` use the `BigInt` sum. Promotion is the
table of apothecary §4.4, written as `promote_rule` methods with no
`@eval`.

### 4.3 Text (`io/`)

`digits.jl` exposes one internal function:

```julia
# Shortest decimal digits d and exponent e such that the text round-trips.
_shortest(x::DoubleFloat) -> (negative::Bool, digits::String, exponent::Int)
```

Method (*verified* as a linear search; the bisection is a *sketch*): form
the exact `BigFloat`; the lower limit is `⌈2p·log₁₀2⌉` digits; double the
count until the round trip `parse(T, text) === x` holds, then bisect
between the last failure and the first success. `string`, `show`, and the
compact form all format the triple this returns; none calls MPFR itself.

`show.jl`:

```julia
function Base.show(io::IO, x::DoubleFloat{F}) where {F}
    if get(io, :compact, false)::Bool
        _print_rounded(io, x, 6)
    elseif get(io, :typeinfo, Any) === DoubleFloat{F}
        print(io, x)
    else
        print(io, _macro_prefix(F), '"'); print(io, x); print(io, '"')
    end
end
```

The one-argument `show(x)` methods are dropped; `Base` supplies them.

### 4.4 Routes (`routes/`)

```julia
@enum Tier exact bounded sampled
@enum Metric forward lattice residual
struct Batch end

struct Route{A,K}
    name::String
    admits::A
    kernel::K
    valid::NTuple{2,Float64}
    measured::NTuple{2,Float64}
    tier::Tier
    metric::Metric
    bound::Float64
    identical::Bool
    precondition::String     # "" when none beyond normalization
    source::String           # citation for `bounded`; report section for `sampled`
end

@inline evaluate(rs::Tuple{Route}, x) = first(rs).kernel(x)
@inline evaluate(rs::Tuple, x) =
    first(rs).admits(x) ? first(rs).kernel(x) : evaluate(Base.tail(rs), x)

routes(f, ::Type{T}) where {T} = ()          # no contract declared
```

Two fields are added to apothecary §7.1. `precondition` is what R3 requires
of a retained `Float128` kernel. `source` is where a reader goes for the
proof or the sample.

For a `sampled` route, `bound` is the ceiling the route is held to, not the
largest error seen. The largest error seen is in the report. This keeps the
source stable when a report is regenerated.

Rules for chains:

- Special values are routes. A chain typically begins with a route whose
  `admits` is `x -> !isfinite(HI(x))`, tier `exact`. Nothing is handled
  outside the chain.
- The last route's `admits` is `Returns(true)`. The one-element method of
  `evaluate` never calls it, so it costs nothing; P-TOTAL checks its type.
- "Computed in `Double64`" is a route: `kernel = x -> Double32(f(Double64(x)))`.
  The support levels of apothecary §9 are then generated from the routes
  and not written by hand.
- `guarantee(f, T)` folds the chain: weakest tier, largest bound,
  intersection of preconditions.

The route tests discover their subjects by reflection over
`methods(routes)` (*sketch*), so adding a `routes` method enrols it in
every property with no list to maintain.

### 4.5 A family file, end to end

The shape every file in `elementary/` takes after W3.4, shown for `exp`.
Kernel bodies are the present ones, unchanged.

```julia
# --- kernels: each states its precondition; none decides admission ---------
@inline _exp_fine(x::Double64) = ...        # precondition: |x| <= 0.36
@inline _exp_table(x::Double64) = ...       # precondition: |x| <= 709
@inline _exp_edge(x::Double64) = ...        # subnormal and overflow results

# --- routes ---------------------------------------------------------------
const EXP_SPECIAL = Route("special", x -> !isfinite(HI(x)), _exp_special, ...)
const EXP_FINE    = Route("fine",    x -> abs(HI(x)) <= 0.36, _exp_fine, ...)
const EXP_TABLE   = Route("table",   x -> abs(HI(x)) <= 709.0, _exp_table, ...)
const EXP_EDGE    = Route("edge",    Returns(true), _exp_edge, ...)

routes(::typeof(exp), ::Type{Double64}) = (EXP_SPECIAL, EXP_FINE, EXP_TABLE, EXP_EDGE)

# --- entry ------------------------------------------------------------------
Base.exp(x::Double64) = evaluate(routes(exp, Double64), x)
```

The names and thresholds above are placeholders for the shape. The real
ones are read from the present branch conditions when each family is
converted, and the conversion is a `move` commit: the corpus must not
change and the benchmark must not regress.

### 4.6 `sinpi` and `cospi` by exact reduction (`elementary/trigpi.jl`)

*Verified* prototype, using the present `sin` and `cos` on the reduced
argument and a two-word `π`:

```julia
# x = k/2 + r (mod 2) with |r| <= 1/4; every step exact.
@inline function _reduce_half(x::Double64)
    h = rem(HI(x), 2.0)                # exact
    r = Double64(h) + LO(x)
    k = round(Int, Float64(2r))
    return r - k / 2, mod(k, 4)
end

function Base.sinpi(x::Double64)
    r, k = _reduce_half(x)
    a = onepi * r
    return k == 0 ? sin(a) : k == 1 ? cos(a) : k == 2 ? -sin(a) : -cos(a)
end
```

Maximum relative error in units of `ε_D`, 50,000 points per row:

| Inputs | Prototype | 1.13.3 |
|:--|--:|--:|
| Dense, [0, 2] | 0.75 | 57 |
| Wide low word, [0, 2] | 0.82 | 524 |
| Near integers (offsets down to `2^-60`) | 0.75 | 3.6 × 10¹⁹ |
| Magnitudes up to `2^40` | 0.79 | 1.1 × 10¹³ |

`sinpi(Double64(1.0, 2.0^-120))` returns `-2.3634716268029e-36`, the true
value. Time 126 ns against 357 ns, no allocation. A triple-word `π` was
planned and is not needed at this accuracy. Exact zeros at integers and the
sign of zero are to be fixed by an explicit branch and a test.

### 4.7 Surface (`DoubleFloats.jl`)

The module file contains, in order: the docstring; `using` and `import`
lines naming every imported identifier (checked by ExplicitImports); the
`include` list of §3.1 in layer order; `export`; `public`; nothing else.
The 60-line `import Base:` list goes: methods are written `Base.name(...)`
at the point of definition, which is the current convention and makes each
file readable alone.

## 5. Staging

Six stages. Each ends in a tagged pre-release and a gate. Within a stage,
items are in dependency order; an item's *Needs* names what must be merged
first.

### Stage 0 — ground (no client-visible change)

Everything here is `move`, `add` (tests and tooling), or configuration. A
package built at the end of Stage 0 returns the same bits as 1.13.3 for
every corpus entry.

| Item | Kind | Work | Needs | Done when |
|:--|:--|:--|:--|:--|
| W0.1 | config | Branches per D14; version `2.0.0-DEV`; compat bounds raised so a fresh resolve loads on current Julia (a stale local manifest pinning GenericLinearAlgebra 0.4.0 fails to precompile on 1.13) | | The package loads in a fresh clone on Julia 1.12 and current |
| W0.2 | config | CI of §3.5 (`test`, `docs`, `invalidations`); this is W1.10 | W0.1 | Matrix green on the unchanged source |
| W0.3 | add | `test/Project.toml`; `test/support/`; move present tests to `test/unit/`; remove the `isapprox` piracy | W0.2 | Same tests pass |
| W0.4 | add | Golden corpus generated at the head of `release-1.13`; `test/golden.jl` | W0.3 | Corpus matches on the full matrix, or per-platform differences are found and recorded |
| W0.5 | add | `benchmark/benchmarks.jl`; `baseline-1.13.3.json`; benchmark job | W0.2 | Job reports on a no-op pull request |
| W0.6 | move | Formatter configuration and one formatting commit | W0.4 | Corpus unchanged |
| W0.7 | move | The tree of §3.1: one commit per destination directory, `git mv` first, splits second | W0.6 | Corpus unchanged; `test/layering.jl` passes |
| W0.8 | move | Sealed struct and `unsafe_double` at every internal construction site; the public pair constructor still raw | W0.7 | Corpus unchanged |
| W0.9 | move | `Base.name(...)` definitions; explicit imports; `@eval` type loops to parametric methods | W0.7 | Corpus unchanged; ExplicitImports passes |
| W0.10 | add | `CONTRIBUTING.md`: the four commit kinds, the corpus, how to add a route | W0.4 | |

W0.4 is the item most likely to surprise. If the corpus differs between
platforms on unchanged source, that is a finding about determinism
(apothecary §6.4) that must be understood before anything else moves.

**Gate 0.** Corpus identical to 1.13.3 on every platform; no benchmark
regression; tree matches §3.1.

### Stage 1 — 2.0-alpha 1: correctness

Order matters: the invariant first, then what assumes it.

| Item | Kind | Work | Needs | Test first | Upgrade-guide line |
|:--|:--|:--|:--|:--|:--|
| W1.1 | add | `test/conformance/` with every Stage 1 property as `@test_broken` | Gate 0 | | |
| W1.3a | fix | Public pair constructor normalizes (§4.1); `isnormalized`, `normalize` public | W1.1 | `isnormalized(Double64(1.0, 1.0))` | `Double64(hi, lo)` now normalizes |
| W1.3b | fix | Exact construction from `Integer`, `Rational`, `BigFloat` | W1.3a | `big(Double64(2^62 + 1)) == 2^62 + 1` | Large integers convert exactly |
| W1.3c | drop | `templated.jl` and nested-type methods | W0.8 | `DoubleFloat{Double32}` is a `TypeError` | |
| W1.2a | fix | `==`, `<`, `<=`, `isless`, `isequal` on one type | W1.3a | P-ORD, same-type part | `NaN == NaN` is `false`; `sort` orders NaN last |
| W1.4a | fix | Exact `decompose`; `Rational(x)` | W1.2a | `Rational(x) == big(x.hi) + big(x.lo)` exactly | `decompose` no longer throws |
| W1.4b | fix | `hash` | W1.4a | `isequal(a, b) ⇒ hash(a) == hash(b)` across types | `Dict` lookups by equal `Float64` keys now succeed |
| W1.2b | fix | Exact mixed comparison (§4.2) | W1.4a | P-ORD, mixed part | `Double64(1)/3 == 1//3` is `false` |
| W1.6a | fix | Integer conversion throws `InexactError` | W1.3b | `Int64(Double64(2.5))` throws | Use `round(Int, x)` or `trunc(Int, x)` |
| W1.6b | fix | `rationalize` honours `tol` | W1.4a | `rationalize(Double64(1)/3) == 1//3` | |
| W1.5 | fix | `tryparse`, `parse`, string constructor; no global precision | W1.3b | `tryparse(Double64, "x") === nothing`; `precision(BigFloat)` unchanged after a failed parse | Bad text throws `ArgumentError` |
| W1.8 | fix | Promotion table | W1.3b | `typeof(Double32(1) + 1.0) === Double64` | `Double32` with `Float64` gives `Double64` |
| W1.7a | fix | `isapprox` keywords across types | W1.8 | `isapprox(Double64(1), 1.0; rtol = 1e-3)` | |
| W1.7b | fix | `rand` grid of `2^-2p`; `randpm` on `AbstractRNG` | W1.3a | Low word is not always zero; `randpm(Xoshiro(1), Double64)` works | Random streams differ from 1.x |
| W1.7c | fix | Three-argument `@via_df32` returns `Double32` | | The call's result type | |
| W1.9 | fix | `Aqua.test_all`; the 12 ambiguities; `lerpi` and `clamp` reviewed for piracy | all above | `test/quality.jl` | |

**Gate 1.** No `@test_broken` in `test/conformance/` for Stage 1; Aqua
passes without exclusions; the corpus diff equals the union of the
upgrade-guide lines above.

Risk in this stage: W1.3a adds a `two_sum` to a constructor that may sit on
a hot path in client code. W0.8 removes it from every internal path
beforehand, so the package's own benchmarks should not move. If a client
benchmark does, the answer is the documented internal `unsafe_double`, and
that fact goes in the upgrade guide.

### Stage 2 — 2.0-alpha 2: text

| Item | Kind | Work | Needs | Test first | Upgrade-guide line |
|:--|:--|:--|:--|:--|:--|
| W2.1a | add | `_shortest` in `io/digits.jl` | W1.5 | `parse(T, text) === x` over the P-TXT classes | |
| W2.1b | fix | `string`, `print` use it; no `Float128` | W2.1a | `string(Double64(1.0, 2.0^-200))` round-trips | Printed digits change; fewer for `Double32`, exact for all |
| W2.2 | fix | `show`: macro form, `:typeinfo`, complex | W2.1b | `eval(Meta.parse(repr(x))) === x`; `repr([x])` shows bare digits | `repr` shows `df64"…"` |
| W2.3 | fix | Compact rule: six significant digits | W2.2 | A vector and a matrix of the same values print the same digits | Matrix display shortens |
| W2.4 | fix | `Printf.tofloat`; drop `ini_dec`, `fix_dec` | W2.1b | `@sprintf("%.30f", x)` equals the `BigFloat` result | `@sprintf` prints full precision |
| W2.5 | add | Exchange page; `showtyped` in shortest form | W2.2 | Doctests | |

**Gate 2.** P-TXT passes for all three types. Every doctest written so far
is regenerated once, in one commit, because every printed value changed.

Stage 2 comes before any docstring work for that reason: doctests written
earlier would all be rewritten.

### Stage 3 — 2.0-beta 1: contract

| Item | Kind | Work | Needs | Done when |
|:--|:--|:--|:--|:--|
| W3.1 | add | `routes/` (§4.4) with unit tests on a toy function | Gate 2 | Three-route toy chain inlines with no allocation in the test |
| W3.5a | add | `test/routes.jl`: the six properties over `methods(routes)`; passes vacuously | W3.1 | |
| W3.2 | add | Arithmetic audit: each kernel in `arith/kernels.jl` compared line by line with its cited algorithm; docstring with citation, bound, preconditions; `guarantee(+, T)` and relatives | W3.1 | Each entry of apothecary §6.2 is `bounded` with a line reference, or `sampled` with the difference described |
| W3.4 | move | Scalar families converted to §4.5, one family per pull request, in this order: `exp`, `log`, `hyperbolic`, `trig`, `arctrig`, `archyperbolic`, `double32`, `complex` | W3.5a | Per family: corpus unchanged; benchmark within noise; route properties pass |
| W3.3 | move | Batch kernels as routes; `batch/` reads `routes(f, T, Batch())` | W3.4 | Corpus unchanged for batch entry points; P-IDENT passes where flagged |
| W3.5b | add | `public` declarations; `simdmap!`, `simdmap`, `guarantee`, `route` documented | W3.3 | C14 closed |
| W3.7 | add | Report scripts read routes; provenance header; sizes per D13; `floatmin_full`; generated support table | W3.3 | Reports regenerate from a clean checkout with one command |
| W3.6 | add | Docstrings and doctests for every exported and public name; each name in the last row of apothecary §9 documented or removed | W3.5b | `checkdocs = :exports` passes |
| W3.8 | move | Manual in four layers; tables generated from routes; `make.jl` reduced; history to `NEWS.md`; planning notes out of the published path | W3.7 | Docs build with no `warnonly` |

The order of families in W3.4 is by independence: `exp` and `log` are used
by the others, so converting them first means later families call entry
points that are already routes.

If a family's conversion costs time, the fallback is specific: keep the
hand-written branch chain as the `Base` method and declare the routes
beside it, with a test that the two agree on every corpus input. The
contract is then still one object per region; only dispatch is duplicated.
That fallback is recorded per family in the route's source comment and is
a defect to retire, not a design.

**Gate 3.** Release criteria 2, 3, and 4 of apothecary §13 hold.

### Stage 4 — 2.0-beta 2: structure

| Item | Kind | Work | Needs | Done when |
|:--|:--|:--|:--|:--|
| W4.0 | add | `test/gate.jl`: the four R3 conditions, both input classes, endpoint-biased sampling, the constructed cases, timing | Gate 3 | Runs against the present `Float128` routes and reproduces apothecary §8.1's table |
| W4.2 | fix | `sinpi`, `cospi`, and with them `tanpi`, `sincospi`, `cispi` (§4.6) | W4.0 | Error within `2.2 ε_D` on all four input classes; exact zeros and signs tested |
| W4.1 | fix, gated | `sinh`, `cosh` top band | W4.0 | Gate passes, or the route is labelled per R3 |
| W4.3 | fix, gated | `asin`, `acos`, `acsc`, `asec`, `acot` | W4.0 | Same |
| W4.4 | fix, gated | `atan(y, x)` | W4.0 | Same |
| W4.5 | fix, gated | `sin`, `cos` for large arguments | W4.0 | Same |
| W4.6a | move | Schur-based linear algebra to its extension; error hints | Gate 3 | `using DoubleFloats` does not load GenericLinearAlgebra; `eigen` on a `Double64` matrix without it gives the hint |
| W4.6b | move | Special functions to their extension; drop their exports | Gate 3 | Same pattern for `erf` |
| W4.6c | move | `Float128` conversion and promotion to the Quadmath extension | R3 retained list empty | `using DoubleFloats` loads only standard libraries |
| W4.6d | add | `PrecompileTools` workload per package and extension | W4.6a, W4.6b | First call of each documented entry point under half a second |
| W4.7 | drop | Reduced exports; `deprecated.jl` with `depwarn` | W3.6 | Each deprecated name warns once and still works |
| W4.8 | add | Transparent broadcast path | W3.3 | P-IDENT on every platform and no new invalidations; otherwise not merged |

Each gated item is one pull request containing the candidate kernel, its
route, and the gate output. The pull request is merged either way: if the
gate passes, the route replaces the `Float128` one; if not, the candidate
stays in `test/gate.jl` as the measured starting point and the retained
route gains its precondition.

**Gate 4.** Release criteria 5, 6, and 7 hold.

### Stage 5 — 2.0-rc

| Item | Work | Done when |
|:--|:--|:--|
| W5.1 | Upgrade guide assembled from the upgrade-guide lines above, each with a before-and-after example run as a doctest | Every `fix` item has its line |
| W5.2 | `NEWS.md` | |
| W5.3 | Downstream job run against the candidate; an issue opened on each dependent that fails, with the upgrade-guide line that explains it | No unexplained failure |
| W5.4 | Every *confirm* item closed: the `5u²` bound, Quadmath platforms, a target without hardware FMA | |
| W5.5 | Rulings in apothecary §2 checked against the released behaviour | No difference |
| W5.6 | The conformance suite reviewed for extraction as a separate package usable by other number types | A decision, recorded |
| W5.7 | Scratch documents (`apotheosis*.md`, this file, the `*better.md` notes) moved out of `docs/` or removed, so the repository holds no record of a transition | The goal of §0.1 |

W5.7 is deliberate. This plan is scaffolding. When 2.0 is released the
design lives in the manual and the docstrings, the history lives in
`NEWS.md` and the commits, and this file has no further reader.

## 6. Risks and what answers each

| Risk | Where | Answer |
|:--|:--|:--|
| Corpus differs across platforms on unchanged source | W0.4 | Stop and investigate; record per-platform entries only with an explanation |
| Route dispatch slower than hand-written branches | W3.4 | Per-family benchmark gate; the fallback of Stage 3 |
| Normalizing constructor slows client code | W1.3a | Internal sites converted first (W0.8); documented `unsafe_double` |
| Shortest-digit generation slow | W2.1 | It runs only when printing; benchmark `string` and state the cost; bisect; a native algorithm is later work |
| New kernels less accurate than `Float128` on ordinary inputs | W4.1, W4.3–W4.5 | R3's gate, condition 1 |
| Extension split breaks dependents that relied on re-exports | W4.6 | Error hints; upgrade-guide line; downstream job |
| Exact mixed comparison allocates | W1.2b | Only the `Rational` and `BigFloat` forms do; `IEEEFloat` and `Integer` forms compare pairs |
| Stage 2 changes every printed value | Gate 2 | No doctest is written before it |
| Hidden reliance on unnormalized intermediates | W0.8 | The corpus; any site that changes bits is examined individually |

## 7. What was measured for this plan

| Claim | Result |
|:--|:--|
| Sealed struct with `unsafe_double` and a normalizing outer constructor | Compiles; no allocation; default constructors suppressed |
| Exact integer construction | Exact on the eight cases of §4.1 |
| Exact comparison with `Rational` | Agrees with exact arithmetic on 20,000 random pairs |
| Integer conversion with `InexactError` | As §4.2 |
| `sinpi` by exact reduction | Table of §4.6 |
| Non-finite values under arithmetic | `(Inf, Inf)` and `(Inf, 0.0)` behave alike under `+`, `*`, `/`, `sqrt`, `exp`, `inv`, comparison, and `string`; `(Inf, NaN)`, reachable today only through the raw constructor, gives `exp(-x) = NaN`, which D16 removes |

Not measured: anything on `Double32` or `Double16`; any platform but
x86_64 Linux; the bisection in `_shortest`; reflection over
`methods(routes)`; the cost of route dispatch on the real families (the
earlier three-route prototype inlined, which is evidence for the pattern
and not for each family).
