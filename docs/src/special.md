# Special Functions

DoubleFloats supports some special functions of real values.

_`x` below is any of `Double64`, `Double32`, `Double16`_

## Bessel Functions

- `besselj0(x)`, besselj1(x)`
    - `besselj(0, x)`, `besselj(1, x)`
    
- `bessely0(x)`, `bessely1(x)`
    - `bessely(0, x)`, `bessely(1, x)`

- `besselj(nu::Int, x)`
    - Bessel function of the first kind

- `bessely(nu::Int, x)`
    - Bessel function of the second kind


## Gamma Functions

- `gamma(x)`
    - gamma function
    
- `loggamma(x)`, `lgamma(x)`
    - log gamma function
    
## Error Functions

- `erf(x)`
    - error function
    
- `erfc(x)`
    - complementary error function (`1-erf(x)`)
    
## Arithmetic-Geometric Mean

- `agm(a, b)`, `agm1(x) = agm(1, x)`
    - converges for all same-signed operands; the iteration stops at its
      roundoff floor, so no operand scale can stall it

## Elliptic Integrals

- `ellipk(m)`
    - Complete Elliptic Integral of the First Kind, `K(m)` with parameter `m`
    - accurate over the whole domain `0 <= m < 1`, including arbitrarily
      close to `m = 1`
