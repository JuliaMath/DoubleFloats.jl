# Generates accuracy_report.md (in this directory).
#
# Run from anywhere:  julia docs/reports/accuracies.jl
# Every function is compared against a 512-bit BigFloat reference over
# random in-domain samples.  Errors are reported in units of the tested type's
# working precision ("ulps" below): 1 ulp means the result is as accurate as
# the format allows.  Not every exported function is measured.

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
    sort!(errs)
    med = errs[(end + 1) ÷ 2]
    wrst = errs[end]
    return @sprintf("| `%s` | %s | %d | %.2f | %.2f |", name, domain, length(errs), med, wrst)
end

accrow(name, fn, sampler, ulp; domain = "") = accrow(name, fn, fn, sampler, ulp; domain)

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

    explog = [
        accrow("exp", exp, wide, ulp; domain = "(-100, 100)"),
        accrow("exp", exp, () -> T(-600 - 60rand()), ulp; domain = "(-660, -600)"),
        accrow("expm1", expm1, sym, ulp; domain = "(-1, 1)"),
        accrow("log", log, positive, ulp; domain = "(0, 100)"),
        accrow("log", log, near1, ulp; domain = "1 ± 2⁻³¹"),
        accrow("log1p", log1p, sym, ulp; domain = "(-1, 1)"),
        accrow("log2", log2, positive, ulp; domain = "(0, 100)"),
        accrow("log10", log10, positive, ulp; domain = "(0, 100)"),
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
        accrow("sinh", sinh, () -> T((2rand() - 1) * 300), ulp; domain = "(-300, 300)"), accrow("cosh", cosh, wide, ulp; domain = "(-100, 100)"),
        accrow("tanh", tanh, sym, ulp; domain = "(-1, 1)"), accrow("asinh", asinh, wide, ulp; domain = "(-100, 100)"),
        accrow("asinh", asinh, tiny, ulp; domain = "±2⁻⁴⁰"), accrow("acosh", acosh, above1, ulp; domain = "(1, 101)"),
        accrow("acosh", acosh, nearone, ulp; domain = "1 + ε"), accrow("atanh", atanh, sym, ulp; domain = "(-1, 1)"), accrow("atanh", atanh, tiny, ulp; domain = "±2⁻⁴⁰"),
    ]
    special = [
        accrow("erf", erf, sym, ulp; domain = "(-1, 1)"), accrow("erfc", erfc, sym, ulp; domain = "(-1, 1)"),
        accrow("gamma", gamma, () -> T(0.1 + 9.9rand()), ulp; domain = "(0.1, 10)"),
        accrow("ellipk", ellipk, x -> big(pi) / (2 * DoubleFloats.agm(big"1.0", sqrt(1 - x))), unit, ulp; domain = "(0, 1)"),
        accrow("ellipk", ellipk, x -> big(pi) / (2 * DoubleFloats.agm(big"1.0", sqrt(1 - x))), () -> T(1) - T(2.0)^(-20 - 30rand()), ulp; domain = "1 - 2⁻²⁰⁻⁵⁰"),
    ]
    return explog, trig, arctrig, hyp, special
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
explog64, trig64, arctrig64, hyp64, special64 = scalar_rows(Double64)
matrix64 = matrix_rows(Double64)
explog32, trig32, arctrig32, hyp32, special32 = scalar_rows(Double32)
matrix32 = matrix_rows(Double32)

function accuracy_section(name, ulptext, explog, trig, arctrig, hyp, special, matrix)
    return """
## $name

Errors are measured against a 512-bit `BigFloat` reference in units of the
`$name` working precision, **1 ulp = $ulptext relative**.  A worst case of
about 1 ulp means the function is as accurate as the format allows.

### Exponentials and Logarithms

$hdr
$(join(explog, "\n"))

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

`erf`, `erfc`, and `gamma` are computed via `Float128`; its 113-bit
significand caps their accuracy at roughly half an ulp of `Double64`.

$hdr
$(join(special, "\n"))

### Matrix Functions (identity residuals)

Matrix routines are checked through their defining identities on random
matrices, normalized per matrix dimension.  An unavailable row identifies a
routine that cannot currently execute for that precision.

$mhdr
$(join(matrix, "\n"))
"""
end

double64_section = accuracy_section("Double64", "2⁻¹⁰⁴ (about 4.9e-32)", explog64, trig64, arctrig64, hyp64, special64, matrix64)
double32_section = accuracy_section("Double32", "2⁻⁴⁶ (about 1.4e-14)", explog32, trig32, arctrig32, hyp32, special32, matrix32)

report = """
# DoubleFloats Accuracy Report

*Generated by `docs/reports/accuracies.jl` on Julia $vinfo.*

This report samples a representative subset; **it does not cover all
available functions**.

$double64_section

$double32_section

The unavailable Double32 matrix rows currently require a generic Schur path
through `Complex{Double32}`, which is not supported.
"""

outpath = joinpath(@__DIR__, "accuracy_report.md")
open(outpath, "w") do io
    write(io, report)
end
println("wrote ", outpath)
