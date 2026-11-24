# Speed up Double64 elementary functions

## Scope and acceptance

Improve the scalar paths for `atan`, `tan`, `sinh`, `cosh`, `tanh`,
`exp`, `exp2`, `expm1`, `log`, `log2`, and `log1p`. Measure the
same Float64 input heads in warmed loops for the D64/F64 comparison.
Use the Accuracy Report's relative unit of `2^-104` for ordinary nonzero
results. Use 2.2 units as a screening ceiling for the new paths, with
tighter budgets where they cost little. Treat subnormal and
grid-limited results separately. A sampled maximum and a bound over
all representable inputs are different deliverables.

## Implementation

1. Use a 17-point dyadic table for `atan`. Reduce with the tangent
   subtraction identity and evaluate the small odd series with a tapered
   Horner scheme. Retain reciprocal reduction and signed special values.
2. Evaluate `sinh` and `cosh` directly for magnitudes through one. Use
   the shared continued-fraction rational correction for `tanh`
   through one and `tan` through one-half, with opposite signs of the
   squared argument. Check quotients and both sides of the switches.
   Protect `tan` near poles and in its general fallback by checking
   whether conversion to Float128 preserved the original input.
3. Use a 128-entry power-of-two table for `exp` and `exp2` in the
   ordinary Double64 range. Reduce `exp` directly with split
   `ln(2)/128` and use a shorter polynomial on the reduced interval.
   Use the corresponding base-2 coefficients for `exp2`. Preserve
   lattice rounding and special-value handling near the exponent limits.
   Extend the existing offset reconstruction for `expm1` closer to
   zero and check tiny inputs before any halving or base conversion.
4. Compute `log` and `log2` through an enlarged mantissa table.
   Normalize the small numerator before forming the reduced quotient.
   Store the anchor in the requested logarithmic base and preserve
   exponent handling. Use a compensated quotient near one and share
   that small-argument evaluator with `log1p`. Preserve the exact
   numerator near zero, including the subnormal lattice.

## Review and refinements

The 256-entry exponential variant improves throughput further but uses
more space and leaves less measured accuracy margin. Start with 128
entries and preserve the existing endpoint algorithms. Near one, use the
extra quotient correction. The cheaper version exceeded 2.2 units in
the scratch sweep. A larger log table by itself also exceeded the
budget when the numerator was left unnormalized.

Check each batch entry point and its consumers, including complex
functions and powers. Use the same scalar arithmetic for matching
normalized inputs. Keep the existing batch dispatch and threshold
policy, and measure vector costs separately from scalar costs.
Where a narrow block is eligible, specialize its reduction so the
compiler can see the loop invariant bounds. Test scalar and batched
values component by component, including a mixture of regimes.
The scalar tangent's pole behavior requires its own check even
though the central rational approximation stays far from poles.

Regenerate the accuracy and timing reports. Run deterministic boundary
checks with nonzero low components, the existing scalar and batch
tests, and independent high-precision sweeps. Review the special-value
and underflow results before publishing benchmark claims. Update the
User Guide and Technical Guide, add a subsection that explains the
reduction choices and their error budgets, rebuild HTML and PDF, and
verify the rendered navigation.

## Implementation and verification

The first integrated sweep exposed two issues that the prototypes
did not cover. Forming `1+x` just outside the old `log1p` interval lost
enough information to exceed the screening threshold. Widening the
direct path worked after retaining the low components of two more
coefficients on the outer part of the interval. Near the circular
tangent's zeros, the small reduced sine also needs the wide route.
The wide route checks conversion to Float128 and uses a private
MPFR value when conversion loses information.

The first batch versions of `atan` and the near-one logarithms were
slower. The final variants use the checked raw arithmetic inside the
loop and make the chosen logarithmic regime explicit. A head of one
with a positive low component requires reciprocal reduction for
`atan`, so its unit-interval batch guard ends just below one.

The deterministic tests cover 6,269 fast-path comparisons, including
reduction boundaries, tangent fallbacks, signed zero, and the
subnormal spacing. The existing and expanded batch tests cover
1,259 comparisons and behavioral checks. The full suite passed on
Julia 1.10.10 and 1.13.3. Targeted warmed loops and the regenerated
reports supply the measurements in the Technical Guide.
