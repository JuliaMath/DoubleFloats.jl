# The client experience, rewoven

Companion to `apotheosis_fable52.md`. That document re-presented the package
as a number type that carries a contract. This one applies the same idea to
what a client actually touches: loading, constructing, displaying,
exchanging, computing, and asking what is promised. Every observation below
was executed against version 1.13.3 on Julia 1.13.3. Findings from the first
document are cited as F1–F12 and not repeated.

## 1. Principle

A Julia client should need to learn almost nothing. `Double64` is an
`AbstractFloat`; the best experience is the one in which everything the
client already knows about `Float64` and `BigFloat` remains true, and the
few things that are specific to a two-word type are discoverable, named in
Julia's idiom, and stated as contracts.

That gives three rules for the client surface.

1. **Generic verbs first.** If `Base` has a verb for it (`parse`, `show`,
   `round`, `rand`, `map!`, broadcasting, `reinterpret`), the package
   implements that verb correctly instead of exporting a new one.
2. **Loud, not lossy.** An operation that cannot honour its contract throws
   the exception `Base` would throw. It does not round, narrow, or truncate
   silently.
3. **Ask the type.** What is guaranteed, and by which route, is a function
   call and a docstring section, generated from the route registry.

## 2. The experience today

### 2.1 What already matches Julia practice

- `Double64` is `isbits`, 16 bytes; `Vector{Double64}` is dense and
  `reinterpret(Float64, v)` works without copying.
- Generic code works: `sum`, `sort`, ranges, `A \ b`, `det`, `eigvals`,
  `exp(A)`, `x + π`, `x + 1//3`, `x^2.5`, `im * x`.
- `rand` is implemented through `Random.SamplerTrivial`, so every
  `AbstractRNG` and every array shape works.
- `df64"0.1"` expands at parse time to a constant.
- `precision(Double64; base=10)` returns 31. `Float64(x)` is correctly
  rounded.
- Load takes 0.45 s; the first scalar `exp` and `string` take 0.18 s.

### 2.2 Where the client is surprised

| # | Observation | Julia expectation |
|:--|:--|:--|
| C1 | `Int64(Double64(2.5))` returns `2` | `InexactError`, as `Int64(2.5)` |
| C2 | `tryparse(Double64, "abc")` throws `MethodError` | returns `nothing` |
| C3 | `parse(Double64, "abc")` throws `MethodError`; `Double64("abc")` throws `ArgumentError` | `ArgumentError` from both |
| C4 | After `Double64("abc")` throws, `precision(BigFloat)` stays changed | No global state is touched |
| C5 | `eval(Meta.parse(repr(x))) === x` is `false` | `repr` round-trips, or says it does not |
| C6 | `parse(Double64, string(Double64(1.0, 1e-40)))` loses the low word (`string` gives `"1"`) | `parse(T, string(x)) == x` |
| C7 | `repr(Double32(1)/3)` prints 35 digits; `Double32` holds about 14 | Shortest digits that identify the value |
| C8 | A `Vector{Double64}` prints 35 digits per element; a `Matrix{Double64}` prints the `Float64` head | One compact rule for both |
| C9 | `@sprintf("%.30f", x)` prints `0.333333333333333314829616256247` | Digits of the `Double64`, not of its head |
| C10 | `Double32(1) + 0.1` is a `Double32`; 5 bits of the `Float64` are dropped | Promotion never narrows |
| C11 | `rationalize(Double64(1)/3)` returns `1//4` | `1//3` |
| C12 | `randpm(Xoshiro(1), Double64)` throws; only `MersenneTwister` is accepted | Any `AbstractRNG` |
| C13 | `@via_df32` with three arguments returns `Float64` | `Float32` |
| C14 | `simdmap!` is neither exported nor `public` | A documented entry point is declared |
| C15 | 29 of 68 exported names have no docstring | `?name` works for every export |
| C16 | 12 method ambiguities | Zero |
| C17 | The first `exp(::Matrix{Double64})` takes 1.5 s | Precompiled |

Together with F1–F5 (hashing, raw constructor, mixed `isapprox`, integer
construction, `floatmin`), these fall into one pattern: the numerical
kernels are careful and the interface around them is not held to a stated
standard.

## 3. The rewoven experience, stage by stage

### 3.1 Arrive

```julia
using DoubleFloats            # arithmetic, elementary functions, I/O
using DoubleFloats, LinearAlgebra, GenericSchur     # activates matrix routes
using DoubleFloats, SpecialFunctions                # activates erf, gamma, bessel
```

- The core loads only standard libraries. Matrix and special functions are
  package extensions under `[weakdeps]`/`[extensions]`, triggered by the
  packages a client using them has already loaded.
- Each extension ships a `PrecompileTools` workload for its common calls,
  which removes C17.
- The exported set is small: the types, the string macros, and the names
  that have no `Base` equivalent and are used unqualified in ordinary code.
  Everything else that is supported is declared `public` (Julia 1.11 and
  later; guarded by a `VERSION` check so 1.10 still loads).

| Disposition | Names |
|:--|:--|
| Export | `DoubleFloat`, `Double64`, `Double32`, `Double16`, `ComplexDF64`, `ComplexDF32`, `ComplexDF16`, `@df64_str`, `@df32_str`, `@df16_str`, `HI`, `LO`, `HILO`, `ulp`, `square`, `cube`, `add2`, `sub2`, `mul2`, `div2` |
| Public, qualified | `simdmap!`, `simdmap`, `guarantee`, `route`, `isnormalized`, `floatmin_full`, `showtyped`, `stringtyped`, `agm`, `agm1`, `intpart`, `fracpart`, `randpm`, `normalize` |
| Deprecate in favour of `Base` | `nan(T)`, `inf(T)`, `posinf(T)`, `neginf(T)` → `T(NaN)`, `T(Inf)`, `T(-Inf)`; `showall(x)` → `print(x)`; `isposinf`, `isneginf` → `x == Inf`; `@via_df64`, `@via_df32` → the broadcast they expand to |
| Review and document, or remove | `fmod`, `sld`, `tld`, `signs`, `spread`, `⊕`, `⊖`, `⊗`, `⊘` |

Two notes on naming. `HI`, `LO`, and `HILO` break the lowercase convention
for functions, and should stay: `lo` and `hi` are the conventional argument
names of `clamp` and of every bounds pair, so lowercase accessors would
shadow constantly. The Unicode operators `⊗` and `⊕` are exported by several
other packages; exporting them from a number type invites clashes, so they
move to `public`.

### 3.2 Construct

The rule: **construction is exact when the value is representable, and the
client chooses explicitly when it is not.**

```julia
Double64(2^62 + 1)            # exact: 63 bits fit in 106        (fixes F4)
Double64(1//3)                # correctly rounded
Double64(π)                   # correctly rounded
df64"0.1"                     # decimal text, at parse time
parse(Double64, "0.1")        # decimal text, at run time
Double64(0.1)                 # exact widening of the Float64 0.1
DoubleFloat(hi, lo)           # normalizing: any two floats
```

- One generic method does the work: `DoubleFloat{T}(x::Real)` computes
  `hi = T(x)` and `lo = T(x - hi)` in exact arithmetic for integers and
  rationals. The per-type copies in `Double.jl` collapse into it.
- `Double64(hi, lo)` normalizes. The raw form becomes the internal
  `unsafe_double` (F2).
- `Double64(::AbstractString)` stays, on the precedent of `BigFloat("…")`,
  and is defined as `parse`. Both use `BigFloat(str; precision = p)` or
  `setprecision(f, BigFloat, p)`, never the global setter, which fixes C4
  and makes parsing safe under threads.
- `tryparse` uses a branch, not `ifelse`, which evaluates both arms (C2, C3).

The `Double64(0.1)` trap deserves one sentence in the docstring and nothing
more. It is how every Julia float type behaves, and the string macro is the
answer.

### 3.3 See

Julia separates three displays, and each has one job.

| Call | Purpose | Rewoven output for `Double64(1)/3` |
|:--|:--|:--|
| `print(io, x)`, `string(x)` | Human text | `0.3333333333333333333333333333333323` |
| `show(io, x)`, `repr(x)` | Julia code that reconstructs the value | `df64"0.3333333333333333333333333333333323"` |
| `show(io, MIME"text/plain"(), x)` | REPL | same as `print`, since the type is shown by context |

The digits in the table are illustrative; the rules below determine them.

Rules:

1. **Shortest round-trip digits.** Emit the fewest decimal digits `d` such
   that `parse(T, digits) === x`. Measured on random `Double64` values that is
   29 to 37 significant digits, mean 33, and about 16 for `Double32` (C7).
   The count is not fixed because a normalized pair can carry more than 106
   bits.
   A sparse low word needs more digits; the search continues until the
   round trip holds, so C6 cannot occur.
2. **`repr` is honest.** Outside a typed container, two-argument `show`
   emits the string-macro form, exactly as `repr(Float16(0.1))` emits
   `Float16(0.1)`. Inside a container whose element type is known
   (`:typeinfo`), it emits bare digits. This fixes C5.
3. **Compact means short, not different.** With `:compact => true`, print
   six significant digits of the value, as `Float64` does. Vectors and
   matrices then follow the same rule (C8), and a client who wants every
   digit in a matrix uses `show(IOContext(io, :compact => false), A)`.
4. **Both components on request.** `showtyped(x)` prints
   `Double64(hi, lo)` with each word in shortest round-trip form. This is
   the lossless textual form and the documented choice for logs.

`Printf` formats through its float-conversion hook (`Printf.tofloat`), which
by default narrows any `Real` to `Float64`. Mapping `DoubleFloat` to
`BigFloat` there gives `%.30f` its digits (C9), as Quadmath already does for
`Float128`. It replaces the present overloads of `Printf.ini_dec` and
`Printf.fix_dec`, which convert to `Float64` and leave C9 in place. Because
the hook is not public API, a test pins the behaviour on every supported
Julia version.

### 3.4 Exchange

- **Text.** `parse(T, string(x)) === x` for every finite normalized `x`,
  by rule 1 above.
- **Binary.** `reinterpret(Float64, v)` and
  `reinterpret(reshape, Float64, v)` give the words without copying, and the
  inverse reconstructs the vector. This is the recommended storage format
  and gets a short manual section; it needs no code.
- **Narrowing.** `Float64(x)` is correctly rounded. `Int64(x)` and
  `convert(Integer, x)` throw `InexactError` unless `x` is an integer in
  range (C1); `round(Int, x)`, `trunc(Int, x)`, `floor(Int, x)` are the
  rounding forms. `rationalize(x)` honours `tol = eps(x)` (C11).
- **Hashing and equality** follow `Base` across numeric types (F1).

### 3.5 Compute with scalars

Nothing changes in what the client writes. What changes is that the result
type and the guarantee are predictable.

**Promotion never narrows.**

| Operands | Today | Rewoven | Reason |
|:--|:--|:--|:--|
| `Double64`, any `IEEEFloat`, `Integer`, `Rational`, `Irrational` | `Double64` | `Double64` | contains them (to rounding) |
| `Double32`, `Float32`/`Float16` | `Double32` | `Double32` | contains them |
| `Double32`, `Float64` | `Double32` | `Double64` | 53 bits do not fit in 48; the exponent range does not fit either |
| `Double16`, `Float32` | `Double16` | `Double32` | same argument |
| `Double16`, `Float64` | `Double16` | `Double64` | same argument |
| any `DoubleFloat`, `BigFloat` | `BigFloat` | `BigFloat` | unchanged |

This is a behaviour change (C10) and belongs to 2.0.

**Errors are `Base`'s errors.** `DomainError(x, "explanation")` carries the
offending value as its first argument, so tooling can read it. The message
says which domain applies and, where there is one, the complex alternative,
as `sqrt(-1.0)` does.

**Each docstring states its contract.** A fixed template, with the contract
section generated from the route registry (the numbers shown are
placeholders for generated values):

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
| Type | Tier | Bound | Measured on |
|:--|:--|:--|:--|
| `Double64` | sampled | 2.2 ε_D | heads in [-745, 709] |
| `Double32` | sampled | 2.2 ε_D | heads in [-103, 88] |

Overflows to `Inf` above 709.78; rounds to the subnormal lattice below
`floatmin_full(Double64)`.
"""
````

The `# Extended help` heading is the standard marker: `?exp` shows the
summary and `??exp` shows the guarantee.

### 3.6 Ask the type

Two public functions expose the contract to code and to the REPL
(output format and values illustrative).

```julia
julia> DoubleFloats.guarantee(exp, Double64)
Guarantee(tier = :sampled, bound = 2.2, unit = 2^-104,
          measured = [-745, 709], samples = 1_000_000)

julia> DoubleFloats.route(exp, df64"0.2")
Route(:exp, Double64, :scalar, "128-entry table, degree 9")

julia> DoubleFloats.guarantee(+, Double64)
Guarantee(tier = :bounded, bound = 0.75, unit = 2^-104,
          source = "Joldes, Muller, Popescu (2017), Algorithm 6")
```

`guarantee` is what lets a downstream package write a tolerance that follows
the package's own claim instead of a hard-coded `1e-30`. `route` is the
diagnostic for "why was this slow?" and "why do these two differ in the last
bit?". Neither exists today; both are thin views of the registry (mechanism
M3 of the first document).

### 3.7 Compute with arrays

Julia's idiom for elementwise work is broadcasting, and a client should not
have to learn a second verb to get the fast path. The contract perspective
says when that is permissible: **an implicit fast path must return the same
bits as the scalar call.**

| Path | What the client writes | Condition | Guarantee |
|:--|:--|:--|:--|
| Transparent | `y .= exp.(x)` | Kernel is registered `identical = true`; `x`, `y` are dense, disjoint `Vector`s | Bit-identical to `map(exp, x)`, enforced by test |
| Explicit | `DoubleFloats.simdmap!(tan, y, x)` | Any registered batch kernel | The kernel's own tier and bound, which can differ from scalar |
| Explicit, threaded | `simdmap!(f, y, x; threaded = true)` | Length above the kernel's threshold | Same values; write order on failure is unspecified |

- The matched run in the Technical Guide reports identical output words for
  the eleven `Double64` kernels (`exp`, `exp2`, `expm1`, `log`, `log2`,
  `log1p`, `atan`, `tan`, `sinh`, `cosh`, `tanh`). Those are the candidates
  for the transparent path. The six native `Double32` kernels have higher
  sampled error than their scalar routes and stay explicit.
- The transparent path is one `copyto!` method on
  `Broadcasted{<:Any, <:Any, F, Tuple{Vector{D}}}` for the registered `F`.
  It dispatches on the package's own element type, so it is not piracy. It
  must be checked for invalidations and for fused expressions such as
  `exp.(x) .+ 1`, which do not match the single-call pattern and correctly
  take the ordinary route.
- `simdmap!` gains a non-mutating `simdmap(f, x)` that allocates the
  destination, following the `map`/`map!` pairing, and both are `public`
  (C14).
- `DoubleFloats.route(f, x::AbstractVector)` reports the admitted fraction,
  so a client can see how much of a workload reaches a native kernel before
  committing to the batch call.

If the bit-identity test cannot be made to pass on every supported target,
the transparent path is not shipped. The explicit path is complete without it.

### 3.8 Linear algebra and special functions

With the extensions loaded, the client writes standard `LinearAlgebra` and
`SpecialFunctions` calls. Three refinements:

- The extension owns its methods on `Matrix{<:DoubleFloat}`. The explicit
  `eigen` and `eigvals` routing that pins GenericSchur stays, inside the
  extension.
- Structure is expressed with wrapper types. `exp(UpperTriangular(A))`,
  `sqrt(Symmetric(A))`, and `exp(Diagonal(d))` dispatch to the dedicated
  routes directly; the run-time structure scan remains for plain `Matrix`
  input.
- Special functions state their tier as the first document's composite
  rule requires: computed in `Float128`, hence tier S with the conversion
  error included.

### 3.9 Random numbers

- `rand(rng, Double64)` keeps its `SamplerTrivial` method and gets a stated
  distribution: uniform on `[0, 1)` over a `2^-106` grid, built as
  `two_sum(u₁, 2^-53 · u₂)` from two independent uniform `Float64` draws.
  The current exponent adjustment of the low word has no stated distribution.
- `randn` states its method and tier.
- `randpm` accepts any `AbstractRNG` (C12), or is deprecated in favour of
  `2rand(rng, T) - 1`, which is what clients write for other float types.

## 4. Practices that hold the experience in place

Each item is a gate in CI, not a convention.

| Practice | Tool | Catches |
|:--|:--|:--|
| Method ambiguities, unbound parameters, piracy, stale dependencies, missing compat | `Aqua.test_all` | C16; stdlib compat entries; the `Base.lerpi` and `clamp` methods get reviewed for piracy |
| Type stability and inference of hot paths | `JET.@test_opt` on each registered scalar route; `@inferred` in tests | Regressions that allocate |
| Explicit imports | `ExplicitImports.jl` | The 60-name `import Base:` list drifting from use |
| Docstrings | `makedocs(checkdocs = :exports, doctest = true)` with `warnonly` removed | C15; examples that stop being true |
| `Base` conformance | The property suite from M4 | C1–C6, C10–C12, F1–F4 |
| Display round trip | `parse(T, repr-digits) === x` over random, sparse, subnormal, and extreme values | C5–C7 |
| Zero allocations | `@allocated` tests on scalar routes and warmed batch calls | Accidental `BigFloat` on a hot path |
| Load and first-call time | `PrecompileTools` workload; the existing Invalidations workflow | C17 |
| Version matrix | CI on Julia 1.10 and current, on `main` | F10 |
| Formatting | `JuliaFormatter` or `Runic` check | Mixed 2-, 3-, and 5-space indentation in `src/` |

Supporting changes to the project file: move test-only dependencies to
`test/Project.toml` (or a `[workspace]`), add `[weakdeps]` and `[extensions]`,
add compat bounds for the standard libraries, and drop the nonstandard
`desc`, `keywords`, `license`, and `repo` keys that the package manager
ignores.

Source idioms worth adopting while touching these files:

- Loops over `(F, D)` with `@eval` that generate one method per type become
  a single parametric method on `DoubleFloat{T}`. Three near-identical
  docstrings become one.
- Coefficient tables built at load time with `setprecision(BigFloat, 256) do`
  are already correct and thread-safe; the string constructors should match.
- Internal names take a leading underscore consistently, so the absence of
  one means "supported".
- `@inline` is kept where measurement shows it matters and dropped
  elsewhere; the compiler's heuristics are better than they were when much
  of this was written.

## 5. Migration

Decided: everything in this document ships in 2.0. The 1.x line receives no
changes from this plan, so its values, printed digits, exports, and
promotion rules stay exactly as they are for clients who pin it.

Work is staged inside the 2.0 development cycle, in an order that keeps
each stage reviewable and testable on its own.

| Stage | Contents | Gate before the next stage |
|:--|:--|:--|
| 2.0-alpha 1: correctness | C1–C4, C9, C11–C13, C16; F1–F4; normalizing constructor; non-narrowing promotion | Conformance suite and `Aqua.test_all` pass |
| 2.0-alpha 2: display | Shortest round-trip `string` (C6, C7); six-digit compact rule (C8); `repr` in string-macro form (C5) | Round-trip properties pass on random, sparse, subnormal, and extreme values |
| 2.0-beta 1: contract | Route registry; `guarantee` and `route`; generated contract sections; docstrings for every export; `public` declarations; `simdmap` | `checkdocs = :exports` and doctests pass without `warnonly` |
| 2.0-beta 2: structure | Extensions for linear algebra and special functions; reduced exports; precompile workloads; transparent broadcast path if bit-identity holds | Load and first-call budgets met on Julia 1.10 and current |
| 2.0-rc | Upgrade guide; `NEWS.md`; downstream packages tested against the release candidate | No open regressions from dependents |

Names scheduled for removal (`nan`/`inf` family, `showall`, `@via_*`,
`isposinf`, `isneginf`) remain in 2.0 as deprecated definitions that call
`Base.depwarn` and are removed in 3.0. Behaviour changes cannot be expressed
that way: lossy `Int64(x)`, narrowing promotion, the raw two-argument
constructor, and printed digits change at 2.0 itself, and each gets one
entry in the upgrade guide with its replacement.

Because 1.x carries no warning release, the upgrade guide is the only
notice clients get. It lists every change in §2.2 with a before and after
line, and the release candidate stays open long enough for dependents to
run their tests against it.

## 6. Acceptance

The client experience is complete when a `Float64` user can do each of
these without consulting the manual, and each is enforced by a test.

1. `parse(T, string(x)) === x` and `eval(Meta.parse(repr(x))) === x` for all
   finite normalized `x`.
2. Every conversion is exact or throws `InexactError`; every promotion
   yields a type that contains both operands.
3. `?f` works for every exported and public name, and `??f` states a tier
   and a bound.
4. `DoubleFloats.guarantee(f, T)` returns a value for every supported
   operation.
5. `y .= f.(x)` equals `map(f, x)` bit for bit, whatever path it takes.
6. `using DoubleFloats` loads no package outside the standard library, and
   no supported call takes more than half a second on first use.
7. `Aqua.test_all(DoubleFloats)` passes with no exclusions.
8. No public function reads or writes global state.
