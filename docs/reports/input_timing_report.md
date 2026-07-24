# Scalar Function Input-Path Timing Report

*Measured on the current `DoubleFloats.jl` checkout with Julia
1.13.0-DEV.1123 on 2026-07-18.*

This report identifies inputs that take a slower scalar path than an ordinary
finite `Double64` input.  Each timing is the best of seven amortized loops of
50,000 calls; it is useful for comparing paths on this machine, not as a
portable performance guarantee.  The benchmark consumes the high word of each
result so that calls are not optimized away.

| function | ordinary input | ordinary ns/call | slower input or class | slower ns/call | source-path explanation | non-finite / domain behavior |
|:--|--:|--:|:--|--:|:--|:--|
| `sin` | `0.5` | 65 | `10` (any `abs(HI(x)) >= 6.28125`) | 633 | Uses `Float128` range reduction outside the native approximately `2π` range. | `NaN` returns; infinities throw `DomainError`. |
| `cos` | `0.5` | 65 | `10` (any `abs(HI(x)) >= 6.28125`) | 625 | Uses `Float128` range reduction outside the native approximately `2π` range. | `NaN` returns; infinities throw `DomainError`. |
| `tan` | `0.5` | 68 | `1.5`, near `π/2 + kπ` | 645 | Uses `Float128` when the locally reduced cosine has `abs(HI(cos(x))) < 0.1`; any `abs(HI(x)) >= 6.28125` also uses `Float128` (`tan(10)`: 596 ns). | `NaN` returns; infinities throw `DomainError`. |
| `sinh` | `2` | 72 | `709.5` | 1,264 | The narrow `709 <= abs(HI(x)) <= 710.476` range uses `Float128` to avoid intermediate `exp` overflow.  The `abs(x) >= 37.5` shortcut is faster (`sinh(40)`: 56 ns). | `NaN` returns; infinities saturate to signed infinity. |
| `cosh` | `2` | 72 | `709.5` | 1,267 | Same `Float128` bridge near overflow as `sinh`; the `abs(x) >= 37.5` shortcut is faster (`cosh(40)`: 56 ns). | `NaN` returns; either infinity returns `Inf`. |
| `tanh` | `0.25` | 86 | `1` or large finite values | 93 | Crosses from the small-argument `expm1` formula to an `exp(-2abs(x))` formula at `abs(HI(x)) = 0.5`; the observed cost increase is small. | `NaN` returns; infinities approach signed one through the large-argument path. |
| `asin` | `0.5` | 652 | `0.99` | 959 | Every call uses `Float128`; values close to an endpoint were slower in the underlying quad-precision routine. | `NaN` propagates; `abs(x) > 1` (including infinities) is a domain error. |
| `acos` | `0.5` | 652 | `0.99` | 1,079 | Every call uses `Float128`; values close to an endpoint were slower in the underlying quad-precision routine. | `NaN` propagates; `abs(x) > 1` (including infinities) is a domain error. |
| `atan` | `0.1` | 128 | `2` | 164 | Native reduction performs inversion for `abs(x) > 1` and extra angle reductions above `tan(π/16)` and `tan(3π/16)`; no `Float128` fallback for unary `Double64` `atan`. | `NaN` returns; infinities return signed `π/2`. |
| `asinh` | `0.5` | 141 | none observed; `2^55` | 128 | Above `4/eps(Float64) = 2^54`, the code takes the simpler `log(abs(x)) + log(2)` asymptotic path, which was faster rather than slower. | `NaN` and infinities return themselves. |
| `acosh` | `2` | 146 | none observed; `2^55` | 127 | Above `2^54`, the code takes the simpler `log(x) + log(2)` asymptotic path, which was faster rather than slower. | `NaN` and `+Inf` return; values below one and `-Inf` throw `DomainError`. |
| `atanh` | `0.25` | 123 | `0.75` or near one | 224 | At `abs(HI(x)) > 0.5`, uses two `log1p` evaluations instead of one; this is about 1.8x slower (`atanh(0.99)`: 221 ns). | `NaN` returns; `abs(x) > 1` and infinities throw `DomainError`; `atanh(±1)` yields signed infinity. |
| `exp` | `2` | 55 | `-650` (any `HI(x) <= -600`) | 1,254 | Deep negative inputs use `Float128` so the result is formed without an overflowing reciprocal intermediate. | `NaN`, `+Inf`, and `-Inf` are immediate returns (`NaN`, `Inf`, `0`); `HI(x) >= 710` immediately returns `Inf` and measured about 2 ns. |
| `log` | `2` | 114 | no finite slow class observed (`1e100`: 117) | — | Uses native exponent/anchor reduction.  The near-one `log1p` route was faster (`1 + 2^-30`: 69 ns), not slower. | `NaN` and `+Inf` are immediate returns; zero returns `-Inf`; negative values, including `-Inf`, throw `DomainError` (caught `log(-Inf)`: about 1.4 µs). |

## Practical summary

The material slowdowns are the explicit `Float128` fallbacks: large `sin` and
`cos`, pole-adjacent or large `tan`, near-overflow `sinh`/`cosh`, and deeply
negative `exp`.  `asin` and `acos` always use `Float128`, so their baseline is
already high and endpoint-adjacent inputs cost more.  Among fully native paths,
`atanh(abs(x) > 0.5)` is the clearest slower branch.

For hot loops, range-reduce trigonometric arguments before calling `sin`,
`cos`, or `tan` when that is numerically appropriate; avoid evaluating `tan`
near poles unless the result is genuinely required; and do not use exceptions
as control flow for invalid `log`, inverse-trigonometric, or inverse-hyperbolic
inputs.
