# Next SIMD paths for vector elementary functions

Extend the qualified `DoubleFloats.simdmap!` entry point for dense
`Double64` vectors. Start by widening `exp`, `exp10`, and the ordinary
`expm1` path. Then add `hypot`, its two-result consumer
`DoubleFloats.normalize`, and reciprocal. Extend the shared circular
reduction in a separate step. Binary `atan` and its use in complex `log`
need their own numerical admission tests.

The [User Guide](src/userguide.md) documents the public contract. The
[Technical Guide](src/technicalguide.md) records the implemented ranges
and the existing benchmark procedure. The [original SIMD plan](simdupdate.md)
describes the initial rollout.

## Implementation record

- The converted exponentials use absolute head bounds of 0.001–700
  for `exp` and 0.001–300 for `exp10`. Ordinary `expm1` uses
  0.5–700, and both signs of the four-doubling binade use the fixed
  count. The public-path benchmarks are in the Technical Guide.
- `hypot` and paired `normalize` accept both signs on the bounded
  0.25–8 magnitude interval, with a dedicated route for positive
  pairs. Reciprocal covers both signs from `2^-256` through `2^256`.
- Wider `sin`, `cos`, `sincos`, `tan`, and `cis` reuse
  the scalar circular reduction. The driver tries existing
  small-angle kernels first. The `tan` guard keeps a 0.11-radian
  band around each pole on the scalar route, and the wider `cis`
  range starts above the direct Taylor cutoff.
- The first positive-rectangle phase prototype used
  `_batch_atan(_batch_div(y, x))` for the binary result. On Julia
  1.10.10, with 65,536 pairs from the rectangle in section 4
  and seed `0x521`, every high limb matched. Both limbs matched in
  12,042 cases. Binary `atan`, `atanxy`, and complex `log` use the
  existing scalar algorithms inside the batch.

## Evidence and order of work

The following prototypes ran at revision `9b4a13cf` on Julia 1.13.3 with
one Julia thread, native CPU targeting, and an Intel Core i9-14900K.
They compare the current preallocated `simdmap!` with checked internal
block loops on 65,536 elements. Both limbs agreed on those samples.
The candidate timings include classification and any block fallback.
Measure the completed public path before adopting any of the gains.

| Operation | Sampled heads | Current → prototype | Speedup |
| --- | --- | ---: | ---: |
| `exp` | Uniform on −100 to 100 | 2,022 → 613 µs | 3.3× |
| `exp10` | Uniform on −100 to 100 | 2,020 → 619 µs | 3.3× |
| `expm1` | Uniform on −100 to 100 | 2,562 → 1,045 µs | 2.5× |
| `hypot` | Independent pairs on 0.25–8 | 1,181 → 248 µs | 4.8× |
| `inv` | Uniform on 0.25–8 | 261 → 110 µs | 2.4× |
| `sqrt` | Uniform on 0.25–8 | 115 → 82 µs | 1.4× |

To reproduce the samples, start a `MersenneTwister(0x521)` and generate
4,096-element fixtures before the 65,536-element fixtures. At each size,
generate the wide vector on −100 to 100, then the two vectors on 0.25–8.
For each vector, draw its uniform heads first and draw one
additional uniform sample per head for `lo = (u - 0.5) * eps(hi)`.
Reuse the wide vector for all three exponentials and the first positive
vector for `inv` and `sqrt`. Warm both methods and alternate timings for
15 repetitions on preallocated outputs.

1. Widen the exponentials as one change with separate results per function.
2. Add `hypot` and then add `normalize` once its full tuple-output path
   pays off. Reciprocal can land independently.
3. Extend `sincos` sector by sector, then use the proven reduction in
   `sin`, `cos`, and `tan`. Measure each public function independently.
4. Investigate binary `atan`, its reversed-argument alias
   `DoubleFloats.atanxy`, and complex `log` behind separate acceptance tests.

Standalone `sqrt` is a lower priority given the measured gain. Its
existing bounded primitive already serves the proposed compositions.

## Dispatch and numerical contract

- Register each new route by function identity, operand types, and natural
  result type. Use `Vector{Double64}` for real results,
  `Vector{Tuple{Double64,Double64}}` for paired results, and
  `Vector{ComplexDF64}` for complex results. Keep computation in the
  owning arithmetic or elementary source file. Reuse the dispatch,
  aliasing, and scheduling in [simd.jl](../src/math/elementary/simd.jl).
- Preserve equal axes before writes, source-at-entry semantics for
  overlapping inputs, scalar assignment conversions, and ordered serial
  failures. Keep custom callbacks, views, narrower destinations, and
  unsupported precisions on their existing paths. Use the native loop
  only with an exact destination element type and eligible disjoint
  operands. Thread newly admitted operations only with explicit
  `threaded=true` and a measured crossover. Add specific allowlist
  entries for `inv`, `hypot`, or `DoubleFloats.normalize` if justified.
  The two binary methods take same-precision operands. For `normalize`,
  the natural output is one tuple per input pair.
- Use the scalar result as the batch contract. For a finite result,
  compare both stored limbs, including zero signs. Compare tuple and
  complex components separately. For special values compare each limb's
  classification and observable signs. Check the natural result type
  before any assignment conversion. Keep existing scalar branch choices
  and operation order. Avoid `@fastmath` and reassociation.
- Prove both-limb bounds before using unchecked arithmetic.
  `_batch_bounded` checks a head interval and a low-magnitude bound.
  Verify any stronger requirement separately, such as the direction of
  a tie at a binade edge or the rounding of a conversion. A raw pair
  rejected by the classifier still goes through the original scalar
  method.
- Retain 32-element whole-block fallback as the starting point. The
  current 64-element sparse repair supports one unary `Double64`
  regime with a scalar placeholder. For new mixtures, compare
  whole-block fallback, ordered runs, and masked repair before extending
  dispatch. Use masked repair only when every excluded scalar call and
  store are safe, the placeholder is valid for all nested operations,
  and classification completes before any block writes. At a possible
  throw, execute the corresponding scalar calls and stores in index
  order. Preserve the existing 64-element minimum call size until the
  new crossover is measured.

## 1. Widen the converted exponentials

Implement in [explog.jl](../src/math/elementary/explog.jl). Keep the
existing `_batch_exp`, `_batch_exp10`, and `_batch_expm1_ordinary`
arithmetic. Widen the respective eligibility predicates first. The
existing `exp2` window provides a reference for the ordinary scaling
path.

- Start with `0.001 <= abs(hi) <= 128` for `exp` and `exp10`. Use
  `0.5 <= abs(hi) <= 128` for the ordinary `expm1` route and retain
  its fixed-binade kernel. The sample included the region around zero.
  Lanes below these minima use an existing eligible regime or the scalar
  method.
- Check that all products in `_mf_mul3` are finite and that the
  converted exponent stays inside the ordinary path. Under the starting
  bound, the largest base-2 magnitude is below 426, including the low
  limb and conversion error. The rounded integer reduction and both
  reconstruction scale factors stay safely within their finite ranges.
  Preserve all three converted limbs and the order in `_mf_mul3`,
  `_exp2_ordinary`, and the final subtraction for `expm1`.
- After the first benchmarks, evaluate separate wider bounds, such as
  `abs(hi) <= 700` for `exp` and `abs(hi) <= 300` for `exp10`.
  Bound the converted head used by `_exp2_clamped`
  and the contribution of both tails, including rounding and scaling
  headroom on each side. Prefer a proven input envelope that avoids
  converting every lane solely for screening. Keep exact zero, unusual
  pairs, nonfinites, the overflow clamp, subnormal lattice rounding,
  the underflow cutoff, and MPFR midpoint refinement in the scalar path.
  Leave `Double32` promotion and low-band dispatch as implemented.
- For small `expm1`, retain the scalar head-based binade and branch
  at `abs(hi) == 0.5`. Add fixed-binade variants only on workloads
  that justify them. Use the same coefficients, scaling, Horner steps,
  and `max(0, exponent(hi) + 9)` reconstruction count as the scalar
  path. Measure code size, first call, and mixed-binade throughput
  before adding another variant.

## 2. Add `hypot`, `normalize`, and `inv`

Put the first two kernels in
[normalize_hypot.jl](../src/math/arithmetic/normalize_hypot.jl).
Keep reciprocal next to its scalar wrapper in
[op_db_db.jl](../src/math/ops/op_db_db.jl), using the transforms in
[op_dd_dd.jl](../src/math/ops/op_dd_dd.jl). Register the native
operations through `_batch_kernel` and use the existing bounded
arithmetic helpers.

### `hypot` and paired normalization

1. Begin with both heads in `[0.25, 8]` and bounded low limbs. Form
   the absolute values and choose the smaller and larger operands with
   the scalar `minmax` order. The proved range allows an inlined
   two-limb comparison. Preserve scalar ordering on ties, including
   equal heads and signed-zero low limbs. Include deterministic tie
   fixtures alongside the randomized positive pairs.
2. Compute `r = small / large`, `r = r * r`, then
   `large * sqrt(one(Double64) + r)`. Use the same double-word
   division, multiplication, addition and positive square root.
   The scalar uses multiplication for `r * r` and a double-word
   addition of one. In the initial box, the divisor, square-root
   argument, and final result are positive and have exponent headroom.
3. Register the exact function object `DoubleFloats.normalize` and
   a tuple result. Reuse the bounded hypot once, then divide the
   original `x` and `y` by that result in input order. Preserve
   the two scalar divisions. Extend to signed inputs only after
   matching scalar `abs` and ordering, including low-word zero signs.
4. Test paired zeros, one zero, mixed magnitudes, underflow and
   overflow, and the infinity/NaN combinations. Retain the scalar
   special-value precedence and the `normalize` branch that divides
   through `x + y` when the hypotenuse is zero or nonfinite. Start
   with binary whole-block fallback. Use a pair of safe operands if
   introducing binary masked repair after measurement.

### `inv`

Start with the sampled positive range and reuse `unsafe_inv_dd_dd_`.
The scalar wrapper already takes this route when its initial reciprocal,
input limbs, and resulting head are finite. Show that those checks
succeed throughout the admitted interval before omitting them. The
low-limb correction still applies when the input low limb is zero.

Test `±0`, infinities, NaNs in either limb, raw pairs, and boundaries
where the reciprocal becomes subnormal or overflows. Add finite negative
ranges and additional binades in steps. Prove that the reciprocal and
every correction remain in the regime of the existing transforms, even
with the extreme allowed low limb. Use identical scalar handling for
singular, tiny, extreme, and unusual inputs.

## 3. Extend circular reduction

Implement in [trig.jl](../src/math/elementary/trig.jl) with the existing
[table constants](../src/math/elementary/sequences.jl) and
[three-limb π reductions](../src/doubletriple/triple_pi.jl).
Start where the current scalar `Double64` method already uses its own
range reduction, `abs(hi) < 6.28125`. Inputs in the existing small-angle
band should retain their checked kernel and throughput.

1. Start with absolute heads on `[0.125, 0.18]` in quadrant `q == 0`.
   This is beyond the Taylor-only branch and lies inside the sector
   between the π/32 and π/16 anchors. Verify the interval against the
   stored anchors and the full two-limb comparison in `index_npio32`.
   Use the scalar residual subtraction, Taylor pair, and
   `sincos_circle` reconstruction in the same rounding order.
   Preserve the scalar Taylor return for a zero-headed residual or
   send that lane to scalar evaluation. Validate adjacent table sectors
   with both low-limb signs before supporting arbitrary sector indices.
2. For varying sectors, try a bounded index estimate followed by
   full-limb verification against both table edges. Match the scalar
   equality convention that an exact anchor belongs to the sector
   starting at that anchor. Prove that every index is valid before
   table access and that the computed remainder stays inside the
   chosen Taylor window with rounding headroom. Measure the cost of
   gathers, sector-specific runs, and mixed-block fallback.
3. Add the other quadrant reductions using the scalar head expression
   for `q`, including its multiply, add, and truncation order. Reuse
   the corresponding `x_minus_*` transform with the same three limbs.
   Keep the direct Taylor decision on the *reduced* head and the
   scalar reconstruction of signs and component swaps. Route ambiguous
   cutoff lanes and inputs near roots through the scalar method until
   tested and proved. Start with one or two regimes at a time. Compare
   deriving inexpensive conservative bounds during classification with
   a staged reduction when the same arithmetic would otherwise be
   repeated. Include staging and repacking in the timing.
4. Share the wide pair internally, with separate adapters for each
   scalar API. `sin` uses signed input in its direct Taylor branch,
   while `sincos` reflects the input first and restores the sine
   sign. Preserve the sign of a zero low limb under double-word
   negation. `cos` uses the absolute input. Admit `cis` only after
   matching `cos(x) + im*sin(x)` and its assignment behavior. The
   scalar NaN result is real. Keep that lane in the scalar loop.
5. For `tan`, prove before unchecked division that the reconstructed
   `abs(HI(c))` is on the scalar quotient side of the `0.1` cutoff
   and that the quotient is bounded. Initially exclude a guard band
   around the pole region. If using the actual reduced cosine for
   eligibility, compute it with the scalar rounding order and check
   it before evaluating the quotient. Keep `cot` in its current
   bounded route until its separate
   `mod1pi` near-root test is covered.

Scattered sectors can make homogeneous blocks rare. Include inputs that
walk across the circle and inputs shuffled over it. A throughput gain on
one sector is evidence for that sector only. Full-range reduction beyond
the scalar `6.28125` cutoff and the pi-scaled functions require separate
numerical work.

## 4. Binary `atan` and complex phase

In [arctrig.jl](../src/math/elementary/arctrig.jl), start with
positive `x` heads on `[1, 4]` and positive `y` heads on
`[0.04, 0.18]`. For bounded low limbs the computed `y/x` has room
inside the current small unary `atan` window. Measure both the cost of
the ratio and the agreement of the existing polynomial with the
binary scalar result before proceeding to other quadrants.

For wider finite pairs, form the ratio of the smaller magnitude to the
larger and prove any scaling and division safe. When `abs(y) > abs(x)`,
subtract the acute angle from π/2. For negative `x`, subtract the
result from π, then apply the sign selected by the scalar convention
for `y`. Use split angle constants and check both reconstructions near
their transitions. Keep axes, signed zeros, infinities, NaNs, and extreme
ratios in the scalar route during this work. Verify
`DoubleFloats.atanxy(x,y)` against `atan(y,x)`.

The [current conversion](../src/type/quadmath.jl) rounds the split
input to `Float128` before binary `atan` and converts the result
back. Even nominally normalized limb pairs can span more than 113 bit
positions. Signed-zero behavior can depend on the conversion as well.
Establish agreement with the current scalar implementation as a separate
check from the mathematical error bound. Verify input rounding and both
result limbs for the admitted lane class. Keep uncertain lanes on the
current scalar or threaded path. A replacement scalar algorithm with a
revised numerical contract is a separate change and needs independent
validation.

After an eligible phase path exists, prototype
[complex `log`](../src/math/elementary/complex.jl) on rectangles where
both real squares, their sum, the real logarithm, and the phase are
bounded. Use `log(square(re) + square(im)) * 0.5` and `atan(im,re)`
in scalar order. Check whether the *sum of squares* reaches the direct
or table logarithm regime. Keep the original results for zeros,
nonfinites, and either side of the negative real axis. Benchmark
one-pass composition against the existing complex method. A separate
magnitude pass is worthwhile only if the finished results show a gain
after phase evaluation, temporaries, and repacking.

## Correctness checks and benchmark admission

Extend [test/simd_elementary.jl](../test/simd_elementary.jl) and reuse
[the exponential boundary fixtures](../test/explog_boundaries.jl).
A scalar loop with the same assignment is the reference for the API.
Also test the candidate on fixtures known to reach its native, mixed,
and rejected branches.

- Check each new cutoff just inside, at, and just outside, with both
  signs of the low limb. For exp conversion and scaling include
  half-integer reduction boundaries, inputs near the normal/subnormal
  and overflow thresholds, underflow midpoints, and values returning
  exact zero or one. For magnitude and reciprocal include equal
  heads, low-limb ties, signed zeros, and extreme ratios. For trig
  include each admitted table anchor, quadrant transitions, the
  Taylor cutoff, and both sides of roots and poles. For phase
  include axes, opposite quadrants, nearly equal magnitudes, and
  branch-cut inputs with opposite signs of a tiny imaginary part.
- Use MPFR or high-precision `BigFloat` references at sensitive
  points. Construct references from the limbs at sufficient
  precision before evaluating the function. Compare scalar and batch
  independently so shared arithmetic regressions are visible.
  Use an absolute error measure at roots and compare subnormal
  exponential results on the underlying float's rounding grid.
  For binary phase distinguish accuracy for the unevaluated sum
  from agreement after the scalar's `Float128` conversion.
- Exercise exact block lengths, short vectors, and tails. Check
  ownership and conversion with exact aliasing, shifted overlaps,
  only one aliased binary operand, strided and custom vectors,
  mismatched axes, and narrow or tuple destinations. Include an
  otherwise eligible mixed block with a throwing lane and verify the
  destination prefix and untouched suffix. Check one-thread and
  multithreaded execution, including a worker-thread caller.
- Run the full suite on Julia 1.10 and a current supported version.
  Inspect LLVM on the target builds for vector arithmetic across
  independent elements. Check that representative scalar callers
  retain inference, allocations, throughput, and numerical results
  after any helper extraction.

Extend [the existing benchmark driver](../perf/bench_simd_elementary.jl)
with the new fixtures. Save measurements of the current public batch
path before changing it. Compare those with preallocated scalar
broadcast, an ordered scalar loop, the new public path, and its
explicit threaded variant. Use otherwise identical inputs and storage.
The driver's `--baseline` mode measures scalar comparisons, so also
run it in normal mode against the pre-change package for the existing
public batch baseline. Keep construction and correctness checks
outside timed loops.

```sh
SIMD_RANGE=general SIMD_SIZE=4096,65536 SIMD_FILTER='^(exp|exp10|expm1)$' \
    julia --project -t1 perf/bench_simd_elementary.jl
```

Update the injected outlier fixtures when a range expands. For example,
heads from 40 to 100 become eligible for the widened exponentials.
Count actual eligibility using the candidate predicates outside the
timed loop, separately from the nominal injection fraction.

| Measure | Fixture design |
| --- | --- |
| Size and layout | Empty and singleton, sizes around 32 and 64, sizes around each measured thread crossover, 4,096, 65,536, and a size beyond cache. Include tuple output, strided storage, conversion, and alias copies. |
| Input mixtures | Use about 0%, 1%, 10%, 50%, and 100% rejected lanes. Record the actual rejected fraction and regime counts. Compare clustered and shuffled rejections and mixtures of individually supported regimes. Include wide exponentials, tied and uneven magnitude pairs, sector walks, and all quadrants. Report poles and MPFR cases separately. |
| Throughput and latency | Record repeated interleaved medians and spread, one thread and representative worker counts including four, first-call latency in fresh processes, bytes and allocations, Julia version, target, CPU, seed, representation, and revision. Inspect native and a second target where available. |

Admit each regime only when the full call improves the intended
workload beyond run-to-run variation and the warmed disjoint dense
serial path makes zero heap allocations. Report regressions on
fully rejected or small workloads separately. Keep a scalar threshold,
narrow the regime, or defer it when dispatch, repair, or first-call
cost outweighs the gain. After each admitted stage, update the User
and Technical Guides with the accepted ranges and measured results.
