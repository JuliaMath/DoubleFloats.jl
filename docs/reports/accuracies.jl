# Generates accuracy_report.md (in this directory).
#
# Run from anywhere:  julia docs/reports/accuracies.jl
# Every function is compared against a 512-bit BigFloat reference over
# random in-domain samples.  Errors are reported in units of the tested type's
# working precision ("ulps" below). The report covers a subset of the API.

import Pkg
Pkg.activate(joinpath(@__DIR__, "..", ".."))

using DoubleFloats, LinearAlgebra, Random, Printf
using SpecialFunctions: erf, erfc, gamma

setprecision(BigFloat, 512)
Random.seed!(20260718)

const NSAMPLES = 250

# Relative error of a DoubleFloat result against the BigFloat truth, in ulps.
function ulps(got, want::BigFloat, ulp::BigFloat)
    iszero(want) && return Float64(abs(BigFloat(got)))
    return Float64(abs(BigFloat(got) - want) / abs(want) / ulp)
end

"""
    accrow(name, fn, bigfn, sampler; domain) -> markdown table row

`sampler()` yields a tested-format point; errors are measured against
`bigfn(BigFloat(x))` over NSAMPLES points.
"""
function accrow(name, fn, bigfn, sampler, ulp; domain = "")
    errs = Float64[]
    for _ in 1:NSAMPLES
        x = sampler()
        got = fn(x)
        (isnan(got) || isinf(got)) && continue
        want = bigfn(BigFloat(x))
        (isnan(want) || !isfinite(want)) && continue
        push!(errs, ulps(got, want, ulp))
    end
    return accuracy_row(name, domain, errs)
end

accrow(name, fn, sampler, ulp; domain = "") = accrow(name, fn, fn, sampler, ulp; domain)

function accuracy_row(name, domain, errs)
    isempty(errs) && return "| `$name` | $domain | 0 | — | — |"
    sort!(errs)
    med = errs[(end + 1) ÷ 2]
    return @sprintf("| `%s` | %s | %d | %.2f | %.2f |", name, domain, length(errs), med, errs[end])
end

# Separate rounding on the inherited absolute lattice from ordinary
# relative accuracy. Classify by the reference even when a result is zero.
function exponential_results(op, inputs, ::Type{D}) where {D}
    T = typeof(HI(one(D)))
    step = BigFloat(nextfloat(zero(T)))
    normal_min = BigFloat(floatmin(T))
    unit = BigFloat(eps(D))
    quantization_limit = step / unit
    overflow_limit = BigFloat(floatmax(T)) + BigFloat(eps(floatmax(T))) / 2

    ordinary = Float64[]
    grid_errors = (Float64[], Float64[])
    agreements = zeros(Int, 2)
    counts = zeros(Int, 2)
    zeros_out = overflow_out = invalid = mismatches = 0
    for input in inputs
        ref = op(BigFloat(input))
        got = op(input)
        is_zero = iszero(got)
        is_overflow = isinf(got)
        zeros_out += is_zero
        overflow_out += is_overflow
        invalid += isnan(got)
        mismatches += is_zero != (ref <= step / 2) || is_overflow != (ref >= overflow_limit)
        bucket = ref < normal_min ? 1 : ref < quantization_limit ? 2 : 0
        bucket != 0 && (counts[bucket] += 1)
        isfinite(got) || continue
        if bucket == 0
            push!(ordinary, ulps(got, ref, unit))
        else
            value = BigFloat(got)
            push!(grid_errors[bucket], Float64(abs(value - ref) / step))
            agreements[bucket] += value == round(BigInt, ref / step) * step
        end
    end
    maxstep = map(xs -> isempty(xs) ? "—" : @sprintf("%.6f", maximum(xs)), grid_errors)
    maxabs = map(xs -> isempty(xs) ? "—" : @sprintf("%.4e", maximum(xs) * step), grid_errors)
    summary = "| `$op` | $(length(inputs)) | $(counts[1]) | $(counts[2]) | $zeros_out | $overflow_out | $invalid | $mismatches |"
    nearest = [iszero(counts[i]) ? "—" : "$(agreements[i])/$(counts[i])" for i in 1:2]
    grids = ["| `$op` | $label | $(nearest[i]) | $(maxstep[i]) | $(maxabs[i]) |"
             for (i, label) in enumerate(("Subnormal range", "Quantization-limited normal range"))]
    return (; ordinary, summary, grids)
end

function exponential_boundary_inputs(inverse, ::Type{D}) where {D}
    T = typeof(HI(one(D)))
    step = BigFloat(nextfloat(zero(T)))
    first_normal = BigFloat(floatmin(T)) / step
    inputs = D[]
    for k in (0, 1, 2, 57, first_normal - 1, first_normal + 1, 4 * first_normal)
        x = D(inverse((BigFloat(k) + BigFloat(0.5)) * step))
        h, l = HILO(x)
        append!(inputs, (D(h, prevfloat(l)), x, D(h, nextfloat(l))))
    end
    push!(inputs, D(inverse(step / 4)), D(inverse(2 * BigFloat(floatmax(T)))))
    return inputs
end

function exponential_accuracy_table(cohort, results)
    summaries = join((r.summary for r in results), "\n")
    grids = join(Iterators.flatten(r.grids for r in results), "\n")
    return """
#### $cohort

| Function | Inputs | Subnormal | Grid-limited normal | Zero | Infinite | NaN | Outcome disagreements |
|:---|---:|---:|---:|---:|---:|---:|---:|
$summaries

| Function | Reference range | Nearest lattice agreements | Worst lattice steps | Worst absolute error |
|:---|:---|---:|---:|---:|
$grids
"""
end

function exponential_rounding_section(D, random_exp, random_exp2)
    # A low component can be one subnormal step away from an exact
    # integer input. Keep that perturbation in the reference evaluation.
    boundaries = setprecision(BigFloat, 1536) do
        (exponential_results(exp, exponential_boundary_inputs(log, D), D),
         exponential_results(exp2, exponential_boundary_inputs(log2, D), D))
    end
    return """
### Exponential rounding near the format limits

For `exp` and `exp2`, the main table reports relative working-precision
units for finite results with reference at or above `Δ / eps($D)`.
Here `Δ` is the smallest positive subnormal of the underlying float.
The subnormal range lies below the underlying float's minimum normal.
The quantization-limited normal range lies between that minimum and
`Δ / eps($D)`.

The lattice tables compare the sum of the two returned components with
the nearest multiple of `Δ` in these two ranges. They also show absolute
error and error measured in steps of `Δ`. Output outcome counts describe
the returned values and can overlap the reference range counts. A zero
or overflow disagreement compares the outcome with round-to-nearest
thresholds for the underlying format. Targeted probes use 1536-bit
references to resolve low components as small as the underlying
subnormal spacing.

$(exponential_accuracy_table("Random samples from the main table", (random_exp, random_exp2)))

$(exponential_accuracy_table("Targeted midpoint, zero, and overflow probes", boundaries))
"""
end

# -------------------------------------------------------------- sections --

function scalar_rows(T)
    ulp = BigFloat(eps(T))
    unit()     = T(rand())
    sym()      = T(2rand() - 1)
    wide()     = T((2rand() - 1) * 100)
    positive() = T(rand() * 100 + 1e-6)
    above1()   = T(1 + rand() * 100)
    near1()    = T(1 + (rand() - 0.5) * 2.0^-30)
    tiny()     = T((2rand() - 1) * 2.0^-40)
    nearone()  = T(1.0, T === Double64 ? rand() * 2.0^-54 : rand() * 2.0^-25)
    dom2()     = T((2rand() - 1) * 2)
    dom9()     = T((2rand() - 1) * 9)

    exp_results = exponential_results(exp, [wide() for _ in 1:NSAMPLES], T)
    expm1_row = accrow("expm1", expm1, sym, ulp; domain = "(-1, 1)")
    exp2_results = exponential_results(exp2, [wide() for _ in 1:NSAMPLES], T)
    explog = [
        accuracy_row("exp", "(-100, 100) ordinary range", exp_results.ordinary),
        expm1_row,
        accuracy_row("exp2", "(-100, 100) ordinary range", exp2_results.ordinary),
        accrow("log", log, positive, ulp; domain = "(0, 100)"),
        accrow("log", log, near1, ulp; domain = "1 ± 2⁻³¹"),
        accrow("log1p", log1p, sym, ulp; domain = "(-1, 1)"),
        accrow("log2", log2, positive, ulp; domain = "(0, 100)"),
    ]
    trig = [
        accrow("sin", sin, wide, ulp; domain = "(-100, 100)"), accrow("cos", cos, wide, ulp; domain = "(-100, 100)"),
        accrow("tan", tan, sym, ulp; domain = "(-1, 1)"),
        accrow("sin", sin, () -> T(1.47 + 0.2rand()), ulp; domain = "near π/2"),
        accrow("cos", cos, () -> T(1.47 + 0.2rand()), ulp; domain = "near π/2"),
        accrow("cos", cos, () -> T(3.04 + 0.2rand()), ulp; domain = "near π"),
    ]
    arctrig = [accrow("asin", asin, sym, ulp; domain = "(-1, 1)"), accrow("acos", acos, sym, ulp; domain = "(-1, 1)"), accrow("atan", atan, wide, ulp; domain = "(-100, 100)")]
    hyp = [
        accrow("sinh", sinh, dom2, ulp; domain = "(-2, 2)"), accrow("sinh", sinh, dom9, ulp; domain = "(-9, 9)"),
        accrow("cosh", cosh, dom2, ulp; domain = "(-2, 2)"), accrow("cosh", cosh, dom9, ulp; domain = "(-9, 9)"),
        accrow("tanh", tanh, dom2, ulp; domain = "(-2, 2)"), accrow("tanh", tanh, dom9, ulp; domain = "(-9, 9)"),
        accrow("asinh", asinh, wide, ulp; domain = "(-100, 100)"),
        accrow("asinh", asinh, tiny, ulp; domain = "±2⁻⁴⁰"), accrow("acosh", acosh, above1, ulp; domain = "(1, 101)"),
        accrow("acosh", acosh, nearone, ulp; domain = "1 + ε"), accrow("atanh", atanh, sym, ulp; domain = "(-1, 1)"), accrow("atanh", atanh, tiny, ulp; domain = "±2⁻⁴⁰"),
    ]
    special = [
        accrow("erf", erf, sym, ulp; domain = "(-1, 1)"), accrow("erfc", erfc, sym, ulp; domain = "(-1, 1)"),
        accrow("gamma", gamma, () -> T(0.1 + 9.9rand()), ulp; domain = "(0.1, 10)"),
        accrow("ellipk", ellipk, x -> big(pi) / (2 * DoubleFloats.agm(big"1.0", sqrt(1 - x))), unit, ulp; domain = "(0, 1)"),
        accrow("ellipk", ellipk, x -> big(pi) / (2 * DoubleFloats.agm(big"1.0", sqrt(1 - x))), () -> T(1) - T(2.0)^(-20 - 30rand()), ulp; domain = "1 - 2⁻²⁰⁻⁵⁰"),
    ]
    return explog, trig, arctrig, hyp, special, exponential_rounding_section(T, exp_results, exp2_results)
end

# ---------------------------------------------------- matrix functions --

# Residual-style accuracy for matrix routines: how well defining identities
# hold, in units of the tested format's working precision.
function matres(name, resfn; n = 8, samples = 25)
    errs = Float64[]
    try
        for _ in 1:samples
            push!(errs, resfn(n))
        end
    catch err
        @warn "matrix accuracy row unavailable" name exception = (err, catch_backtrace())
        return @sprintf("| `%s` | %d×%d | — | unavailable | unavailable |", name, n, n)
    end
    sort!(errs)
    return @sprintf("| `%s` | %d×%d | %d | %.2f | %.2f |",
                    name, n, n, samples, errs[(end + 1) ÷ 2], errs[end])
end

resid(T, M) = Float64(BigFloat(maximum(abs.(M))) / BigFloat(eps(T)))

function matrix_rows(T)
    return [
    matres("eigen residual  ‖AV−VΛ‖", n -> begin
        A = rand(T, n, n) .- 0.5
        F = eigen(A)
        resid(T, A * F.vectors - F.vectors * Diagonal(F.values)) / n
    end),
    matres("exp∘log roundtrip", n -> begin
        A = rand(T, n, n) .+ Diagonal(fill(T(n), n))
        resid(T, exp(log(A)) - A) / Float64(maximum(abs.(A))) / n
    end),
    matres("sqrt squared", n -> begin
        A = rand(T, n, n) .+ Diagonal(fill(T(n), n))
        resid(T, sqrt(A)^2 - A) / Float64(maximum(abs.(A))) / n
    end),
    matres("sin²+cos²−I", n -> begin
        A = rand(T, n, n) .- 0.5
        s, c = sincos(A)
        resid(T, s * s + c * c - I) / n
    end),
    ]
end

# -------------------------------------------------------------- assemble --

vinfo = string(VERSION)
hdr = "| function | domain | samples | median (ulps) | worst (ulps) |\n|:---------|:-------|--------:|--------------:|-------------:|"
mhdr = "| identity | size | samples | median (ulps) | worst (ulps) |\n|:---------|:-----|--------:|--------------:|-------------:|"
explog64, trig64, arctrig64, hyp64, special64, rounding64 = scalar_rows(Double64)
matrix64 = matrix_rows(Double64)
explog32, trig32, arctrig32, hyp32, special32, rounding32 = scalar_rows(Double32)
matrix32 = matrix_rows(Double32)

function accuracy_section(name, ulptext, explog, trig, arctrig, hyp, special, rounding, matrix)
    return """
## $name

Scalar errors are measured against a 512-bit `BigFloat` reference.
For nonzero references, the tables divide relative error by the working
precision unit, **1 ulp = $ulptext relative**. Each worst value is the
maximum over the listed samples.

### Exponentials and Logarithms

$hdr
$(join(explog, "\n"))

$rounding

### Trigonometric Functions

$hdr
$(join(trig, "\n"))

### Inverse Trigonometric Functions

$hdr
$(join(arctrig, "\n"))

### Hyperbolic and Inverse Hyperbolic Functions

$hdr
$(join(hyp, "\n"))

### Special Functions

`erf`, `erfc`, and `gamma` are computed via `Float128` before conversion
back to the tested type. The errors below include both steps.

$hdr
$(join(special, "\n"))

### Matrix Functions (identity residuals)

The matrix rows measure how closely the results satisfy the listed
identities on random matrices. Each residual uses the largest entry
magnitude, divided by dimension and working epsilon. The logarithm
and square root rows also divide by the largest input entry magnitude.
An unavailable row indicates an error during that measurement.

$mhdr
$(join(matrix, "\n"))
"""
end

double64_section = accuracy_section("Double64", "2⁻¹⁰⁴ (about 4.9e-32)", explog64, trig64, arctrig64, hyp64, special64, rounding64, matrix64)
double32_section = accuracy_section("Double32", "2⁻⁴⁶ (about 1.4e-14)", explog32, trig32, arctrig32, hyp32, special32, rounding32, matrix32)

report = """
# DoubleFloats Accuracy Report

*Generated by `docs/reports/accuracies.jl` on Julia $vinfo.*

This report samples a representative subset; **it does not cover all
available functions**.

$double64_section

$double32_section

"""

outpath = joinpath(@__DIR__, "accuracy_report.md")
open(outpath, "w") do io
    println(io, rstrip(report))
end
println("wrote ", outpath)

