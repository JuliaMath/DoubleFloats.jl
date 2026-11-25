# Checkpoint

Progress record for the 2.0 transformation. The plan is `apothic.md`; the
design is `apothecary.md`. Updated at the end of each work item.

## State

- Date: 2026-11-25
- Branches: `stage0` (draft pull request #328 against `main`, all checks
  green) and `stage1`, stacked on it
- `main`: 1.13.3 (pull request #327 merged as `9c61406a`)
- `release-1.13`: `b186e440`, the 1.13.3 baseline
- Registration of 1.13.3: JuliaRegistries/General#177768 is open and
  blocked. AutoMerge objects that 1.13.3 skips 1.13.0. It merges if the
  package author comments `[merge approved]` there.

## Stage 0 — ground

| Item | Status | Commits | Evidence |
|:--|:--|:--|:--|
| W0.1 Branches, version, compat | done | `21ea3bcd` | Suite passes from a fresh resolve on Julia 1.13.3; lowest admitted dependency versions load |
| W0.2 CI matrix | done | `88ba4035`, `9ec52ac5` | Nine test jobs pass on #328: Julia 1.12, current, pre-release on Linux, macOS (ARM), Windows |
| W0.3 Test layout and support | done | `4f7ae0d5`, `cb13130f`, `327f5cb3` | Same 140 test sets with the same counts as before, plus `test support` |
| W0.4 Golden corpus | done | `0ea66d94`, `067ffaa4`, `cb79391c` | 483 subjects recorded from `release-1.13`. CI: identical on Linux, macOS ARM, Windows with Julia 1.12.0, 1.13.4, 1.14 beta (one subject removed, see findings) |
| W0.5 Benchmark suite | done | `acab47e4`, benchmark fix | 179 benchmarks; `release-1.13` against the working tree: every ratio between 0.95 and 1.05. CI job passes |
| W0.6 Line endings and formatting | done | `e01825b1`, `00d5f7bc`, `53da9379` | Corpus and suite unchanged; benchmark ratios 0.95 to 1.05 |
| W0.7 Source tree | done, with two splits deferred (below) | `66f38363` through `c3c90aef` (15 commits) | Corpus identical after every commit; suite passes; layering lint reports no upward use |
| W0.8 Sealed constructor | done | this commit range | Corpus identical; suite passes; benchmark ratios 0.98 to 1.06 against `release-1.13` |
| W0.9 Explicit imports | done; type loops deferred | `492b93fa`, `96beebb2` | Corpus identical; suite passes on Julia 1.12 and 1.13; four ExplicitImports checks pass; shadowed names unchanged; benchmark ratios 0.95 to 1.10 |
| W0.10 Contributor guide | done | this commit | `CONTRIBUTING.md` |

**Gate 0 holds.** On #328: nine test jobs (Julia 1.12.0, 1.13.4, 1.14 beta
on Linux, ARM macOS, Windows), docs, invalidations, and the benchmark
comparison all pass. The corpus is identical to 1.13.3 on all nine.

## Stage 1 — correctness

Conformance: 275 properties, 172 hold, 103 listed in
`test/conformance/broken.txt`. The stage is done when no Stage 1 key is
left in that file.

| Item | Status | Commits | Evidence |
|:--|:--|:--|:--|
| W1.1 Conformance suite | done | `86911e12` | 266 properties written; 112 did not hold |
| W1.3a Pair constructor normalizes | done | `9e2f00b4` | Nine properties now hold; corpus changed on four subjects, each explained; benchmarks 0.94 to 1.07 |
| modf (found on the way) | done | `4f6f1288` | Three properties now hold; corpus changed on `modf` only |
| W1.3b Exact construction from integers, rationals, `BigFloat` | next | | |
| W1.3c Nested-type methods | | | |
| W1.2a Comparison on one type | | | |
| W1.4a `decompose`, `Rational` | | | |
| W1.4b `hash` | | | |
| W1.2b Exact mixed comparison | | | |
| W1.6a Integer conversion throws | | | |
| W1.6b `rationalize` | | | |
| W1.5 Parsing | | | |
| W1.8 Promotion | | | |
| W1.7 `isapprox`, random numbers, macros | | | |
| W1.9 Aqua, ambiguities, piracy | | | |

## Findings so far

- Versions 1.13.0 to 1.13.3 had never been pushed. They are now on `main`.
- Quadmath works on ARM macOS (the test suite passes there). That *confirm*
  item of apothecary §8.1 is closed for that platform.
- The test suite's override of `Base.isapprox` for IEEE floats was never
  reached by any test. Removed.
- The invalidations check fails on #328 with 158 against 156 on `main`,
  although the branch changes no source. Local measurement gives 157 for
  the branch and 159 for `main`. All counted invalidations come from
  dependencies. The check is unchanged; the cause of the ±2 is not found.
- Some source and test files have CRLF line endings. W0.6 settles one
  convention.
- The corpus is the same on x86_64 Linux, ARM macOS, and Windows for a
  given Julia version. Scalar results do not depend on the platform.
- Three things made the first corpus depend on the Julia version, all in
  the corpus code and none in the package: the printed form of `BigFloat`
  (`e-05` on 1.12, `e-5` on 1.13); `ldexp` on a subnormal `Float32`, which
  returns different values on Julia 1.12 and 1.13; and matrix products
  through LinearAlgebra's generic kernels (2x2 products differ on 1.12,
  matrix-vector products differ from 1.14). The corpus now avoids all three.
  Consequence: matrix-vector and 2x2 products of `Double32` are not
  bit-protected by the corpus; their unit tests remain.
- `string(Double32(hi, 0))` prints six digits and the same head with a
  nonzero low word prints 35. Display is Stage 2 work; noted here because
  the corpus exposed it.
- A 16x16 `Double32` matrix product takes 16 μs against 2.6 μs for
  `Double64`: `Double32` does not reach the compensated product kernel.
  Not in the plan; candidate for a later item.
- The benchmark baseline is not a stored file. Timings from another machine
  are not comparable, so `benchmark/compare.jl` runs both versions on the
  same machine and the CI job compares each pull request with
  `release-1.13`. `apothic.md` is updated to say so.
- Same-source noise on the local machine is about ±6%; the local threshold
  is 1.2 and the CI threshold 1.3.
- Julia 1.12 was installed locally (juliaup channel `1.12`) to diagnose
  the corpus.

- `sqrt` of a `ComplexDF64` is computed through `Float128`
  (`ComplexDF64ComplexF128`). On ARM macOS with Julia 1.12.0 its bits
  differ from every other platform and version in the matrix. This is a
  seventh `Float128` path in the core, not listed in apothecary F18, and
  direct evidence for R3: a result that depends on the platform's
  libquadmath cannot carry a bound. Removed from the corpus; to be added to
  the R3 list.
- With one evaluation per sample, sub-microsecond benchmarks showed ±25%
  on identical source. The comparison now calibrates evaluations.
  `tune!` was tried and took more than ten minutes.
- The formatter leaves a trailing `;` where two statements shared a line.
  To be cleaned by hand as files are touched in W0.7 and W0.9.

- W0.7 as done: every source file is in its layer directory; ten operation
  files became `arith/kernels.jl` and `arith/operators.jl`; the include
  list is in layer order. Deferred: splitting `elementary/explog.jl`,
  `elementary/trig.jl`, and `core/type.jl` into the smaller files of
  `apothic.md` §3.1. The first two are rewritten family by family in W3.4,
  and `core/type.jl` is rewritten in W0.8 and W1.3, so splitting them now
  would be done twice.
- The layering lint moved the route records below arithmetic. With the
  batch records in the batch layer, more than sixty uses in `arith/` and
  `elementary/` reached upward. Layers are now: eft, core, routes, arith,
  contract, constants, elementary, batch, io, random, linalg. `apothic.md`
  §2.1 is updated.
- `elementary/templated.jl` holds the `Double32` and `Double16` functions
  computed in `Double64`, not nested-type methods. It is kept, as
  `elementary/widened.jl`. The plan is corrected.
- `type/intraconstructors.jl` was never included by anything. Removed.
- `two_cbrt` sat with the error-free transformations but calls
  `DoubleFloat` arithmetic. Moved to `arith/operators.jl`.
- The plan's "prefix loading" check was vacuous: a package that loads has
  already loaded every prefix. `apothic.md` §2.2 now says so.

- W0.8: the struct already had two inner constructors, an untyped one that
  normalizes (`DoubleFloat(hi, lo)`) and a typed one that does not
  (`Double64(hi, lo)`). Both are now outer methods over `unsafe_double`.
- Eight of the 506 rewritten sites passed words of another type (`Float64`
  literals to a `Double32`), and three more passed integers; the old typed
  constructor converted each word. `unsafe_double` has a method that does
  the same, restricted to machine floats and integers.
- Not rewritten: constructions through a type variable (`T(hi, lo)`,
  `typeof(x)(hi, lo)`). They reach the public constructor and will be
  normalized after W1.3a. The corpus will show whether any of them mattered;
  the benchmarks will show the cost.
- A mistake of mine worth recording: I killed my own shell twice with
  `pkill -f` on a pattern that matched the command line.

- W0.9: 336 definitions qualified, the module file fell from 308 lines to
  about 200. Deferred: replacing `@eval` loops over the three types with
  parametric methods. Most of them are constructors and conversions that
  W1.3 rewrites.
- `csc` and `sec` are this package's own functions, not methods of
  `Base.csc` and `Base.sec`: the old import list did not name them. A
  caller's `csc(x)` reaches Base's generic method, not the package's. Kept
  as found (a `move` must not change it); to be made Base methods as a
  `fix` in Stage 1.
- `normalize` shadows `LinearAlgebra.normalize` in the same way.
- `ispositive` and `isnegative` are Base functions only from Julia 1.13.
  The conditional import stays, and their definitions stay unqualified.
- The package uses 33 names that are not public in their modules, among
  them `Base.decompose`, `Base._cpow`, `Base.lerpi`, `Base.rtoldefault`,
  `Base.mightalias`, `Base.uinttype`, `Base.MPFR.libmpfr`,
  `Printf.ini_dec`, `Printf.fix_dec`, and several LinearAlgebra types.
  Each is a way for a Julia release to break the package. Not checked in
  CI yet; to be reduced, then checked, in W1.9.

- The constructor as first designed was wrong. `two_sum(-0.0, 0.0)` is
  `0.0`, so normalizing with `two_sum` alone lost negative zero; the corpus
  changed on 125 subjects. The constructor now leaves the words as given
  when the low word is zero. `apothecary.md` §3.3 said "identity on a
  normalized pair (verified)"; it was not verified on signed zeros. It is
  corrected.
- Internal code passes a meaningless low word with a non-finite high word
  (`Double64(big(Inf))` built `(Inf, NaN)`). A constructor that summed the
  words turned `parse(Double64, "Inf")` into `NaN`. The rule is now the one
  D1 states for readers: a high word that is not finite is the value.
- Defects the conformance suite found that were in no earlier list:
  `round(Double64(2.5))` is 3, not 2 (ties do not go to even);
  `isapprox(x, y)` uses a default tolerance near `eps^(1/4)`, far looser
  than `sqrt(eps)`; `isapprox(NaN, NaN)` is `true`; `NaN <= NaN` is `true`;
  `modf` split a value just below an integer the wrong way (fixed);
  `parse(Double64, "1.000…0001")` with sixty zeros drops the low word when
  a failed parse earlier in the session has changed the global `BigFloat`
  precision.
- That last one made an existing unit test fail when the conformance suite
  ran before it: a bad parse lowered the global precision and
  `Int128(Double64(a))` then lost bits. Each conformance property now
  restores the precision. The defect itself is C4, due in W1.5.
- `Int128(Double64(n)) == n` fails for about 18% of random 128-bit
  integers that fit in 106 bits (F4, due in W1.3b).

## Open

Decisions that are the maintainer's:

1. Registration of 1.13.3. Either comment `[merge approved]` on
   JuliaRegistries/General#177768, or register the release as 1.13.0.
2. Merging #328 (`stage0`) into `main`, which makes `main` the 2.0
   development line (R5). Gate 0 holds.

Still to confirm: the `5u²` multiplication bound; a target without
hardware FMA.

Installed locally during this work: juliaup channels `1.10` and `1.12`.

## Next

W1.3b: exact construction from `Integer`, `Rational`, and `BigFloat`, by
one method per argument kind in place of the per-type copies and the
`@eval` loop in `core/type.jl`.
