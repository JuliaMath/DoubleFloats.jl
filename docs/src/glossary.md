# Glossary

Terms and symbols are grouped by their role in the manual. Each entry
starts with the definition shown when you hover over or focus a linked
term. Select the link to open the entry. Symbols can have different
meanings in different formulas. For example, the matrix dimension
`n` and an exponential reduction index belong to different contexts.

## Floating-point representation

### [Floating-point number](@id glossary-floating-point)

A number represented with a sign, a significand, and an exponent. The exponent lets the spacing between representable values vary with magnitude.[^floating-point]

### [Underlying type T](@id glossary-underlying-type)

The component format in `DoubleFloat{T}`. It is `Float64`, `Float32`, or `Float16` for the three supported real DoubleFloat types.

### [DoubleFloat and the Double64, Double32, and Double16 types](@id glossary-doublefloat)

A real number stored as the unevaluated sum of two floats of the same type. The suffix identifies the component format. For example, `Double64` stores two `Float64` values.

### [Float64, Float32, and Float16](@id glossary-binary-formats)

Julia's IEEE binary floating-point formats with 64, 32, and 16 storage bits, respectively. Their normal significands have 53, 24, and 11 bits, including the implicit leading bit.

### [BigFloat and MPFR](@id glossary-bigfloat)

`BigFloat` is Julia's arbitrary-precision binary floating-point type backed by MPFR. Its chosen precision controls significand bits, and its exponent range is wider than that of the DoubleFloat component formats.

### [Float128 and Quadmath](@id glossary-float128)

`Float128` is the IEEE binary128 type supplied by Quadmath.jl. It has a 113-bit normal significand and is used as an intermediate by some functions.

### [Complex value and imaginary unit i](@id glossary-complex)

A number of the form a + bi, with real part a, imaginary part b, and i² = −1. Julia uses `im` for the imaginary unit. `ComplexDF64` and its smaller counterparts store two DoubleFloat values.

### [Significand](@id glossary-significand)

The part of a floating-point representation that carries its significant digits. In a binary format the exponent scales the significand by a power of two.

### [Exponent and exponent range](@id glossary-exponent)

The exponent sets the scale of the significand. The exponent range governs the largest finite and smallest positive magnitudes the format can store.

### [Precision](@id glossary-precision)

The capacity to distinguish nearby values, usually expressed in significand bits or decimal digits. A two-word format's nominal precision describes ordinary normalized pairs. Its effective precision depends on the components and the result scale.

### [High and low components, hi and lo](@id glossary-components)

The high component carries the leading approximation and the low component stores its correction. The represented number is their exact sum. `HILO(x)` returns the stored pair. A component is also called a word or limb.

### [Normalized two-word pair](@id glossary-normalized-pair)

A pair arranged so the high word carries the leading approximation and the low word is a small, nonoverlapping correction. The ordinary kernels bound the low word by half the spacing of the high word's binade.

### [Binade](@id glossary-binade)

A binary exponent band with magnitudes from 2ᵉ inclusive to 2ᵉ⁺¹ exclusive, for integer e. Within a normal binade the underlying binary format has constant spacing.

### [Normal and subnormal numbers](@id glossary-subnormal)

A normal binary float has an implicit leading 1 in its significand. A nonzero subnormal lies below the smallest positive normal, with the same fixed spacing throughout the subnormal range.

### [Overflow](@id glossary-overflow)

When a result, rounded with the format precision and an unrestricted exponent, exceeds the finite range of the format. Round-to-nearest returns signed infinity on overflow. Other modes can return the largest finite value of the appropriate sign.

### [Underflow and gradual underflow](@id glossary-underflow)

At very small magnitudes, the format's fixed subnormal grid limits precision. A result can round to a subnormal or signed zero. Gradual underflow is the transition through that grid.

### [Rounding and rounding midpoint](@id glossary-rounding)

Rounding maps an exact value to a representable one according to a rule. A midpoint lies halfway between adjacent representable values. Round-to-nearest, ties-to-even selects the endpoint with an even low-order bit at an exact tie.

### [Signed zero, ±0](@id glossary-signed-zero)

IEEE floating point stores positive and negative zero. They compare equal numerically, while operations such as reciprocal and sign-sensitive functions can distinguish the signs.

### [Infinity, ±∞ and ±Inf](@id glossary-infinity)

The two signed infinite values of a floating-point format. They can result from overflow, division by zero, or evaluation at an infinite argument.

### [NaN](@id glossary-nan)

A floating-point value meaning “not a number.” It can represent an invalid arithmetic result, and ordinary ordered comparisons against it are false.

### [Unit in the last place, ulp(x)](@id glossary-ulp)

The weight of the last place of the underlying format at the scale of x. In an ordinary normal binade it is the gap between adjacent values. The Accuracy Report uses a separately defined relative working-precision unit.[^floating-point]

### [Spacing and eps](@id glossary-eps)

Spacing is the gap between adjacent representable values. Julia uses `eps(T)` for the format's precision scale at one and `eps(x)` for spacing at a value. For DoubleFloat error reports, `eps(D)` supplies a relative working-precision scale.

### [Widening and narrowing](@id glossary-widening)

Widening converts a value to a representation with more working precision or range. Narrowing converts it to one with less. Conversion preserves only the information representable in the destination.

### [String literal, constructor, and parse](@id glossary-construction)

A string literal is quoted text written in Julia code. A constructor creates a value of a specified type. Parsing reads a textual representation into a typed value. DoubleFloat string literals such as `df64"0.2"` read the decimal text directly at the requested precision.

### [Rational number and //](@id glossary-rational)

A quotient of two integers with nonzero denominator. Julia's `a // b` constructs that fraction without first rounding it to floating point.

### [Bitstype, inline storage, and platform bit width](@id glossary-bitstype)

A bitstype is an immutable Julia type represented directly by bits, with fields that are themselves bitstypes. Arrays of these values can store the elements inline rather than as references to separately allocated objects.

## Error and numerical evaluation

### [Absolute error](@id glossary-absolute-error)

The magnitude of the difference between a computed result and its reference. For a real scalar it is |computed − reference|.

### [Relative error](@id glossary-relative-error)

Absolute error divided by the magnitude of a nonzero reference result. Use absolute error or a suitable problem scale when the reference is zero.

### [Reference result](@id glossary-reference-result)

A comparison value from an exact identity, a known value, or an independent computation with adequate precision. A finite-precision reference has its own error.

### [Tolerance and approximate equality, ≈](@id glossary-tolerance)

A tolerance is an allowed difference. An absolute tolerance has the units of the result, and a relative tolerance scales with a magnitude. In Julia, `≈` calls `isapprox`. DoubleFloat's defaults are described in the precision guide.

### [Residual](@id glossary-residual)

The difference left when a computed quantity is substituted into its defining equation. For a linear solve it can be written Ax − b. A small residual measures how well the equation is satisfied.

### [Conditioning and condition number](@id glossary-conditioning)

Conditioning describes the sensitivity of a mathematical problem to perturbations in its inputs. A condition number quantifies that sensitivity. It helps translate a residual or input error into an estimate of result error.

### [Rounding error and input rounding](@id glossary-rounding-error)

Rounding error is the difference caused by representing a value with finite precision. Input rounding occurs before evaluation, for example when decimal text is first converted to Float64.

### [Cancellation](@id glossary-cancellation)

Subtraction of nearly equal values leaves a small difference. If the operands already carry error, that error can be large relative to the difference.

### [Root, pole, and fixed point](@id glossary-sensitive-points)

A root is a zero of a function. A pole is a singularity where its magnitude diverges with an inverse-power law. At a fixed point, the function returns its argument.

### [Error-free transformation](@id glossary-error-free)

An operation that returns several floats whose exact sum equals an exact arithmetic result, under its representability assumptions. `two_sum` and `two_prod` return a rounded part and the corresponding rounding error.

### [Fused multiply-add, fma](@id glossary-fma)

Evaluates ab + c with one rounding of the combined result. It can recover product residuals that would be lost by rounding multiplication and addition separately.

### [Compensated arithmetic](@id glossary-compensated)

Arithmetic that carries a correction for rounding incurred in an earlier step. For example, a compensated quotient uses the division residual to refine the leading quotient.

### [Domain, branch, and domain error](@id glossary-domain)

A domain specifies the inputs admitted by a function or path. A branch selects a value when a formula has several possible values. Julia can throw `DomainError` when an argument lies outside an operation's real domain.

### [Reduced argument and reconstruction](@id glossary-range-reduction)

Range reduction transforms the original argument into a smaller or better behaved range. Reconstruction combines the approximation there with the scaling, symmetry, or offset needed for the original input.

### [Dyadic number and anchor](@id glossary-dyadic)

A dyadic number has the form j/2ᵏ for integers j and nonnegative k. An anchor is a reference point for local evaluation. A dyadic anchor can be represented exactly when its significant bits and exponent fit the format.

### [Taylor series, polynomial, and truncation error](@id glossary-series)

A Taylor series expands a function about a given point using derivatives. A finite set of terms is a polynomial. Truncation error is the contribution of omitted terms or steps.

### [Continued fraction and rational approximation](@id glossary-continued-fraction)

A continued fraction is a nested expression of the form a₀ + b₁/(a₁ + b₂/(a₂ + ⋯)). A finite truncation with polynomial entries gives a rational approximation, a ratio of polynomials.

### [Horner evaluation](@id glossary-horner)

Evaluates a polynomial through nested multiplication and addition, such as a₀ + x(a₁ + xa₂). This avoids forming each power separately.

### [Sterbenz's lemma](@id glossary-sterbenz)

For two same-sign floating-point numbers within a factor of two of each other, subtraction is exact when the exact difference remains representable. IEEE gradual underflow includes differences on the subnormal grid.

### [Rounding lattice and Δ](@id glossary-rounding-grid)

A lattice is a regular set of points. Near underflow the underlying format has equally spaced points at integer multiples of Δ, its least positive subnormal.

### [Working-precision error unit and ε_D](@id glossary-working-unit)

A relative reporting scale for type D. The manual uses ε_D = 2⁻¹⁰⁴ for Double64 and 2⁻⁴⁶ for Double32. One report unit means that relative error, which can differ from one representable step at the result.

### [Error budget](@id glossary-error-budget)

An allowance for error across the stages of a computation, including input conversion, approximation, evaluation, and reconstruction.

### [Convergence and termination](@id glossary-convergence)

Convergence is approach to a limiting value as an iteration proceeds. Termination is the rule that stops the actual finite computation.

### [Sample percentile, p99, and sample maximum](@id glossary-percentile)

The p99 is the estimated 99th percentile of the observed errors, with about 99% of the sample at or below it. The sample maximum is the largest observed error. Both describe the sampled inputs.

### [Interquartile range](@id glossary-iqr)

The difference between the 75th and 25th percentiles. It measures the spread of the middle half of the observed timings or errors.

### [Newton correction](@id glossary-newton)

Uses a local linear approximation of an equation to improve an estimate of its root. Reciprocal and square root kernels express this correction in terms of the residual of the leading approximation.

### [Reciprocal](@id glossary-reciprocal)

The multiplicative inverse 1/x of a nonzero x. A reciprocal reduction uses this transformed input to put the calculation in a more convenient range.

### [Roundoff floor](@id glossary-roundoff-floor)

The scale where further iterations stop producing a smaller correction because of finite arithmetic or representation.

### [Recurrence](@id glossary-recurrence)

A rule that computes the next value from earlier values. For triangular matrix functions the order in which entries are computed is part of the recurrence.

### [Minimax and coefficient tapering](@id glossary-minimax)

A minimax approximation minimizes the largest error over a stated interval for a specified error measure and approximation family. A coefficient taper uses lower precision where the term contributes little to the final error.

### [Quantization-limited normal result](@id glossary-grid-limited)

The result's high word is normal, but the low word is too small to retain ordinary working precision. The accuracy report uses the range below Δ / eps(D) to identify this regime.

## Scalar functions and notation

### [Scalar, vector, and matrix](@id glossary-scalar-vector-matrix)

A scalar is one value. A vector is an ordered one-dimensional collection. A matrix is a rectangular collection with row and column indices.

### [Comparison and interval notation, ≤ ≥ ∈ ±](@id glossary-relations)

The signs ≤ and ≥ include equality. The sign ∈ means “belongs to,” and square brackets include the written endpoints of an interval. The sign ± means both the positive and negative choices.

### [Absolute value and magnitude, |x|](@id glossary-magnitude)

For a real x, |x| is its distance from zero. For a complex x, |x| is its Euclidean distance from zero in the complex plane. Matrix norms use double bars.

### [Argument and function value, x and f(x)](@id glossary-function-notation)

The symbol x denotes a function's input when used in f(x). The expression f(x) is the value of function f at x, and f′(x) is its derivative when it exists.

### [Small correction or perturbation, δ](@id glossary-delta)

A small change to an input. In a formula such as log(1 + δ), δ is the offset from one whose contribution can disappear when 1 + δ is rounded.

### [Natural exponential and logarithm, exp, log, and ln](@id glossary-exp-log)

`exp(x)` is eˣ, with e the base of the natural logarithm. `log(x)`, also written ln(x), is its real inverse for x > 0. The suffixes 2 and 10 specify other bases.

### [expm1 and log1p](@id glossary-offset-functions)

`expm1(x)` computes exp(x) − 1 and `log1p(x)` computes log(1 + x). Their specialized algorithms preserve small offsets when x is near zero.

### [Trigonometric and inverse circular functions](@id glossary-trigonometric)

The circular functions include sine, cosine, and tangent of an angle. Their principal inverses include arcsine, arccosine, and arctangent. π is the half-turn angle in radians.

### [Hyperbolic and inverse hyperbolic functions](@id glossary-hyperbolic)

The hyperbolic functions include sinh(x) = (eˣ − e⁻ˣ)/2, cosh(x) = (eˣ + e⁻ˣ)/2, and tanh(x) = sinh(x)/cosh(x). Their inverse functions use the branches and domains stated for the respective operations.

### [Paired sine/cosine and cis](@id glossary-paired-trig)

`sincos(x)` returns the tuple (sin(x), cos(x)). `cis(x)` returns the complex quantity cos(x) + i sin(x).

### [Bessel functions and order n](@id glossary-bessel)

Jₙ(x) and Yₙ(x) are solutions of Bessel's differential equation of the first and second kind. The integer order n identifies the member of the family used by the documented calls.

### [Gamma function](@id glossary-gamma)

A function extending the shifted factorial, with Γ(n) = (n − 1)! for positive integers n. It has poles at nonpositive integers.

### [Error function and complementary error function](@id glossary-erf)

`erf(x)` is the integral of exp(−t²) from 0 to x multiplied by 2/√π. Its complement is `erfc(x)` = 1 − erf(x).

### [Arithmetic-geometric mean, AGM](@id glossary-agm)

The common limit of two positive sequences formed by repeatedly taking the arithmetic and geometric means of the previous pair.

### [Complete elliptic integral, parameter m and modulus k](@id glossary-elliptic-integral)

The complete elliptic integral of the first kind integrates 1/√(1 − m sin²θ) from θ = 0 to π/2. `ellipk` takes the parameter m. A formula using modulus k supplies m = k².

### [Widened arithmetic, ⊕ ⊖ ⊗ ⊘](@id glossary-widened-operators)

DoubleFloats infix operators for widened addition, subtraction, multiplication, and division. They correspond to `add2`, `sub2`, `mul2`, and `div2`.

### [Paired normalization and hypot](@id glossary-paired-normalization)

`hypot(x, z)` computes the Euclidean length h = √(x² + z²) with scaling where needed. For nonzero length, paired normalization returns (x/h, z/h).

### [Predicate](@id glossary-predicates)

A function that tests a property and returns a Boolean value. For example, `isfinite` tests whether a number is finite.

### [π and triple-double constants](@id glossary-triple-double)

π is the ratio of circumference to diameter. A triple-double constant stores a leading value and two corrections. Near multiples of π, retaining those corrections helps compute a small reduced angle.

### [Dyadic table index j and integer reduction n](@id glossary-scalar-reduction-indices)

In the exponential kernels, j indexes a table of values 2^(j/128). In offset reconstruction, n is the integer power-of-two scale. These indices have different roles from matrix dimension n.

### [Reduced variables m, c, and t](@id glossary-log-reduced-variables)

In the logarithm reduction, m is the normalized mantissa, c is a table center, and t = (m − c)/(m + c) is the small argument of the odd series. In log1p the reduced argument is t = x/(2 + x).

### [Offset q in expm1](@id glossary-exp-offset)

q is a reduced approximation to exp(t) − 1. The identity exp(2t) − 1 = 2q + q² explains the doubling update.

## Arrays, execution, and measurements

### [Broadcasting and dotted calls](@id glossary-broadcast)

Julia's elementwise application with compatible axes. `f.(x)` applies f to elements of x, and `.=` writes a broadcast result into an existing destination.

### [Axes and index](@id glossary-axes)

An array's axes give its valid indices in each dimension. An axis describes index values as well as the number of elements.

### [Destination and preallocation](@id glossary-destination)

The destination is the array receiving the result. Preallocation creates that storage ahead of the timed call or loop so multiple calls can reuse it.

### [Alias, view, and snapshot](@id glossary-aliasing)

Arrays alias when their storage overlaps. A view exposes existing storage through another array object. A snapshot captures the original input values so writes cannot change what later elements read.

### [Dense and disjoint storage](@id glossary-dense-storage)

Dense arrays store all entries. Disjoint arrays have separate memory regions. Specialized batches in this package check the actual storage and overlap before using their dense path.

### [Batch, block, and lane](@id glossary-batch)

A batch is a group of elementwise evaluations in one call. A block is the group checked together for a specialized route. A lane is one input and its corresponding result within that evaluation.

### [Kernel, guard, and fallback](@id glossary-kernel)

A kernel is an implementation of a specific operation or regime. A guard checks whether its assumptions hold. A fallback is the route used when the input fails those checks.

### [SIMD](@id glossary-simd)

Single instruction, multiple data. A vector instruction performs the same arithmetic operation on several hardware lanes. A batch API can also use scalar arithmetic when its SIMD path is unavailable.

### [Threading and serial execution](@id glossary-threading)

Threading can let several worker threads execute chunks concurrently. Serial execution processes the work on one thread, with the documented mutation and exception order.

### [Method dispatch and type stability](@id glossary-dispatch)

Dispatch selects an implementation based on the argument types. An operation is type-stable when its result type can be inferred from the types of its inputs, without depending on their values.

### [Allocation and in-place operation](@id glossary-allocation)

Allocation obtains new storage. An in-place operation writes into an existing destination. The same call may still allocate temporaries or a snapshot.

### [Throughput, latency, and speedup](@id glossary-throughput)

Throughput counts work completed per unit time. Latency is the duration of a single operation. A speedup is baseline time divided by candidate time for the same workload.

### [Benchmark, warm-up, and fixture](@id glossary-benchmark)

A benchmark measures a specified workload. A fixture fixes inputs and conditions for comparison. Warm-up runs exercise compilation and initialization before timed runs.

### [Compiler target, LLVM, and FMA support](@id glossary-compiler-target)

The compiler target specifies which processor instructions may be generated. LLVM is the compiler infrastructure used by Julia. FMA availability and vector instruction support can affect measured throughput.

### [BLAS and LAPACK](@id glossary-blas-lapack)

BLAS specifies basic vector and matrix operations, including matrix products. LAPACK supplies higher-level routines such as factorizations and eigensolvers. Their standard numerical kernels use conventional floating-point and complex types.

### [Uniform distribution, standard normal distribution, and RNG](@id glossary-random)

A uniform distribution gives equal probability to intervals of equal length within its support. The standard normal distribution has mean zero and variance one. An RNG supplies the pseudorandom values used for sampling.

### [Fast-math and reassociation](@id glossary-fastmath)

Julia's `@fastmath` can relax floating-point rules, including permitting arithmetic to be regrouped. Regrouping can change rounding and invalidate identities that recover rounding errors.

### [Benchmark ratios and size n](@id glossary-benchmark-ratios)

In the benchmark tables, D64/F64 and D32/F32 are DoubleFloat time divided by the corresponding Float time. Big/D64 and Big/D32 use BigFloat time in the numerator. The symbol n is the dimension of a square test matrix.

## Linear algebra and matrix functions

### [Linear system, A, x, and b](@id glossary-linear-system)

Ax = b asks for the unknown vector x, given coefficient matrix A and right-hand side b. Julia's `A \ b` solves the system with a method chosen for the inputs.

### [Identity matrix I and nilpotent part N](@id glossary-identity-matrix)

The identity matrix I has ones on its diagonal and zeros elsewhere. In the Jordan-block example, N = A − I and N² = 0. A matrix is nilpotent when some positive power is zero.

### [Diagonal and triangular matrix](@id glossary-triangular)

A diagonal matrix has zeros off the diagonal. A triangular matrix has zeros on one side of the diagonal, so an upper-triangular matrix has zeros below it.

### [Transpose, adjoint, symmetric, and Hermitian](@id glossary-adjoint)

Transpose swaps rows and columns. Adjoint, written A′ or A*, transposes and conjugates. A symmetric matrix equals its transpose, and a Hermitian matrix equals its adjoint.

### [Positive definite](@id glossary-positive-definite)

A Hermitian matrix A is positive definite if x*Ax > 0 for every nonzero x. A real symmetric matrix uses the same test with transpose in place of adjoint.

### [Rank, determinant, trace, and null space](@id glossary-matrix-invariants)

Rank is the dimension of the matrix's range. The determinant is the signed or complex product of the eigenvalues. The trace is the sum of the diagonal. The null space consists of x with Ax = 0.

### [Norm and operator one-norm, ‖A‖₁](@id glossary-norm)

A norm measures size. The induced matrix one-norm ‖A‖₁ is the largest absolute column sum. Julia's `opnorm(A, 1)` gives this norm.

### [Factorization, LU, QR, and LQ](@id glossary-factorization)

A factorization rewrites a matrix in simpler factors. LU uses triangular factors, with a permutation if pivoted. QR uses an orthogonal or unitary factor followed by an upper triangle. LQ reverses the order and uses a lower triangle.

### [Cholesky and Bunch–Kaufman factorizations](@id glossary-structured-factorization)

Cholesky represents a positive-definite matrix by a triangular factor times its adjoint. Bunch–Kaufman uses pivoting and diagonal blocks to factor symmetric or Hermitian matrices that may be indefinite.

### [Singular value decomposition and pseudoinverse](@id glossary-svd)

The singular value decomposition writes A = UΣV* with nonnegative diagonal singular values in Σ. The Moore–Penrose pseudoinverse inverts the nonzero singular values and exchanges the two singular vector bases.

### [Eigenvalue, eigenvector, and spectrum](@id glossary-eigen)

A nonzero vector v is an eigenvector when Av = λv, and λ is its eigenvalue. The spectrum is the set of eigenvalues.

### [Orthonormal and unitary](@id glossary-orthonormal)

Orthonormal vectors have unit norm and are pairwise orthogonal. A square matrix with orthonormal columns is unitary, or orthogonal in the real case.

### [Schur and Hessenberg forms](@id glossary-schur)

Schur form is triangular over the complex numbers and is obtained by a unitary similarity. Real Schur form may contain 2×2 diagonal blocks. Upper Hessenberg form allows a nonzero first subdiagonal and zeros below it.

### [Sylvester and Lyapunov equations](@id glossary-sylvester)

A Sylvester equation is linear in the unknown matrix X, for example AX + XB + C = 0. The documented Lyapunov equation uses B = A*, giving AX + XA* + C = 0.

### [Jordan block, defective, and diagonalizable](@id glossary-jordan)

A Jordan block has one eigenvalue on the diagonal and ones immediately above it. A matrix is diagonalizable if it has a basis of eigenvectors. A defective matrix lacks such a basis.

### [Matrix function and principal branch](@id glossary-matrix-function)

A matrix function acts on the whole square matrix, including the interaction between entries. A principal branch is a specified choice among possible values, such as the principal matrix logarithm on its standard domain.[^matrix-functions]

### [Singular matrix and singular exception](@id glossary-singular)

A square matrix is singular when it has no inverse, equivalently when zero is an eigenvalue. Julia's `SingularException` signals singularity in operations that require nonsingular input.

### [Scaling and squaring and inverse scaling](@id glossary-scaling-squaring)

For the exponential, compute at a scaled-down argument and recover the result by repeated squaring. For the matrix logarithm, inverse scaling takes square roots to approach the identity and rescales the logarithm afterward.

### [Paterson–Stockmeyer evaluation](@id glossary-paterson-stockmeyer)

A polynomial evaluation scheme that groups powers into blocks and reuses powers of the argument. For matrix arguments it reduces the number of expensive matrix multiplications.

### [Björck–Hammarling recurrence](@id glossary-bjorck-hammarling)

A recurrence for a triangular matrix square root. After choosing the diagonal square roots, it solves for off-diagonal entries using already calculated entries and sums of diagonal roots.

### [Packed arithmetic and structural zero](@id glossary-packed)

Packing arranges matrix blocks in contiguous buffers for efficient reuse. A structural zero is known from the shape, such as an entry below the diagonal of an upper triangle. The package checks its stored components before using that structure.

### [Normalized matrix argument T and distance ‖T − I‖₁](@id glossary-matrix-bound)

Here T is the triangular matrix entering the current step and I is the identity. ‖T − I‖₁ is the largest absolute column sum of their difference.

## Symbols in the crossover and accuracy reports

### [Reference y, computed ŷ, and error E](@id glossary-reported-error)

In the error formula, y is the reference, ŷ is the computed result, and E = |ŷ − y|/(|y| ε_D) for nonzero y. The quantity E is relative error measured in the tested type's report units.

### [Time Tₛ, Tₖ, and speedup target σ](@id glossary-model-time)

Tₛ is scalar baseline time per element, Tₖ is the time for candidate k, and σ is the desired speedup. Tᵥ denotes the batch time when scalar and batch evaluation are compared.

### [Observed errors E₉₉,ₖ and Eₘₐₓ,ₖ and targets τ](@id glossary-model-targets)

E₉₉,ₖ and Eₘₐₓ,ₖ are the p99 and maximum observed errors for candidate k. τ₉₉ and τₘₐₓ are the corresponding targets, in the same working-precision units.

### [Normalized time qₖ and error aₖ](@id glossary-model-scores)

qₖ is target speedup × candidate time / scalar time. aₖ is the larger of the p99 and maximum errors after each is divided by its target. A value at most one meets the corresponding targets.

### [Workload c, candidate k, and feasibility I(c,k)](@id glossary-model-feasibility)

The workload c specifies the inputs, arrangement, storage, size, and target. The candidate k is an evaluation route. I(c,k) is 1 if the candidate passes the hard requirements for that workload and 0 otherwise. The identity matrix I has a separate entry.

### [Coverage grade μ_C and joint grade Q(c,k)](@id glossary-model-grade)

μ_C is an optional grade for coverage of the native route. Q is the smallest of the feasibility, speed, accuracy, and coverage grades. The grade expresses a preference on a scale from zero to one.

### [Weight w, log cost L_w, and crossover w*](@id glossary-model-weight)

w is the weight on normalized error in the weighted log cost L_w. w* is the weight where two feasible routes have equal cost. If the batch is faster and the scalar route has smaller error, the batch is preferred below w*.

### [Speedup s and error-score ratio r](@id glossary-model-ratios)

In the Technical Guide's crossover formula, s is scalar time divided by batch time, and r is batch normalized error divided by scalar normalized error. The formula applies when both ratios exceed one.

### [Scalar route s and vector route v](@id glossary-model-candidates)

The subscripts s and v identify scalar and vector candidates in comparisons. Tₛ and Tᵥ are their times, and aₛ and aᵥ are their normalized error scores.

### [Block eligibility p, pⱼ, m, b, and K](@id glossary-model-blocks)

p is the probability a lane qualifies, and pⱼ is its probability of qualifying for regime j. m is block width, b is the probability the whole block can use the native route, and K counts rejected lanes. The notation ⌊m/8⌋ rounds down to the nearest integer.

### [Native and scalar costs N and S, and overhead H](@id glossary-model-costs)

N and S are per-element times for a fully eligible native batch and scalar fallback, respectively. H is extra per-element overhead for mixing the paths. These are workload costs, not universal constants.

### [Native fraction π and error distributions F](@id glossary-model-distributions)

In the mixture model, π is the fraction of lanes actually evaluated by the native route. Fₙ(e) and Fₛ(e) are the fractions with error at or below e conditional on native and scalar routes. F_E(e) is the combined fraction.

### [Matrix residual notation AV − VΛ](@id glossary-eigen-residual)

In the accuracy report, columns of V are computed eigenvectors and Λ contains their corresponding eigenvalues on the diagonal. AV − VΛ measures how closely those eigenpairs satisfy the decomposition.

[^floating-point]: David Goldberg, [What Every Computer Scientist Should Know About Floating-Point Arithmetic](https://doi.org/10.1145/103162.103163), *ACM Computing Surveys* 23 (1991).

[^matrix-functions]: Nicholas J. Higham, [Functions of Matrices: Theory and Computation](https://doi.org/10.1137/1.9780898717778), SIAM (2008).
