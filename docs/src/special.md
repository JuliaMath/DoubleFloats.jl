# Special Functions

These functions accept real `Double64`, `Double32`, and `Double16`
arguments. Load them with `using DoubleFloats`.

| Family | Calls |
|:-------|:------|
| Bessel functions of the first kind | `besselj0(x)`, `besselj1(x)`, `besselj(n, x)` with integer order `n` |
| Bessel functions of the second kind | `bessely0(x)`, `bessely1(x)`, `bessely(n, x)` with integer order `n` |
| Gamma function | `gamma(x)` |
| Error function and its complement | `erf(x)`, `erfc(x)` |
| Arithmetic-geometric mean | `agm(a, b)`, `agm1(x)` for `agm(one(x), x)` |
| Complete elliptic integral of the first kind | `ellipk(m)` with parameter `m` |

For the logarithm of the absolute gamma function and its sign, use
`DoubleFloats.logabsgamma(x)`. The Bessel, gamma, and error functions
use `Float128` internally. See the [Accuracy Report](accuracy_report.md)
for sampled functions and domains.

## Arithmetic-geometric mean and elliptic integral

Use same-type positive inputs for the usual arithmetic-geometric mean.
The iteration stops when the gap ceases to shrink. `ellipk(m)` uses
the parameter `m`. If your formula is expressed in terms of the modulus
`k`, pass `k^2`. The implemented real domain is `0 ≤ m ≤ 1`, with
an infinite result at `m = 1`.

```@example elliptic_integral
using DoubleFloats

k = df64"0.5"
m = k^2
@assert isinf(ellipk(one(Double64)))
string(ellipk(m))
```
