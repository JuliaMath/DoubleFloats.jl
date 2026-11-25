# Contributing to DoubleFloats

This guide is for the 2.0 development line. It says how a change is made
so that it can be trusted, and where things live.

## One kind of change per commit

The first word of a commit subject says what kind of change it is.

| Kind | Changes | What shows it is safe |
|:--|:--|:--|
| `move` | Where code lives, how it is named or factored | The golden corpus is unchanged |
| `fix` | A result a caller can observe | A test written first and shown failing; the corpus entries it alters are regenerated in the same commit |
| `add` | New code; nothing existing altered | New tests; the corpus is unchanged |
| `drop` | Removes code or a name | The corpus is unchanged, or a deprecation is tested |
| `config` | Project, CI, or tooling | CI |

A change that needs two kinds is two commits.

## The golden corpus

`test/golden/corpus.toml` holds checksums of the output bits of every
public function on fixed inputs, recorded from the 1.13.3 release. The
test suite recomputes and compares them on every run.

- If you only moved or renamed code and the corpus test fails, the change
  altered a result. Find out where:

      julia test/golden/diff.jl rev:main path:.

  It lists the inputs on which the two versions differ, with both results.

- If you meant to alter a result, regenerate the corpus in the same commit
  and check that only the entries you expected have changed:

      julia --project=. test/golden/generate.jl
      git diff --stat test/golden/corpus.toml

What the corpus leaves out, and why, is stated in comments in
`test/golden/subjects.jl`.

## Tests

    julia --project=. -e 'using Pkg; Pkg.test()'

| Suite | File | Asserts |
|:--|:--|:--|
| Golden | `test/golden.jl` | Output bits match the corpus |
| Layering | `test/layering.jl` | No file uses a name defined in a later layer |
| Quality | `test/quality.jl` | Imports are explicit and current |
| Unit | `test/unit/` | Behaviour, topic by topic |

Shared helpers are in `test/support/`: the exact `BigFloat` value of a pair
(`exactbig`), relative error in working units (`relerr`), and a random
generator the suite owns (`SplitMix64`) so recorded inputs do not depend on
Julia's.

## Speed

    julia benchmark/compare.jl rev:release-1.13 path:.

runs the suite in `benchmark/benchmarks.jl` against both versions on your
machine and prints the ratio for each benchmark. Identical source measures
within about 5%. CI runs the same comparison on every pull request.

## Where code lives

The source is loaded in layers, in the order of the include list in
`src/DoubleFloats.jl`. A file may use only what is loaded above it.

| Layer | Directory | Holds |
|:--|:--|:--|
| 1 | `src/eft/` | Error-free transformations on machine floats |
| 2 | `src/core/` | The type, constructors, predicates, reflection |
| 3 | `src/routes/` | Records that describe a kernel |
| 4 | `src/arith/` | Double-word kernels on tuples; operators; rounding |
| 5 | `src/contract/` | Conversion, comparison, promotion |
| 6 | `src/constants/` | Constants and coefficient tables |
| 7 | `src/elementary/` | Elementary functions, one file per family |
| 8 | `src/batch/` | `simdmap!` and its machinery |
| 9 | `src/io/` | Text in and out |
| 10 | `src/random/` | Random numbers |
| 11 | `src/linalg/` | Matrices |

Julia enforces the order for types, constants, and macros. The layering
test enforces it for functions.

## Conventions

- A method for a function of another module is written `Base.name(...)`
  where it is defined. There is no `import` list.
- Every name taken from another module appears in a `using Module: name`
  statement in `src/DoubleFloats.jl`.
- `unsafe_double(T, hi, lo)` builds a pair without normalizing it. Use it
  only where the code has already established `hi == RN(hi + lo)`.
- Internal names begin with an underscore.
- Format with JuliaFormatter using `.JuliaFormatter.toml`.
- Layout-only commits are listed in `.git-blame-ignore-revs`:

      git config blame.ignoreRevsFile .git-blame-ignore-revs
