# Checkpoint

Progress record for the 2.0 transformation. The plan is `apothic.md`; the
design is `apothecary.md`. Updated at the end of each work item.

## State

- Date: 2026-11-25
- Branch: `stage0`, draft pull request #328 against `main`
- `main`: 1.13.3 (pull request #327 merged as `9c61406a`)
- `release-1.13`: `b186e440`, the 1.13.3 baseline
- Registration of 1.13.3: requested, JuliaRegistries/General#177768, not yet merged when last checked

## Stage 0 — ground

| Item | Status | Commits | Evidence |
|:--|:--|:--|:--|
| W0.1 Branches, version, compat | done | `21ea3bcd` | Suite passes from a fresh resolve on Julia 1.13.3; lowest admitted dependency versions load |
| W0.2 CI matrix | done | `88ba4035`, `9ec52ac5` | Nine test jobs pass on #328: Julia 1.12, current, pre-release on Linux, macOS (ARM), Windows |
| W0.3 Test layout and support | done | `4f7ae0d5`, `cb13130f`, `327f5cb3` | Same 140 test sets with the same counts as before, plus `test support` |
| W0.4 Golden corpus | done locally; CI pending | `0ea66d94`, `067ffaa4` | 484 subjects recorded from `release-1.13`. Identical on Julia 1.12.7, 1.13.3, 1.15-DEV locally; identical on Linux, macOS ARM, Windows with Julia 1.13.4 in CI (first version of the corpus) |
| W0.5 Benchmark suite | done locally; CI pending | `acab47e4` | 179 benchmarks; `release-1.13` against the working tree: every ratio between 0.95 and 1.06 |
| W0.6 Formatting commit | next | | |
| W0.7 Source tree | | | |
| W0.8 Sealed constructor | | | |
| W0.9 Explicit imports | | | |
| W0.10 Contributor guide | | | |

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

## Open

- Registration of 1.13.3 to be confirmed merged; then tag `v1.13.3` appears.
- *Confirm* items still open: the `5u²` multiplication bound; a target
  without hardware FMA.
- Julia 1.10 was installed locally (juliaup channel `1.10`) to test 1.13.3.

## Next

W0.6: one line-ending convention and one formatter configuration, each
applied in its own commit, with the corpus unchanged.
