# Improve the DoubleFloats manual

Use the package source and runnable Julia examples to establish public behavior.
Preserve the published Markdown page paths and the named references for the
vector and matrix kernels.

## Audit findings

- The overview, README, User Guide, and Characteristics page repeat numerical
  claims with different wording and little context. Integer constructors in
  `src/Double.jl` convert through the underlying float, and `src/extras/misc.jl`
  derives scalar comparison defaults from the high words. Neither behavior is
  captured by the older blanket descriptions.
- Construction and display examples conflate decimal parsing with inspection
  of stored components. `src/type/parse.jl` parses numeric text, while
  `src/type/string.jl` emits constructor-shaped text for `stringtyped`.
  The two-input constructors have different normalization behavior.
- Users choosing an array operation need to see the distinction between
  broadcasting and matrix functions before seeing kernel details. The relevant
  dispatch and fallback behavior lives in `src/math/elementary/simd.jl` and
  `src/math/linearalgebra/{matrixfunction,matfun}.jl`.
- The special functions page lists names without implemented methods.
  `src/math/special/` also makes the distinction between the elliptic
  parameter and modulus important and includes the endpoint at one.

## Revision plan

1. Put a working setup and first calculation on the landing page. Turn the
   README into a matching entry point. Organize the sidebar around getting
   started, computing, and accuracy and implementation.
2. Give each type and precision fact one primary home. Teach the distinction
   between accuracy, precision, and exponent range in plain terms before
   introducing high and low components or the error metric used in reports.
   Explain when to widen existing data, how to enter precise constants, and
   how to choose comparison tolerances.
3. Start the computation guide with familiar scalar operations, then show
   broadcasting, preallocation, and whole-matrix functions. Put the detailed
   batch contract beside its example, matrix function domains beside the
   matrix API, and SIMD or matrix eligibility ranges in the Technical Guide.
4. Replace stale transcripts with short, runnable examples. Add a reference
   calculation that distinguishes input rounding from arithmetic error, a
   complete vector workflow that compares broadcast with preallocation, and
   a matrix workflow that checks a defective triangular example against a
   known result.
5. Check the reference pages against dispatch and exports. Keep benchmark
   tables and accuracy measurements tied to the versions, input ranges,
   and error metrics they actually describe.

## Audience review

A Julia newcomer should be able to copy the first example and understand what
the extra precision buys. Put installation and a decimal example above the
navigation links. Present dimensional and type constraints next to the
operations that need them. A numerical practitioner needs a path from input
construction to a reference calculation and guidance on residuals. A
performance-focused reader needs a direct link from each operation to its
eligibility and measured timing. Introduce each of those details where it
first answers a practical question and link to the deeper treatment.

## Verification

Run the complete examples in the documentation build and on the minimum
supported Julia version. Confirm that the rendered sidebar, local page links,
and section links lead to the intended content. Read the revised pages in
each of the three audience orders, and fix duplicated explanations,
undefined terminology, and claims that exceed the source or the measurements.
Commit the sources and the corresponding tracked HTML.

## Implementation and flow review

- First use now goes from setup and a calculation to constructing and
  displaying values, then to the User Guide. The type comparison has
  one home in Representation and precision.
- The numerical path goes from input construction to a reference
  calculation, explicit error measures, and the sampled accuracy report.
  The report now explains its units and matrix residuals alongside its
  existing data.
- The performance path goes from ordinary operations to the vector
  batch or dense matrix contract, then to the corresponding Technical
  Guide section and its timings. The two kernel links also lead back
  to the public usage pages.
- The review separated scalar `isapprox` from strict error checks,
  distinguished scalar and matrix `expm1` and `log1p`, and removed a
  stale Double32 Schur limitation from the accuracy report. The
  contributor guide points to the same accuracy conventions as the
  user documentation.

The 13 runnable blocks passed on Julia 1.10.10 and in the Julia 1.13.3
Documenter build. Ten additional API contract checks passed on Julia
1.10.10. The rendered review verified the sidebar and 712 internal
links and asset references across 15 pages. Documenter supplies the
version-selector metadata on deployment. The recorded accuracy table
values are identical to those before the revision.
