# Where the exponential error tails come from

*Conference briefing on the exponential kernels at revision `d63ef398`*

## Follow-up after the implementation

The signed error budgets below describe the original kernels. The
first revision used a 16-entry table and one multiplication
to reconstruct the result. The latest ordinary Double64 paths refine
the reduction to a 128-entry table. `Double64 expm1` now carries the
offset from one directly through input head magnitudes of one.
The regenerated [Accuracy Report](reports/accuracy_report.md) keeps
ordinary relative accuracy separate from the underflow lattice and
counts zero and infinite results. See the
[Technical Guide](src/technicalguide.md#elementary-function-algorithms)
for the current algorithms and batch timings.

In the 16-entry revision, the largest ordinary scores were 0.43 for
`Double64 exp`, 0.56 for `Double64 exp2`, and 0.63 for
`Double32 exp2`. The `Double64 expm1` maximum was 1.11.
All 18 subnormal `Double32 exp` results still match nearest lattice
rounding.

## Abstract

The largest reported error, `157483982232.15` for `exp(::Double32)`,
comes from rounding a positive subnormal result to the nearest
representable value. Its absolute error is **0.1295 of one available
subnormal step**. The report divides that error by a much smaller
nominal double-word error unit. The outliers of two to four report
units for normal results have a different origin. Rounding in Horner
evaluation and three successive squarings dominates the native
exponential kernel. The outer branch of `expm1(::Double64)` magnifies
the inherited relative error of `exp` by measuring it against
`exp(x) - 1`.

## 1. The measurement and the six outliers

For a nonzero reference value $y$, the report computes

$$
U = \frac{|\widehat y-y|}{|y|\,\varepsilon_D}, \qquad
\varepsilon_{64}=2^{-104}, \quad \varepsilon_{32}=2^{-46}.
$$

Here $\widehat y$ is the high-precision sum of the two returned
components. $U$ expresses a relative error in units of `eps(D)`.
The local spacing between representable sums depends on the components
and their exponents. In particular, an absolute spacing floor near
underflow can be vastly larger than $|y|\varepsilon_D$.
See [Goldberg (1991)](src/references.md#goldberg-1991) for relative error, ulps, and gradual underflow.

The replay used seed `20260718` and the report's draw order on Julia
1.13.3 at commit `d63ef398`. The reference used MPFR at 512 bits on the sum of
the actual input components. The input column gives the constructor
arguments for each maximum. In the sample column, the first number is
the draw within the row and the second is the number of retained
finite results. The generator starts each row with 250 draws and
skips nonfinite results. It runs the `Double64` scalar and matrix
sections before the `Double32` scalar section, so reseeding each row
would change the sample. See the [generator](https://github.com/JuliaMath/DoubleFloats.jl/blob/d63ef39842bae3dad3f5b6f36e405ce50e6c5609/docs/reports/accuracies.jl),
[recorded report](https://github.com/JuliaMath/DoubleFloats.jl/blob/d63ef39842bae3dad3f5b6f36e405ce50e6c5609/docs/reports/accuracy_report.md), and
[the GNU MPFR manual](src/references.md#gnu-mpfr-manual) for the reference operations.

| Type | Function | Draw / retained | Input components | Median $U$ | Maximum $U$ |
|:---|:---|---:|:---|---:|---:|
| `Double64` | `exp` | 23 / 250 | `(43.84686880209618, 0.0)` | 0.34 | 3.326343 |
| `Double64` | `expm1` | 215 / 250 | `(0.7699138649020267, 0.0)` | 0.34 | 4.462367 |
| `Double64` | `exp2` | 68 / 250 | `(84.22552088106674, 0.0)` | 0.32 | 2.401192 |
| `Double32` | `exp` | 184 / 235 | `(-99.220726f0, 3.6388583f-6)` | 0.02 | 157483982232.15 |
| `Double32` | `expm1` | 102 / 250 | `(-0.7832272f0, -2.8476283f-8)` | 0.02 | 0.115293 |
| `Double32` | `exp2` | 150 / 250 | `(5.4395943f0, 5.8430174f-8)` | 0.37 | 3.130619 |

These are sample maxima. The reference evaluates `f(BigFloat(x))`
after conversion to the tested type, so errors in converting the
original random draw to that type are outside the measurement.
The `Double64` draws in these three rows come from single
`Float64` values and therefore have zero low components.

## 2. Why the largest number occurs in `exp(::Double32)`

### The available lattice

Every finite `Float32` component is an integer multiple of
$\Delta=2^{-149}\approx1.40129846\times10^{-45}$. A sum of two
such components is still an integer multiple of $\Delta$. Near
underflow, the nominal double-word scale $y\,2^{-46}$ keeps shrinking
with $y$, while the absolute spacing floor stays fixed.

At the worst sample the exact input is
`-99.2207223743253052816726267337799072265625`, with component bit
patterns `0xc2c67103` and `0x3674331c`. The comparison is

| Quantity | Value |
|:---|---:|
| Reference $y/\Delta$ | 57.87048689249684 |
| Returned $\widehat y/\Delta$ | 58 |
| Signed error in lattice steps | +0.12951310750316 |
| Absolute error | $1.81486519\times10^{-46}$ |
| Relative error | $2.23798199\times10^{-3}$ |
| Relative error divided by $2^{-46}$ | 157483982232.15 |

The nearest lattice point is $58\Delta$. At this magnitude, one
step is about $1.216\times10^{12}$ report units. Even an exact
exponential followed by ideal rounding to the destination would
return the same value.
Extending the domain below $-150\log(2)\approx-103.97208$ would give
correctly rounded zero from some positive exact values. At `x = -105`,
for example, the relative error is one and the report metric would be
$2^{46}$.

### Where the source rounds

For sufficiently negative inputs, `exp(::Double32)` converts the
argument to base 2 and dispatches to the low-range path. This path
uses the reduced high and low components to choose an integer lattice
index and returns a zero low component. Near a midpoint, directed
MPFR evaluation refines the choice. In the ordinary path,
`Double32(exp(Double64(x)))` evaluates the kernel in double-double
precision before converting. The conversion takes the `Float64`
head and splits it into a `Float32` head and residual. That residual
can itself be subnormal or zero even when the returned head is normal.
See [the exponential paths](https://github.com/JuliaMath/DoubleFloats.jl/blob/d63ef39842bae3dad3f5b6f36e405ce50e6c5609/src/math/elementary/explog.jl#L315-L429)
and [the two-step conversion](https://github.com/JuliaMath/DoubleFloats.jl/blob/d63ef39842bae3dad3f5b6f36e405ce50e6c5609/src/Double.jl#L117-L125).

The finite `Double32 exp` samples make the transition visible.
The split at $2^{-101}$ is a diagnostic cutoff for this table.
The low component can lose bits above the subnormal head threshold
$2^{-126}$.

| Reference result range | Count | Maximum $U$ | Observed rounding |
|:---|---:|---:|:---|
| $0<y<2^{-126}$ | 18 | $1.57484\times10^{11}$ | All matched the nearest $2^{-149}$ lattice point |
| $2^{-126}\le y<2^{-101}$ | 14 | $7.97864\times10^5$ | The worst case rounded by 0.360586 lattice steps |
| $y\ge2^{-101}$ | 203 | 0.119816 | The worst case was in the ordinary promoted path |

Computing the worst subnormal sample in `Double64` from the same
input gives an error of about $1.6\times10^{-18}$ when expressed in
the report's `Double32` units **before** narrowing. Narrowing to the
actual destination precision restores the lattice constraint.
A separate 8,193-point sweep of `Double32` inputs from −110 to
−87.34 found zero disagreements with the nearest lattice point.
A second check used three adjacent low components near each of
11 output midpoints, including the zero and normal transitions.
All 33 results agreed with the reference rounding. These checks test
selected inputs and transitions.

## 3. The native kernel for ordinary `exp` and `exp2`

The scalar kernel writes its base-2 argument as $n+8r$, with
$|r|$ near or below $1/16$. It evaluates a tapered polynomial $P(r)$
for $2^r$, squares three times, then scales by $2^n$. `exp` first
forms the base-2 argument with a three-component product using
$\log_2(e)$. Native `exp2` takes its input as the base-2 argument
directly. The polynomial in the source has degree 13 for `Double64`
and 7 for `Double32`.
See [conversion, approximation, and reconstruction](https://github.com/JuliaMath/DoubleFloats.jl/blob/d63ef39842bae3dad3f5b6f36e405ce50e6c5609/src/math/elementary/explog.jl#L173-L281).

### A signed budget at each sampled maximum

Each entry is a stage's signed contribution to final error in the
report's units. To measure the contribution, the experiment changes
one stage from ideal to actual, then computes the remaining powers and
scale in MPFR. The differences telescope to the observed error. The
stored-polynomial row evaluates the exact values of the stored
coefficients in MPFR. The Horner row combines the scalar taper and
double-word evaluation roundings. The separate effect of using the
high argument component in the tapered tail was at most
$4.8\times10^{-5}$ units on the `Double64 exp` row and
$1.1\times10^{-4}$ on the `Double32 exp2` row.

| Stage | `Double64 exp` | `Double64 exp2` | `Double32 exp2` |
|:---|---:|---:|---:|
| Base conversion product | $-1.05\times10^{-17}$ | 0 | 0 |
| Reduce and combine the argument components | +0.015143 | 0 | 0 |
| Stored polynomial versus exact exponential | +0.001728 | +0.014763 | −0.003022 |
| Rounded Horner evaluation, including taper | −0.807753 | −0.929264 | −0.888519 |
| First square | −1.392867 | −0.932368 | −2.070739 |
| Second square | −0.808194 | +0.065991 | −0.225138 |
| Third square | −0.334398 | −0.620314 | +0.056798 |
| Final power-of-two scaling | 0 | 0 | 0 |
| **Total** | **−3.326343** | **−2.401192** | **−3.130619** |

An initial relative error $\eta$ in $P(r)$ becomes approximately
$8\eta$ after three squarings. Local relative errors in the three
squares are propagated by factors of roughly four, two, and one.
The square kernel computes the leading product and its residual,
then accumulates $2hl$ into the residual with an FMA. It omits $l^2$
from $(h+l)^2$. That omission biases the result downward, while
rounding the residual can have either sign. At the worst
`Double64 exp` sample, the omitted $l^2$ accounted for about 38–44%
of each square's net negative local error. The measured Horner error
also includes the rounding of cross terms and low residuals.
See [the Horner step](https://github.com/JuliaMath/DoubleFloats.jl/blob/d63ef39842bae3dad3f5b6f36e405ce50e6c5609/src/math/elementary/explog.jl#L91-L120) and
[the square kernel](https://github.com/JuliaMath/DoubleFloats.jl/blob/d63ef39842bae3dad3f5b6f36e405ce50e6c5609/src/math/ops/op_dd_dd.jl#L43-L49).

Replacing each square in the three cases by an MPFR square followed
by a two-component split reduced the absolute errors to 1.157, 0.904,
and 1.103 report units, respectively. Splitting the MPFR-evaluated
stored polynomial to two components **before** the ordinary squarings
left each of the three maxima unchanged. At these inputs, the split
gives the same pair as the runtime Horner evaluation.
Avoiding the intermediate rounding of that value is a separate
design question from improving its Horner evaluation.

An independent grid of 4,097 evenly spaced values of $r$ in
$[-1/16,1/16]$ confirmed the difference in scale. It used zero low
argument components and no final rescaling.

| Kernel | Largest stored-polynomial error after exact $P(r)^8$ | Largest complete kernel error |
|:---|---:|---:|
| `Double64` | 0.02391 | 4.44352 |
| `Double32` | 0.01070 | 3.95583 |

The native `Double32 exp2` row uses this `Float32`-component
polynomial and squaring path. Its sampled outputs have normal heads.
The split power-of-two scaling added zero measured error for all 250
samples. By comparison, ordinary `Double32 exp` uses a wider kernel
then narrows, which explains its much smaller errors away from the
bottom of the exponent range.

## 4. Why `expm1` behaves differently

For `abs(HI(x)) ≥ 0.5`, the scalar function evaluates `exp(x) - 1`.
If the exponential has relative error $\eta$, its contribution to the
relative error of `expm1` is
$\eta\,\exp(x)/(\exp(x)-1)$, before any rounding of the subtraction.
For smaller input magnitudes, the implementation scales the argument,
evaluates a Taylor polynomial for `expm1`, and repeatedly applies
$\operatorname{expm1}(2t)=e(e+2)$ with
$e=\operatorname{expm1}(t)$.
See [the two branches](https://github.com/JuliaMath/DoubleFloats.jl/blob/d63ef39842bae3dad3f5b6f36e405ce50e6c5609/src/math/elementary/explog.jl#L710-L737).

- **`Double64` outer branch.** At the worst sample,
  `x = 0.7699138649020267`, the exponential contributes
  −2.396055 units on its own scale. The ratio
  $\exp(x)/|\exp(x)-1|=1.862381$ brings that to −4.462367 on
  the `expm1` scale. The subtraction of one was exact on the
  computed pair. The largest of the 133 outer-branch errors was
  therefore inherited from the exponential and amplified by the
  smaller result denominator.
- **`Double64` inner branch.** The largest of its 117 errors was
  1.109188 units at `x = 0.49044118974494033`. The pure Taylor
  truncation contributed about $-4.1\times10^{-8}$ report units,
  and the rounded coefficients contributed about $-1.9\times10^{-7}$.
  The remaining error came from the double-word evaluation and
  seven doublings, with the doublings accounting for nearly all of it.
- **`Double32`.** The outer-branch maximum was only 0.115293 units.
  At that input, the promoted exponential contributed −0.000206
  on the `expm1` scale, while the final double-word subtraction
  contributed −0.115086. The inner branch reached 0.102169 units,
  primarily from arithmetic in its evaluation and doublings.

## 5. Implications for reporting and approximation

1. **Report underflow rounding on the available grid.** Keep the
   nominal relative error where it is informative. For subnormal
   results and for normal heads with quantized low components, also
   report absolute error, error in $2^{-149}$ steps, and agreement
   with reference rounding where the lattice specifies the result.
   Count overflow and rounded-to-zero results explicitly. This makes
   the representational error visible without obscuring the few-unit
   errors in ordinary ranges.
2. **Improve reconstruction before increasing polynomial degree.**
   The stored polynomials have small measured approximation errors.
   The error budget points first to retained precision through the
   early squares and to the rounding of the starting approximation.
   An improvement should demonstrate a lower signed error tail on
   the same inputs and on dense sweeps of the reduced interval.
3. **Evaluate `expm1` branches separately.** Improvements to
   `exp` carry into the outer branch. A direct `expm1`
   approximation on a wider interval is a separate candidate if
   the amplification remains important. Choose tolerances and test
   points around the branch boundary, both signs, and values near zero.

## Reproduction appendix

Save the following block as a Julia script and run it from a package
checkout at revision `d63ef398` to reproduce the original values.
It checks the six fixed inputs independently of the
random stream. The low-range assertion distinguishes a bad lattice
choice from a large nominal error for the correct choice.

```julia
using DoubleFloats, Printf

setprecision(BigFloat, 512) do
    examples = (
        (exp,   Double64(43.84686880209618)),
        (expm1, Double64(0.7699138649020267)),
        (exp2,  Double64(84.22552088106674)),
        (exp,   Double32(-99.220726f0, 3.6388583f-6)),
        (expm1, Double32(-0.7832272f0, -2.8476283f-8)),
        (exp2,  Double32(5.4395943f0, 5.8430174f-8)),
    )
    expected = (-3.326343, -4.462367, -2.401192,
                157483982232.1534, -0.115293, -3.130619)
    for ((f, x), signed_reference) in zip(examples, expected)
        y = f(BigFloat(x))
        got = BigFloat(f(x))
        signed_units = Float64((got - y) / (abs(y) * BigFloat(eps(typeof(x)))))
        @printf("%-8s %-5s %+.9g\n", string(typeof(x)), string(f), signed_units)
        @assert isapprox(signed_units, signed_reference; atol=5e-7, rtol=1e-12)
    end

    f, x = examples[4]
    Δ = BigFloat(2)^(-149)
    y = f(BigFloat(x))
    got = BigFloat(f(x))
    @assert got == round(y / Δ) * Δ == 58 * Δ
end
```

To reconstruct the ordinary error budget, read the hexadecimal
coefficients as the component type before converting them to MPFR.
Form the ideal stage sequence from $y$, the converted argument,
the reduced argument, and the exact polynomial. Then replay
`_exp2_poly` and each call to `square_dd_dd_`. For states holding
$P$, $P^2$, or $P^4$, take the remaining powers in MPFR and multiply
by $2^n$ before comparing. Subtract consecutive completed estimates
and divide by $|y|\,\varepsilon_D$. Verify that the last reconstructed
pair agrees with the public method. This attributes error at the
sampled inputs without relying on a bound for an unmeasured domain.
