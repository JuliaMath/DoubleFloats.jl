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
| W0.4 Golden corpus | next | | |
| W0.5 Benchmark baseline | | | |
| W0.6 Formatting commit | | | |
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

## Open

- Registration of 1.13.3 to be confirmed merged; then tag `v1.13.3` appears.
- *Confirm* items still open: the `5u²` multiplication bound; a target
  without hardware FMA.
- Julia 1.10 was installed locally (juliaup channel `1.10`) to test 1.13.3.

## Next

W0.4: the golden corpus. Record checksums of output bits at the head of
`release-1.13`, add `test/golden.jl`, and see whether the corpus is the
same on every platform and Julia version of the matrix.
