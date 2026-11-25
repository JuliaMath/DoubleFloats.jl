# Double32 elementary acceleration plan

## Scalar evaluation

Use the corresponding Base Float64 function for ordinary, bounded
Double32 inputs to exp, exp2, expm1, log, log2, log1p, atan, tan, sinh,
cosh, and tanh. Use the same public dispatch as before. Keep the
existing Double64 forwarding and the dedicated Float32 exponential
reconstruction as the fallbacks.

Check the head range and bound the low word to half the head's binade
spacing. For the resulting close operands, subtraction of the head
from the Float64 sum is exact by Sterbenz's lemma. Require that this
difference recover the original low word before evaluating the
function. Split the Float64 result at its Float32 head and store the
rounded residual as the second word. Run the guard before conversion
of the result, with bounds that keep the result and its split in the
ordinary range. Use the old paths for nonfinite and exceptional inputs,
logarithms near one, and exponential format boundaries. Return an
exact zero argument directly for the odd functions and log1p so
narrowing through Double64 cannot lose its sign.

## Batch evaluation

Start with tan, tanh, sinh, atan, and log2. They had the best combination
of sampled accuracy and improvement over the widened loop. Use
existing compensated Float32 primitives and reuse the log2 table.
Use a shorter continued fraction for the tangent pair, a tapered odd
series for sinh, and the same dyadic reduction as Double64 for atan
with a shorter correction. Retain exact outputs of log2 on powers of
two. Allow sparse low words in these kernels since they are used
directly. Use the shared driver and whole-block fallback to retain
index-ordered exceptions and alias handling. Force inlining of the
per-element arithmetic and verify that LLVM actually widens the loop.

The initial Float32 log1p experiment approached the 2.2-unit accuracy
limit. Evaluate a natural logarithm series using the compensated
quotient x/(2 + x) from the Double64 kernel with Float32 coefficients
and a taper sized for the narrower interval. Use it in production
only if it restores margin and improves throughput. Use the guarded
scalar method for expm1 since the initial native implementation was
slower and exceeded 2.2 units. Use the guarded scalar method in other
batch calls as well. For exp2 it also retained more accuracy than the
native prototype in ordinary inputs.

## Review and acceptance

The input conversion must preserve the low word before evaluation.
Testing only converted Float32 heads would miss the failure at
Double32(1, 2^-60). Range checks include the effects of either sign
of the low word, and the split never sees overflow in the admitted
scalar ranges. Preserve the existing exceptional paths as well as
their method precedence. Native kernels may round differently from
the scalar method, so verify them against the exact pair evaluated
in 512-bit BigFloat, with a 2.2-unit target and explicit checks for
signed zeros, exact powers, and format limits.

Probe head guard endpoints, neighboring Float32 heads, varied low
words, table and reduction switches, and scattered rejected lanes.
Exercise disjoint vectors, overlaps, lengths around 64, threaded
calls, and mutation through a domain error. Measure warmed scalar
and full preallocated batch calls against the preceding revision on
the same data. Record the ranges, observed errors, and results in
the manual and regenerate the affected documentation.

## Validation results

The compensated log1p kernel met the batch criteria. The wider
65,536-point stress samples included sparse low words and logarithmically
spaced magnitudes. The largest observed native-kernel error was 1.255
report units for log1p. LLVM emitted eight-lane Float32 arithmetic for
all six kernels on the tested native target.
