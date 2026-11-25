# Balancing speed and accuracy

A suitable path depends on the function, the input range, and the
error the application can tolerate. For vector calls, it also depends
on which inputs share a block. The [Technical Guide](src/technicalguide.md#to-be-well-balanced)
summarizes how to make that choice. The measurements and calculations
below show how it changes with the workload.

Two gains account for the results. A faster scalar method benefits
every call that can use it, including scalar evaluation inside a
batch. A native batch can offer a further gain. On the matched dense
inputs, the eleven Double64 elementary batches were **2.96–3.59×**
faster than current scalar evaluation and returned identical output
words. Six Double32 native batches were **1.44–2.70×** faster than
current scalar evaluation and had higher sampled maximum errors.
The larger before/after gains in the manual include changes to the
scalar baseline. [Technical Guide benchmarks](src/technicalguide.md#double32-benchmarks)

## Reading the measurements

The matched run used revision `2d860805`, Julia 1.10.10 with a [native CPU target](src/glossary.md#glossary-compiler-target), and one thread on an Intel i9-14900K. Each case used
32,768 inputs and [preallocated outputs](src/glossary.md#glossary-destination). Times are medians of
nine interleaved timing samples, with eight calls per sample.
The scalar loop calls the public function on each input. The batch
uses serial `DoubleFloats.simdmap!` on [dense, disjoint vectors](src/glossary.md#glossary-dense-storage) and
includes eligibility checks and [fallback](src/glossary.md#glossary-kernel). A ratio close to 1× means
the measured times were close. For example, the Double32 `exp2`
dense scalar and batch medians differ by 0.066 ns per element, while
the batch's [interquartile range](src/glossary.md#glossary-iqr) spans 0.139 ns per element. Treat
small differences of this size as timing-sensitive.

For a finite, nonzero reference [$y$](src/glossary.md#glossary-reported-error) and computed value
[$\widehat y$](src/glossary.md#glossary-reported-error), the score [$E$](src/glossary.md#glossary-reported-error) is
$E=|\widehat y-y|/(|y|\epsilon_D)$. The working-precision unit
[$\epsilon_D$](src/glossary.md#glossary-working-unit) is $2^{-104}$ for Double64 and $2^{-46}$ for Double32,
so compare their scores to targets in their respective units.
The reference uses both input words and 512-bit [BigFloat](src/glossary.md#glossary-bigfloat) arithmetic.
The tables show the [99th percentile](src/glossary.md#glossary-percentile) (𝐏₉₉) and the maximum of each
sample. Tuple results use the largest component score per input.
Complex results use the complex magnitude. A sampled maximum gives
evidence for the tested inputs. A domain-wide bound requires further
analysis. [Accuracy Report](reports/accuracy_report.md)

### Scalar evaluation

Each row uses the same head distribution in both formats. The
before revisions are `cfeee67e` for Double32 and `bbe7832c` for
Double64. The error columns describe the current scalar method.

| Function | Dense head interval | D32 ns before → after | D32 𝐏₉₉ / max | D64 ns before → after | D64 𝐏₉₉ / max |
| --- | --- | --- | --- | --- | --- |
| `exp` | 0.25–2.25 | 21.30 → 4.86 | 0.107 / 0.130 | 27.40 → 15.73 | 0.434 / 0.938 |
| `exp2` | 0.25–2.25 | 13.06 → 4.66 | 0.113 / 0.614 | 24.98 → 15.81 | 0.442 / 1.009 |
| `expm1` | 0.035–0.06 | 35.23 → 6.50 | 0.093 / 0.115 | 88.81 → 28.80 | 1.073 / 1.579 |
| `log` | 1.125–2.25 | 21.64 → 6.13 | 0.105 / 0.130 | 26.47 → 17.98 | 0.301 / 0.525 |
| `log2` | 1.125–2.25 | 21.47 → 6.29 | 0.109 / 0.131 | 24.08 → 17.34 | 0.301 / 0.450 |
| `log1p` | 0.008–0.045 | 23.65 → 5.35 | 0.108 / 0.130 | 22.10 → 18.79 | 0.581 / 1.149 |
| `atan` | 0.015–0.95 | 43.87 → 9.99 | 0.106 / 0.131 | 145.28 → 37.16 | 0.283 / 0.992 |
| `tan` | 0.025–0.475 | 36.70 → 6.03 | 0.107 / 0.132 | 61.65 → 31.19 | 0.250 / 0.358 |
| `sinh` | 0.025–0.95 | 30.07 → 6.44 | 0.108 / 0.132 | 93.69 → 25.02 | 0.249 / 0.397 |
| `cosh` | 0.025–0.95 | 30.06 → 3.87 | 0.118 / 0.132 | 49.16 → 24.29 | 0.189 / 0.367 |
| `tanh` | 0.025–0.95 | 36.25 → 8.57 | 0.108 / 0.139 | 72.03 → 30.45 | 0.275 / 0.522 |

The largest gains come from doing less arithmetic in a range where
a simpler evaluation is accurate enough. Double64 uses fine tables
and [short reductions](src/glossary.md#glossary-range-reduction) for the exponentials and logarithms, [dyadic anchors](src/glossary.md#glossary-dyadic) for `atan`, and bounded direct approximations for `tan` and
the hyperbolic functions. The measured Double64 `sinh` maximum fell
from 2.322 to 0.397 units, and `tan` fell from 1.229 to 0.358, while
both got faster. For `exp` and `exp2`, the faster methods raised the
sampled maxima from 0.831 to 0.938 and 0.837 to 1.009 respectively.
The `expm1` maximum fell slightly, from 1.603 to 1.579, while 𝐏₉₉ rose
from 0.901 to 1.073. A tail-percentile target and a maximum target
therefore give different assessments of that change.
[Scalar implementation details](src/technicalguide.md#faster-double64-elementary-kernels)

For Double32, [widening](src/glossary.md#glossary-widening) is fast when the sum of the words is exactly
representable in Float64 and the result is in a safe range for splitting
back into two Float32 words. All eleven dense fixtures admitted
32,103 of 32,768 inputs to this scalar route. Some low words were too
sparse to survive widening. The largest scalar Double32 `exp2` error
came from the fallback at the pair `(1.7698154f0, 3.6909767f-10)`.
The `exp2` maximum nevertheless fell from 0.911 to 0.614 units on the
matched inputs. Its 𝐏₉₉ fell from 0.442 to 0.113.

The same input conversion error can matter much more near a root.
If rounding the input changes $x$ by [$\delta$](src/glossary.md#glossary-delta), the first-order relative
change in [$f(x)$](src/glossary.md#glossary-function-notation) is about $|f'(x)/f(x)|\,|\delta|$ when $f(x)\ne0$.
For `exp` the factor $|f'(x)/f(x)|$ is one. For `log` and `log2` it
grows as $1/|x-1|$ near one. For example,
`Double32(1.0f0, Float32(2^-60))` has a logarithm of approximately
$2^{-60}$, which would disappear if conversion rounded the input to
one. The two-word path retains it. Exact widening removes this input
error. The subsequent function evaluation and split still round.
[Double32 implementation details](src/technicalguide.md#faster-double32-elementary-kernels)

Several functions preserve accuracy by keeping a small quantity
explicit. `expm1` carries the offset from one through reconstruction.
`log1p` starts with $x$ rather than first forming $1+x$.
`sinh` keeps $x$ as its leading term. The local `tan` and `tanh`
formulas carry a small correction to $x$. The `tan` fallback pays for
more accurate phase reduction near poles. For `cosh`, an even expansion
or [guarded](src/glossary.md#glossary-kernel) widening makes ordinary scalar evaluation cheap.
[Elementary function algorithms](src/technicalguide.md#elementary-function-algorithms)

At exponential [underflow](src/glossary.md#glossary-underflow), the least positive subnormal [$\Delta$](src/glossary.md#glossary-rounding-grid) sets
the spacing that can be represented in the result. Half a grid step
corresponds to $\Delta/(2|y|\epsilon_D)$ in relative working-precision
units. This quantity grows as the reference shrinks. Use nearest-grid
agreement, absolute error, and zero or overflow classification at
the format limits. The targeted `exp` and `exp2` probes in the
Accuracy Report agreed with the nearest grid on all 22 subnormal or
grid-limited inputs per operation and format.
[Exponential rounding analysis](worstulps.md)

### Vector evaluation

Each speedup is current scalar time divided by batch time on the same
inputs. The mixed fixtures replace 328 randomly selected lanes with
the head in the last column and a zero low word. These inputs are
valid. Some belong to a different fast regime, and some fall back to
scalar evaluation. For example, 1.015625 belongs to the direct
Double64 logarithm regime while the other inputs use the table.

| Function | D32 dense / mixed | D32 dense 𝐏₉₉ / max | D64 dense / mixed | D64 dense 𝐏₉₉ / max | Mixed heads D32 / D64 |
| --- | --- | --- | --- | --- | --- |
| `exp` | 0.99× / 0.99× | 0.107 / 0.130 | 2.96× / 1.85× | 0.434 / 0.938 | 81 / 705 |
| `exp2` | 0.99× / 0.98× | 0.113 / 0.614 | 3.03× / 2.86× | 0.442 / 1.009 | 113 / 0 |
| `expm1` | 0.98× / 0.98× | 0.093 / 0.115 | 3.57× / 1.99× | 1.073 / 1.579 | 0.75 / 0.25 |
| `log` | 0.99× / 0.99× | 0.105 / 0.130 | 3.08× / 1.88× | 0.301 / 0.525 | 1.015625 / 1.015625 |
| `log2` | 1.44× / 1.25× | 0.288 / 0.443 | 2.97× / 1.85× | 0.301 / 0.450 | 1.015625 / 1.015625 |
| `log1p` | 2.59× / 1.61× | 0.578 / 1.151 | 3.21× / 1.91× | 0.581 / 1.149 | 0.075 / 0.075 |
| `atan` | 1.75× / 1.44× | 0.283 / 0.826 | 3.59× / 2.03× | 0.283 / 0.992 | 1.125 / 1.125 |
| `tan` | 1.93× / 1.42× | 0.243 / 0.403 | 3.41× / 2.43× | 0.250 / 0.358 | 0.625 / 7 |
| `sinh` | 2.28× / 1.54× | 0.252 / 0.396 | 3.25× / 1.95× | 0.249 / 0.397 | 1.05 / 1.05 |
| `cosh` | 0.97× / 0.97× | 0.118 / 0.132 | 3.27× / 1.93× | 0.189 / 0.367 | 1.05 / 1.05 |
| `tanh` | 2.70× / 1.70× | 0.276 / 0.518 | 3.37× / 1.97× | 0.275 / 0.522 | 1.05 / 1.05 |

All eleven Double64 comparisons returned identical words on both
routes for both fixtures. In Double32, `exp`, `exp2`, `expm1`, `log`,
and `cosh` use the scalar path inside the vector entry point. The
native implementations of `log2`, `log1p`, `atan`, `tan`, `sinh`,
and `tanh` use two-Float32 arithmetic. On dense fixtures their
maxima were 0.396–1.151 units. An independent wider stress run reached
about 1.255 for the native `log1p` path. A trial native `expm1`
kernel was slower than widening and exceeded 2.2 units, so its batch
retains scalar evaluation. [Double32 acceleration results](double32better.md#validation-results)

The following cases cover additional Double64 and ComplexDF64
operations. Scalar and batch maxima agree at the displayed precision.
The scalar baseline for `sincos`, `cis`, and `normalize` already
computes both components in one call.

| Operation | Dense head interval | Scalar → batch ns | Speedup | Batch 𝐏₉₉ / max |
| --- | --- | --- | --- | --- |
| `sin` | 0.012–0.08 | 29.85 → 7.30 | 4.09× | 0.338 / 0.599 |
| `cos` | 0.012–0.08 | 31.00 → 24.33 | 1.27× | 0.139 / 0.288 |
| `sincos` | 0.012–0.08 | 33.73 → 25.12 | 1.34× | 0.338 / 0.599 |
| `cis` | 0.012–0.08 | 64.91 → 56.43 | 1.15× | 0.139 / 0.287 |
| `cot` | 0.012–0.08 | 47.41 → 11.09 | 4.27× | 0.515 / 0.865 |
| `exp10` | 0.55–8 | 27.19 → 8.19 | 3.32× | 0.425 / 0.839 |
| `log10` | 1.125–2.25 | 25.91 → 7.38 | 3.51× | 0.404 / 0.733 |
| `inv` | 0.25–8 | 4.77 → 1.85 | 2.57× | 0.459 / 0.690 |
| `sqrt` | 0.25–8 | 1.76 → 1.76 | 1.00× | 0.278 / 0.502 |
| `square` | 0.25–8 | 4.23 → 4.24 | 1.00× | 0.389 / 0.704 |
| `abs2` | 0.25–8 | 4.24 → 4.25 | 1.00× | 0.389 / 0.704 |
| `csch` | 1.2–4.5 | 45.75 → 9.61 | 4.76× | 0.623 / 1.128 |
| `sech` | 1.2–4.5 | 46.12 → 9.67 | 4.77× | 0.604 / 1.032 |
| `coth` | 1.2–4.5 | 70.95 → 10.32 | 6.87× | 0.692 / 1.969 |
| `asinh` | 0.006–0.04 | 44.57 → 17.37 | 2.57× | 0.606 / 1.164 |
| `acosh` | 1.000025–1.00009 | 36.06 → 15.43 | 2.34× | 0.648 / 1.351 |
| `atanh` | 0.006–0.02 | 30.75 → 13.47 | 2.28× | 0.667 / 1.366 |
| `acsch` | 32–46 | 57.57 → 20.26 | 2.84× | 0.679 / 1.147 |
| `asech` | 0.99993–0.99997 | 46.74 → 17.58 | 2.66× | 0.701 / 1.534 |
| `acoth` | 42–70 | 34.89 → 14.82 | 2.35× | 0.710 / 1.360 |
| `atan(y,x)` | Both 0.25–8 | 450.53 → 449.36 | 1.00× | 0.104 / 0.125 |
| `hypot` | Both 0.25–8 | 32.41 → 9.37 | 3.46× | 0.563 / 1.170 |
| `normalize` | Both 0.25–8 | 53.10 → 14.09 | 3.77× | 0.802 / 1.434 |
| `^` with scalar exponent 5 | Base 0.55–1.45 | 35.49 → 1.59 | 22.25× | 0.990 / 1.725 |
| `^` with vector exponent | Base 1.15–1.45, exponent 0.25–0.85 | 50.90 → 14.12 | 3.61× | 0.465 / 1.021 |
| Complex `exp` | Real 1.2–4.5, imaginary 0.012–0.08 | 78.59 → 11.55 | 6.80× | 0.533 / 0.980 |

The gains depend on what the batch can simplify. For example,
a constant exponent of 5 selects a short chain of squarings and
multiplications. A vector of exponents uses the positive-base
logarithm/exponential composition. Bounded inputs keep intermediate
values in range for `hypot` and paired `normalize`. The incremental
gains for `sincos` and `cis` were modest on this compiler target.
Binary `atan`, `sqrt`, `square`, and `abs2` ran near scalar
throughput in these fixtures. The applicable input and result types
are listed with the registered kernels.
[Elementary vector kernels](src/technicalguide.md#elementary-vector-kernels)

## Comparing accuracy and speed together

Start with requirements that every candidate must satisfy. These
may include [signed zero](src/glossary.md#glossary-signed-zero), [domain behavior](src/glossary.md#glossary-domain), assignment order, [overlap](src/glossary.md#glossary-aliasing),
and a hard accuracy ceiling. The measurements give a sample-based
screen for the numerical requirements. At a 1.52-unit maximum, all
six native Double32 kernels pass the dense sampled screen. Double64
`expm1`, `coth`, `asech`, and integer power with exponent 5 exceed
that ceiling on their tested inputs. These cases pass the 2.2-unit
screen. At 1.0 unit, the Double32 `log1p` batch and Double64 `exp2`,
`expm1`, and `log1p` exceed the dense sampled ceiling. The Double64
scalar and batch words agree for those operations, so switching the
execution route gives the same sampled error.

Use the hard ceiling to rule out any route that misses it. If a
remaining route is faster with equal or smaller error, it can be
chosen directly for the measured workload. A weighted [crossover](src/glossary.md#glossary-model-weight)
helps when one route is faster and the other is more accurate.
Test sensitive regions and input layouts separately before applying
that choice to a broader workload.

After screening, a graded comparison can express how well each
candidate fits the workload. The categories include function, format,
range, input arrangement, storage, and target.

#### Normalizing time and error

For candidate [$k$](src/glossary.md#glossary-model-feasibility), compare its
normalized time [$q_k$](src/glossary.md#glossary-model-scores) with its
normalized error [$a_k$](src/glossary.md#glossary-model-scores).

Let [$T_s$](src/glossary.md#glossary-model-time) denote the scalar baseline time, [$T_k$](src/glossary.md#glossary-model-time) the candidate time,
and [$\sigma$](src/glossary.md#glossary-model-time) the requested speedup. The two errors [$E_{99,k}$](src/glossary.md#glossary-model-targets)
and [$E_{\max,k}$](src/glossary.md#glossary-model-targets) are the candidate's 𝐏₉₉ and maximum. The corresponding
targets are [$\tau_{99}$](src/glossary.md#glossary-model-targets) and [$\tau_{\max}$](src/glossary.md#glossary-model-targets).

```math
\begin{aligned}
q_k &= \frac{\sigma T_k}{T_s}, \\
a_k &= \max \left\{\frac{E_{99,k}}{\tau_{99}},
                     \frac{E_{\max,k}}{\tau_{\max}}\right\}.
\end{aligned}
```

The speed and accuracy grades $1/(1+q_k)$ and $1/(1+a_k)$ reach
one half when the candidate meets the corresponding target exactly.
For workload [$c$](src/glossary.md#glossary-model-feasibility), the joint
grade [$Q(c,k)$](src/glossary.md#glossary-model-grade) takes the minimum
across requirements. The indicator [$I$](src/glossary.md#glossary-model-feasibility)
marks candidates that pass the hard screen. The optional grade
[$\mu_C$](src/glossary.md#glossary-model-grade) measures coverage.

```math
Q(c,k) = \min \left\{I(c,k), \frac{1}{1+q_k},
                       \frac{1}{1+a_k}, \mu_C(c,k)\right\}.
```

Set the coverage grade to one for ordinary timing comparisons, since
coverage already affects the measured time. An explicit coverage requirement can grade candidates
separately. Taking $\max_k Q(c,k)$ gives the best joint grade for
that workload.
These grades express chosen preferences and have no probability
interpretation. [Zadeh (1965)](src/references.md#zadeh-1965)

For a concrete target, take $\sigma=2$, $\tau_{99}=1$, and
$\tau_{\max}=2.2$. Dense Double32 `log1p`, `sinh`, and `tanh`
meet all three targets. They miss the speed target with the mixed
inputs. All eleven dense Double64 batches meet the speed and maximum
targets. Only `expm1` misses the 𝐏₉₉ target, with an observed value
of about 1.0735.

### The accuracy weight at a crossover

A faster candidate with the same sampled error already wins on the
time axis. When the faster route spends some accuracy margin, an
explicit preference can resolve the choice. Give accuracy a weight
[$w$](src/glossary.md#glossary-model-weight) between zero and one and minimize the weighted log cost [$L_w(k)$](src/glossary.md#glossary-model-weight).
Its value is $L_w(k)=(1-w)\log q_k+w\log a_k$. Use a common positive floor for zero
scores. A graded preference for [$v$](src/glossary.md#glossary-model-candidates) over [$s$](src/glossary.md#glossary-model-candidates) is
$[1+\exp(L_w(v)-L_w(s))]^{-1}$. With [$T_v$](src/glossary.md#glossary-model-time) below the scalar time and $a_v>a_s$, its midpoint is [$w^*$](src/glossary.md#glossary-model-weight).

```math
w^*=\frac{\log(T_s/T_v)}
          {\log(T_s/T_v)+\log(a_v/a_s)}.
```

The crossover equates the gain in log time,
$(1-w)\log(T_s/T_v)$, with the cost in log error,
$w\log(a_v/a_s)$. The faster route wins below $w^*$ and the route
with the lower normalized error score wins above it. Treat weights
close to the crossover as sensitive to variation in timings or in
the sampled errors. The table applies the formula to the same targets and
shows how the choice moves when some lanes use scalar evaluation.
The last column uses the maximum alone for the accuracy score.

| Native Double32 kernel | Dense crossing | Mixed crossing | Dense crossing using only max |
| --- | --- | --- | --- |
| `log2` | 0.274 | 0.199 | 0.231 |
| `log1p` | 0.362 | 0.228 | 0.304 |
| `atan` | 0.306 | 0.225 | 0.232 |
| `tan` | 0.444 | 0.308 | 0.371 |
| `sinh` | 0.494 | 0.353 | 0.429 |
| `tanh` | 0.514 | 0.376 | 0.430 |

At an accuracy weight of 0.40, the model favors dense Double32
`tan`, `sinh`, and `tanh` batches. With the mixed inputs, it favors
scalar evaluation for all six.

#### Inputs to the Double32 crossover calculation

The 𝐏₉₉ and maximum columns use working-precision units. Each row
supplies the two times and four error statistics needed to recalculate
its crossover or apply different error targets.

| Function | Fixture | Scalar ns | Batch ns | Scalar 𝐏₉₉ / max | Batch 𝐏₉₉ / max |
|:---|:---|---:|---:|---:|---:|
| `log2` | dense | 6.285 | 4.359 | 0.10895 / 0.13138 | 0.28756 / 0.44284 |
| `log2` | mixed | 6.557 | 5.255 | 0.10895 / 0.13138 | 0.26534 / 0.44284 |
| `log1p` | dense | 5.352 | 2.068 | 0.10775 / 0.13045 | 0.57779 / 1.15148 |
| `log1p` | mixed | 5.760 | 3.567 | 0.10765 / 0.13045 | 0.54431 / 1.15148 |
| `atan` | dense | 9.995 | 5.727 | 0.10622 / 0.13107 | 0.28276 / 0.82566 |
| `atan` | mixed | 10.767 | 7.467 | 0.10621 / 0.13107 | 0.26224 / 0.82566 |
| `tan` | dense | 6.027 | 3.126 | 0.10693 / 0.13226 | 0.24336 / 0.40341 |
| `tan` | mixed | 6.750 | 4.768 | 0.10685 / 0.13226 | 0.23332 / 0.36369 |
| `sinh` | dense | 6.441 | 2.824 | 0.10812 / 0.13231 | 0.25168 / 0.39646 |
| `sinh` | mixed | 6.741 | 4.391 | 0.10812 / 0.13231 | 0.23743 / 0.36777 |
| `tanh` | dense | 8.574 | 3.170 | 0.10766 / 0.13877 | 0.27613 / 0.51788 |
| `tanh` | mixed | 9.026 | 5.304 | 0.10745 / 0.13877 | 0.25983 / 0.51788 |

For dense Double32 `tanh`, the speedup is `8.574 / 3.170 = 2.705`.
With 𝐏₉₉ and maximum targets of 1 and 2.2 units, the scalar score
is `max(0.10766, 0.13877 / 2.2) = 0.10766`. The batch score is
`max(0.27613, 0.51788 / 2.2) = 0.27613`. Their ratio is 2.565,
giving `log(2.705) / (log(2.705) + log(2.565)) ≈ 0.514`.
For the mixed inputs, the speedup is about 1.702 and the score
ratio is about 2.418, giving a crossover near 0.376. The speed
advantage shrinks more than the error penalty.

#### Comparing earlier Double64 scalar algorithms

The same model can compare two algorithm revisions. These
measurements use the same dense inputs as the scalar table above.
The accuracy targets are again 1 for 𝐏₉₉ and 2.2 for the maximum.

| Function | Scalar ns before → after | 𝐏₉₉ before → after | Maximum before → after | Crossover |
|:---|---:|---:|---:|---:|
| `exp` | 27.399 → 15.733 | 0.42317 → 0.43419 | 0.83129 → 0.93810 | 0.956 |
| `exp2` | 24.977 → 15.808 | 0.42163 → 0.44151 | 0.83711 → 1.00928 | 0.844 |
| `expm1` | 88.812 → 28.800 | 0.90061 → 1.07350 | 1.60294 → 1.57897 | 0.865 |

Under a hard 1.0-unit sampled ceiling, the earlier `exp2`
passes and the newer one exceeds the ceiling by about 0.009 units.
In that case the hard ceiling determines the choice before the
weight is applied. The crossover is an analysis of the measured
alternatives. The library selects its kernels using the input guards.

### How block coverage moves the crossover

If lanes are independent and each is eligible with probability [$p$](src/glossary.md#glossary-model-blocks),
a whole block of width [$m$](src/glossary.md#glossary-model-blocks) has eligibility probability [$b$](src/glossary.md#glossary-model-blocks) equal to $p^m$.
If each block needs one common regime, with disjoint regime
probabilities [$p_j$](src/glossary.md#glossary-model-blocks), then $b=\sum_j p_j^m$. Under that model,
a 50/50 mix of two Double64 logarithm regimes gives $2^{1-32}$
for a 32-element block. Grouping those inputs into homogeneous blocks
can restore the native path almost everywhere.

At a 1% miss rate, the model predicts 72.5% eligibility for
32-element blocks. The matched mixture admitted 740 of 1,024
such blocks, or 72.3%. With the same 328 replacements packed at
the end of that array, only 11 blocks would contain misses, leaving
1,013 of 1,024 blocks eligible. The arrangement can therefore
change native coverage from 72.3% to 98.9% at the same miss count.
This is a block count, so the clustered speedup still needs to be
measured. Sparse repair allows [$K$](src/glossary.md#glossary-model-blocks) rejected lanes
when [$K\le\lfloor m/8\rfloor$](src/glossary.md#glossary-model-blocks).
Every rejected lane must also pass the repair safety check.
Double64 `exp2` and `tan` admitted all 512 blocks of width 64
in their mixed fixtures, with 245 using repair. Their speedups
were 2.86× and 2.43×. In a separate Double32 experiment,
scattering sparse low words while keeping the heads in range
left the native kernels eligible. The source of a guard failure
therefore matters alongside its frequency.
[Batch benchmark fixtures](src/technicalguide.md#batch-benchmarks)

For a rough prediction, let [$N$](src/glossary.md#glossary-model-costs) and [$S$](src/glossary.md#glossary-model-costs) be the fully eligible
batch and fallback times per element. Let [$H$](src/glossary.md#glossary-model-costs) cover extra mixed
execution overhead. If $N<S$, the condition for a speedup of
at least $\sigma$ is approximately

```math
\begin{aligned}
T_v &\approx bN+(1-b)S+H, \\
b &\ge \frac{S(1-1/\sigma)+H}{S-N}.
\end{aligned}
```

With $S=8.574$ ns and $N=3.170$ ns for Double32 `tanh`, setting
$H=0$ requires about 79.3% eligible blocks for 2×. Under independence
at width 32, that allows about 0.72% missed lanes. The actual mixed
run reached 1.70×. Expensive outliers and repair can change the
per-block cost, so measure them separately when they are common.

The error distribution also changes with coverage. If [$\pi$](src/glossary.md#glossary-model-distributions) is the
fraction of actual lanes that took native arithmetic and [$F_n$](src/glossary.md#glossary-model-distributions) and
[$F_s$](src/glossary.md#glossary-model-distributions) are the conditional error distributions for native and scalar
evaluation, then [$F_E(e)$](src/glossary.md#glossary-model-distributions) gives the fraction meeting an error threshold $e$.

```math
F_E(e) = \pi F_n(e) + (1-\pi)F_s(e).
```

The formula combines the two fractions at the same threshold.
In the mixed Double32 `log1p` fixture, 𝐏₉₉ improved from 0.578 to 0.544
and the maximum stayed at 1.151, while the speedup fell from 2.59× to
1.61×. The accuracy and speed measurements can therefore pull in
opposite directions as coverage changes.

Finally, the batch driver checks axes and overlap before selecting
a route. Views, overlapping inputs, and dense ranges shorter than
64 use scalar evaluation. Threading introduces separate size and
exception-order constraints. These choices can move a workload past
a crossover even when the numerical input range stays fixed.
[Vector API](src/userguide.md#elementwise-operations-on-vectors)

## Reproducing the comparison

Reset `MersenneTwister(0xf01c)` for each row and draw two vectors
of 32,768 Float64 uniforms with `rand(rng, n)`. For head interval
`(a, b)` and underlying type `F`, pair the uniforms `(u, v)` to
form `h = F(a + (b - a)*u)` and `D(h, F(v - 0.5)*eps(h))`.
Draw independent input vectors in argument order, with the real
part preceding the imaginary part in complex fixtures. For a mixed
run, use positions `randperm(rng, n)[1:328]` after sampling the dense
fixture and replace them with the heads above. Warm both entry points
and alternate execution order when timing. Use the same inputs with
the earlier revision for a before/after comparison.

This example recreates the dense and mixed Double32 `tanh` fixtures,
times the two public evaluation routes, and computes the crossover.
It reports a crossover only when the measured batch is
faster and the scalar method has the lower error score. On the
original run the dense maxima were 0.139 and 0.518 report units.
Timings and the resulting crossover can vary with the machine and
compiler.

```julia
using DoubleFloats, Random, Statistics

@noinline function scalar!(f::F, dest, x) where {F}
    @inbounds for i in eachindex(x)
        dest[i] = f(x[i])
    end
    return dest
end

@noinline function ns_per_element(apply::A, f::F, dest, x) where {A,F}
    start = time_ns()
    for _ in 1:8
        apply(f, dest, x)
    end
    return (time_ns() - start) / (8 * length(x))
end

function compare(f, x)
    scalar = scalar!(f, similar(x), x)
    batch = DoubleFloats.simdmap!(f, similar(x), x)
    scalar_times, batch_times = Float64[], Float64[]
    for i in 1:9
        if isodd(i)
            push!(scalar_times, ns_per_element(scalar!, f, scalar, x))
            push!(batch_times, ns_per_element(DoubleFloats.simdmap!, f, batch, x))
        else
            push!(batch_times, ns_per_element(DoubleFloats.simdmap!, f, batch, x))
            push!(scalar_times, ns_per_element(scalar!, f, scalar, x))
        end
    end
    times = (scalar=median(scalar_times), batch=median(batch_times))
    errors = setprecision(BigFloat, 512) do
        ref = f.(BigFloat.(x))
        map((scalar, batch)) do outputs
            e = [Float64(abs(BigFloat(y)-r) / (abs(r)*eps(Double32)))
                 for (y, r) in zip(outputs, ref)]
            (percentile_99=quantile(e, 0.99), worst=maximum(e))
        end
    end
    a_s, a_v = map(e -> max(e.percentile_99, e.worst / 2.2), errors)
    s, r = times.scalar / times.batch, a_v / a_s
    crossover = s > 1 && r > 1 ? log(s) / (log(s) + log(r)) : nothing
    return (; times, errors, speedup=s, crossover)
end

n = 32_768
rng = MersenneTwister(0xf01c)
a, b, replacement = 0.025, 0.95, 1.05
x = map(rand(rng, n), rand(rng, n)) do u, v
    h = Float32(a + (b - a) * u)
    Double32(h, Float32(v - 0.5) * eps(h))
end
println("dense  ", compare(tanh, x))
x[randperm(rng, n)[1:328]] .= Double32(replacement)
println("mixed  ", compare(tanh, x))
```

The [benchmark driver](../benchmark/studies/bench_simd_elementary.jl) supports
varying input mixtures, storage, sizes, and threading. Keep input
cohorts comparable. The local Double32 `tan` call took about 6 ns
here. The broad benchmark report measured about 116 ns on a
different distribution that exercises phase reduction and fallback.
[Benchmark Report](reports/benchmark_report.md#elementary-functions-1)
