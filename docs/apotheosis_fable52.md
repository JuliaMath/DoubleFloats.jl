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
  tests, 68 public names.
- **Arithmetic.** Error-free transformations (`two_sum`, `two_prod` via `fma`)
  under double-word kernels that cite Joldes, Muller, and Popescu (2017) in
  source comments: addition below `3u²`, multiplication at most `7u²`.
- **Elementary functions.** Table-driven reductions with double-word
  coefficients generated at load time from 256-bit `BigFloat`. Guarded fast
  routes for bounded head ranges, wider fallbacks, and MPFR-assisted rounding
  at the underflow lattice.
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
`floatmin(Double64)` returns `floatmin(Float64)`. Full 106-bit precision
requires the low word's grid to sit above the subnormal spacing `Δ`. The
Accuracy Report uses the threshold `Δ / eps(Double64) = 2^-970` (about
`1e-292`); the Technical Guide quotes about `4e-292`. Either way it is some
sixteen decimal orders above `floatmin`, and the type's own reflection
functions do not expose it.

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
that no constructor produces. Special functions for all three types pass
through `Float128`. None of this is wrong, but the manual's type table
presents the three types as equals.

**F12. Minor.** A comment for a different algorithm is fused into a code
line in `sub_dddd_dd`. `test/README.md` is a list of empty headings.

## 5. Mechanisms

Six mechanisms. Each removes a class of finding rather than one instance.

### M1. Make the invariant a fact of the type

Define normalization once:

```math
\mathcal{N}(h, l):\quad h = \mathrm{RN}(h + l)
\quad\text{for finite } h,\, l;\qquad l = h \text{ or } l = \mathrm{NaN} \text{ when } h \text{ is not finite.}
```

- The only public constructors establish `𝒩`. The raw pair constructor
  becomes internal, with a name that says so (`unsafe_double`), used by
  kernels that have already proved `𝒩`.
- `isnormalized(x)` is exported for users who build values from stored pairs.
- A debug mode (`DoubleFloats.checked(true)`) asserts `𝒩` on the output of
  every kernel during testing.

Resolves F2. Makes every later bound well-posed, since each published bound
assumes `𝒩` on inputs.

### M2. Three tiers of guarantee

Every public operation is assigned exactly one tier per route.

| Tier | Meaning | Statement form | Examples |
|:--|:--|:--|:--|
| **E** exact | Result equals the mathematical value | `hi + lo = a ∘ b` | `two_sum`, `two_prod`, `add2`, `mul2`, conversion from `Float64` |
| **B** bounded | Relative error has a proved bound under `𝒩` and no over/underflow | `\|ŷ − y\| ≤ c·u²·\|y\|` with a citation or proof | `+`, `−` (`c = 3`); `*` (`c = 7` as coded) |
| **S** sampled | Bound observed on a stated sample; no proof | `max ≤ m ε_D` on `n` points of a named distribution | elementary functions, matrix functions |

Rules that keep the tiers honest:

1. A tier-B constant must name the algorithm in the cited paper and the
   line of code that implements it. A kernel that deviates from the published
   algorithm drops to tier S until re-proved.
2. A tier-S statement carries its sample size and distribution. With `n`
   independent samples and no failures, the one-sided 95% bound on the
   failure probability is `3/n`. For `n = 250` that is 1.2%, so the report
   should either say so or raise `n` until the claim is the one intended
   (`n = 10⁶` gives `3·10⁻⁶`).
3. Tier-S routes add structured adversarial points to the random ones:
   reduction boundaries, table midpoints, both signs of `lo` at each branch
   switch. The boundary tests already do this for `exp` and `log`; the
   mechanism makes it uniform.
4. Composite operations inherit the weakest tier of their parts.

Resolves F7. Converts the test threshold of `2.2 ε_D` from a private
constant into the published tier-S ceiling for scalar elementary functions.

### M3. A route registry

A route is a record:

```julia
struct Route{F,P,K}
    op::F              # exp, log, ...
    types::Type        # Double64, Double32, ComplexDF64
    shape::Symbol      # :scalar, :batch, :matrix
    admits::P          # predicate on inputs; cheap, branch-free where batched
    valid::Interval    # where the kernel is mathematically valid
    measured::Interval # where evidence exists; measured ⊆ valid
    kernel::K
    tier::Symbol       # :E, :B, :S
    bound::Float64     # in units of ε_D
    fallback           # next route
end
```

The existing `_BatchKernel(eligible, evaluate)` is this record with five
fields missing. Generalize it rather than invent a new thing.

One registry, four consumers:

- **Dispatch.** Scalar routes compile to the same guarded branches as today
  (the registry is consulted at definition time through `@generated` or
  macro expansion, so there is no run-time table lookup).
- **Tests.** For each route: sample inside `measured`, probe both sides of
  each endpoint of `admits`, assert the result is within `bound` and that
  `𝒩` holds. A route without a passing fixture cannot be registered.
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
them over all three types, including non-finite and subnormal values:

- `isequal(a, b) ⇒ hash(a, h) == hash(b, h)` across `DoubleFloat`, `Float64`,
  `BigFloat`, `Rational`, and integers.
- `T(x)` is exact whenever `x` is representable in `T`, for every `Real`
  subtype (catches F4).
- `==`, `<`, `isless` form a total order on normalized values and agree with
  the exact order of `hi + lo` in `BigFloat`.
- `parse(T, string(x)) == x`; `nextfloat(x) > x`; `prevfloat(nextfloat(x)) == x`.
- Every keyword-accepting method is called with each keyword (catches F3).

The correct hash: when `lo == 0`, return `hash(hi, h)`; otherwise fall
through to `Base`'s generic `hash(::Real, h)`, which uses `decompose` and
therefore agrees with `BigFloat` and `Rational`. `decompose` is already
defined for `Double64`.

For F5, add `floatmin_full(T) = nextfloat(zero(F)) / eps(T)` (`2^-970` for
`Double64`, the threshold the Accuracy Report already uses) and document
`floatmin` as the smallest normal head.

### M5. Sculpt the dependency surface

| Layer | Contents | Dependencies |
|:--|:--|:--|
| Core | type, invariant, arithmetic, elementary functions, I/O, batches | `Base`, `Printf`, `Random`, `LinearAlgebra` |
| Extension: linear algebra | `eigen`, `schur`, `svd`, matrix functions | GenericLinearAlgebra, GenericSchur |
| Extension: special functions | `erf`, `gamma`, Bessel | SpecialFunctions, Quadmath |

Julia 1.10 supports package extensions, so the declared minimum already
permits this. It is a breaking change for users who rely on `gamma` or
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
is a registry entry plus a kernel plus a fixture, and the checklist is what
the registry refuses to accept.

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
  routes/      Route type, registry, dispatch generation
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
| 1 | Conformance suite; fix `hash`, mixed `isapprox`, integer construction | alpha 1 | F1, F3, F4 |
| 2 | Raw constructor internal; `isnormalized`; checked mode | alpha 1 | F2 |
| 3 | CI on `main`, on Julia 1.10 and current; tighten compat; untrack build output | alpha 1 | F9, F10 |
| 4 | Tier labels and bounds on reports; raise sample sizes; add `floatmin_full` | beta 1 | F5, F7 |
| 5 | Route registry for batch kernels (extend `_BatchKernel`); generate the batch admission table | beta 1 | F6 (batch) |
| 6 | Scalar routes into the registry; seam and totality tests | beta 1 | F6, F8 |
| 7 | Manual re-layered; history to `NEWS.md` | beta 1 | F8, F9, F11 |
| 8 | Extensions for linear algebra and special functions | beta 2 | M5 |

The invariant (step 2) moves ahead of the registry because every bound the
registry records assumes normalized inputs. Stage names match the migration
table in `apotheosis_from_fable52.md`, whose alpha 2 stage covers display.

## 8. Acceptance criteria

The apotheosis is reached when each of these is mechanically true.

1. No public call can return a finite value violating `𝒩`.
2. The conformance suite passes for `Double64`, `Double32`, and `Double16`.
3. Every exported operation has a tier and a bound in a generated table,
   and a test that fails if the bound is exceeded.
4. Every admission range printed in the manual is emitted from the registry.
5. Every route boundary has a seam test, and every route chain is total.
6. Each report names one toolchain, one revision, one seed, and its sample
   sizes.
7. `using DoubleFloats` loads no package outside the standard library.
8. CI exercises the oldest declared Julia version.

All eight are release criteria for 2.0.
