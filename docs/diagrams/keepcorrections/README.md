# Keep small corrections from input to output

A small correction can determine the answer even when it lies below
the spacing of the base float. This guide turns the first transformation
in [DoubleFloats at its best](../../apotheosis.md) into a design for a
standalone Julia package and a design that uses existing DoubleFloats
functions wherever their behavior meets the calculation's requirements.
Both designs cover the value's path from input to output, including
where to look when a correction disappears.

## Read the diagrams

Each link opens a Mermaid source file. To view a diagram as a graphic,
open the file in a Mermaid-capable editor or render it with Mermaid CLI.

```sh
mmdc -i 01-overview.mmd -o /tmp/keepcorrections-overview.svg
```

| Diagram | Question it answers |
| --- | --- |
| [01 · Overview](01-overview.mmd) | What must survive from source through evaluation and export? |
| [02 · Inputs](02-inputs.mmd) | How do we preserve the difference between a decimal, an already-rounded binary value, and a pair? |
| [03 · Standalone package](03-standalone.mmd) | Which responsibilities belong to a new type, its arithmetic, and its higher-level operations? |
| [04 · Arithmetic](04-arithmetic.mmd) | Where do the residual terms go in addition, multiplication, division, square root, and reductions? |
| [05 · Keep small quantities explicit](05-keep-small-quantities-explicit.mmd) | When does reformulating the calculation save more information than widening it? |
| [06 · DoubleFloats adapter](06-doublefloats-adapter.mmd) | When does reusing an existing public method help, and when does another route take over? |
| [07 · Conversion and output](07-conversion-and-output.mmd) | How do we narrow deliberately or export both words losslessly? |
| [08 · Vectors and matrices](08-vectors-and-matrices.mmd) | How do corrections survive array construction, batch dispatch, and structured operations? |
| [09 · Validation](09-validation.mmd) | What establishes correctness, and when is a faster route worth using? |
| [10 · Worked paths](10-worked-paths.mmd) | Where does the correction disappear in a scalar formula, a conversion, and a linear system? |

For a standalone implementation, read 01–05, then 07–10. For a project
using DoubleFloats, read 01–02 and 05–10. Diagram 04 is also useful
when diagnosing an existing calculation.

## The value and its contract

A finite pair denotes the mathematical sum of its high and low words.
Taking that sum in the component format can round away the low word.
The low word usually describes a correction to the high word, but it
can be much smaller than half the spacing at the high word. Exact
conversion therefore depends on the exponent gap as well as the
number of bits in the destination. Two words also share the range
constraints of their component format, including the subnormal grid.

Decide whether the caller needs a pair, a correctly rounded ordinary
float, an exact conversion, or an approximate result within a stated
tolerance. State the treatment of zeros, infinities, NaNs, and domain
errors. Carry the exact source or an enclosing interval when a retry
must recover information the first attempted representation cannot
hold. Binary inputs already rounded upstream can be preserved exactly
as binary values.

## Build a standalone package

Implement intake and output first and use them as the reference
boundaries for arithmetic. Parse decimal input as a rational or
enclose it with directed rounding. Decode floating-point words as
dyadic rationals when an exact value is required. Use a normalized
two-word representation on the ordinary path. Specify the compression
rule, including ties, carry into the high word, and overflow and
subnormal behavior. Diagram 07 uses a leading nearest-even rounding,
a rounded residual, and renormalization as the proposed rule. This
defines a two-word compression procedure. For an enclosure-based
implementation, require that the leading word and residual rounding
are both determined, or directly establish the stated tolerance for
the returned pair.

Build arithmetic on error-free transformations such as TwoSum and
the fused multiply-add product residual. Give each transformation its
rounding and range preconditions. An exact product residual can be
lost to underflow. A rounded high product can also overflow before
the low terms have been accounted for. Use exact rescaling where it
preserves the operands, and route other cases to a wider or exact
implementation. Include cancellation, evaluation error, and discarded
terms when bounding the final result. Preserve separately supplied
offsets with formulas such as `log1p(delta)`. For two-word output,
return the normalized result. For a base-float output, round the
computed value to the requested precision, using the retained inputs
to resolve cases where an intermediate pair alone cannot settle the
destination rounding.

For binary operations and conversions, an exact dyadic or rational
reference can settle boundary cases. For transcendental functions, a
wider value can serve as test evidence. A guarantee requires a justified
error bound or enclosure and a check against the destination rounding
or tolerance. Set a retry limit and expose unresolved cases under the
chosen API. Validate each component type and complex branch separately.
Add vector and structured-matrix dispatch after the scalar and
conversion semantics can be tested independently.

## Reuse DoubleFloats selectively

| Use case | Reuse when it fits | Boundary to check |
| --- | --- | --- |
| Construct an intended decimal | `df64"0.2"` and the corresponding `df32` or `df16` string constructors | They use a finite-precision `BigFloat` parse. Use exact digits or an enclosure for a requirement stronger than the parse can establish. [String input](../../../src/type/parse.jl) |
| Construct or extract a pair | `DoubleFloat(hi, lo)` normalizes same-type floating words. `HILO(x)` exposes both. | The raw two-word parametric constructor stores the words as supplied. Validate an external pair before using a route that assumes normalization. [Pair type](../../../src/Double.jl) |
| Capture residuals of arithmetic on base floats | `add2`, `sub2`, and `mul2` operate on matching component types and return a pair. | Validate range limits and special values for the workload. Keep the pair or accumulate its correction. [Arithmetic](../../../src/math/ops/arith.jl) |
| Evaluate a small correction | Use `expm1` and `log1p` on the correction itself. Selected `Double32` scalar methods already guard widening to one `Float64`. | A conversion to `Float64` can lose a sparse low word. The guarded scalar methods fall back to evaluation through a two-word `Double64` path. [Double32 kernels](../../../src/math/elementary/double32.jl) |
| Evaluate arrays | Use `DoubleFloats.simdmap!` when its destination, storage, and result semantics fit. Use explicit scalar evaluation when scalar agreement is required and the batch route can round differently. | The existing API requires equal axes and uses snapshots for overlap. Its default scalar error leaves prior writes in order. With threads, failures can leave writes in other chunks. [Batch API](../../../src/math/elementary/simd.jl) |
| Evaluate a matrix function | Use the corresponding public matrix method and preserve known structure. | Dedicated `exp`, `log`, and `sqrt` handle cases outside the diagonalizable inputs accepted by the generic eigen-based `matrixfunction`. Select by operation and branch. [Matrix dispatch](../../../src/math/linearalgebra/matrixfunction.jl) |
| Round or export | Use `HILO` and the desired component encoding for lossless export. | `Float64(::Double64)` returns the high word. `Float64(::Double32)` forms a rounded sum, which can lose the low word. `BigFloat(x)` adds both words at the active precision, so use enough precision for their exponent span or reconstruct from exact dyadics. [Conversions](../../../src/type/constructors.jl) |

For an adapter, keep the guard, reference, and fallback separate
from the reused method. The guard establishes whether the method is
eligible. The reference tests the promised behavior, and the fallback
uses the retained inputs if the method cannot meet the requirement.
When evaluating alternatives, include the cost of conversions,
temporary storage, and any checks performed on each production call.

## Run the worked paths

Run this Julia block with DoubleFloats installed. The assertions check
three different boundaries: cancellation in a formula, representability
in one wider word, and construction of sensitive matrix data.

```julia
using DoubleFloats, LinearAlgebra

delta = 0x1p-60

# The small quantity is available before the sum rounds.
@assert log(1.0 + delta) == 0.0
@assert log1p(Double64(delta)) > 0

# A pair of Float32 words can contain a correction a single Float64 loses.
p = Double32(1.0f0, Float32(delta))
@assert HILO(p) == (1.0f0, Float32(delta))
@assert Float64(p) == 1.0
setprecision(BigFloat, 128) do
    @assert BigFloat(p) - 1 == BigFloat(delta)
end

# The same correction distinguishes two rows of a linear system.
u = one(Double64)
d = Double64(delta)
A = [u u; u u + d]
b = [Double64(3), Double64(3) + 2d]
@assert Float64.(A) == ones(2, 2)
x = A \ b
@assert x == Double64[1, 2]
```

For the matrix example, the known solution tests forward error
directly. For other systems a residual on the retained data measures
how well the result satisfies the equations. Relating that residual
to forward error requires information about conditioning.
[Worked matrix example](../../apotheosis.md#a-correction-that-changes-the-problem)
