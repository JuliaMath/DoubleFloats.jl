# Generates benchmark_report.md (in this directory).
#
# Run from anywhere:  julia docs/reports/benchmarks.jl
# No dependencies beyond the package itself; timings use best-of-trials
# amortized loops rather than BenchmarkTools, so the numbers are indicative
# rather than rigorous.  Not every exported function is measured.

import Pkg
Pkg.activate(joinpath(@__DIR__, "..", ".."))

using DoubleFloats, LinearAlgebra, Random, Printf

Random.seed!(20260718)

# ---------------------------------------------------------------- timing --

const SINK = Ref(0.0)   # keeps results live so work is not elided

"""
    nsper(f, iters; trials) -> nanoseconds per call of f()

`f` should perform one unit of work and return a number, which is accumulated
into SINK.  Best (minimum) of `trials` amortized loops.
"""
function nsper(f::F, iters::Int; trials::Int = 9) where {F<:Function}
    s = 0.0
    best = Inf
    for _ in 1:trials
        t0 = time_ns()
        for _ in 1:iters
            s += Float64(f())
        end
        best = min(best, (time_ns() - t0) / iters)
    end
    SINK[] += s
    return best
end

fmt(ns) = ns < 1000 ? @sprintf("%.0f ns", ns) :
          ns < 1e6  ? @sprintf("%.2f µs", ns/1e3) :
                      @sprintf("%.2f ms", ns/1e6)

ratio(a, b) = @sprintf("%.1f", a / b)

# ------------------------------------------------------- scalar sections --

# Vectors of positive test points, identical values across precision sections.
const NPTS = 1000
xs64  = rand(NPTS) .* 2 .+ 0.25          # (0.25, 2.25): in-domain everywhere
xsB   = BigFloat.(xs64)                  # default 256-bit precision
ys64  = rand(NPTS) .* 2 .+ 0.25
ysB   = BigFloat.(ys64)

# time `op` mapped across the sample vectors; returns ns per element
function mapbench(op::F, xs) where {F<:Function}
    work = () -> begin
        s = 0.0
        for x in xs
            s += Float64(op(x))
        end
        s
    end
    return nsper(work, 20) / NPTS
end

function mapbench2(op::F, xs, ys) where {F<:Function}
    work = () -> begin
        s = 0.0
        for i in eachindex(xs)
            s += Float64(op(xs[i], ys[i]))
        end
        s
    end
    return nsper(work, 20) / NPTS
end

function scalar_row(T, baseT, name, op1, op2 = nothing)
    xs = T.(xs64); ys = T.(ys64)
    xbase = baseT.(xs64); ybase = baseT.(ys64)
    if op2 === nothing
        d = mapbench(op1, xs); f = mapbench(op1, xbase); b = mapbench(op1, xsB)
    else
        d = mapbench2(op2, xs, ys); f = mapbench2(op2, xbase, ybase); b = mapbench2(op2, xsB, ysB)
    end
    return "| `$name` | $(fmt(d)) | $(fmt(f)) | $(ratio(d, f))x | $(fmt(b)) | $(ratio(b, d))x |"
end

function scalar_rows(T, baseT)
    arith = [
        scalar_row(T, baseT, "+",    nothing, +),
        scalar_row(T, baseT, "*",    nothing, *),
        scalar_row(T, baseT, "/",    nothing, /),
        scalar_row(T, baseT, "sqrt", sqrt),
        scalar_row(T, baseT, "abs",  abs),
        scalar_row(T, baseT, "fma",  nothing, (x, y) -> fma(x, y, x)),
    ]

    elementary = [
        scalar_row(T, baseT, "exp",   exp),
        scalar_row(T, baseT, "log",   log),
        scalar_row(T, baseT, "sin",   sin),
        scalar_row(T, baseT, "cos",   cos),
        scalar_row(T, baseT, "tan",   tan),
        scalar_row(T, baseT, "atan",  atan),
        scalar_row(T, baseT, "sinh",  sinh),
        scalar_row(T, baseT, "tanh",  tanh),
        scalar_row(T, baseT, "asinh", asinh),
        scalar_row(T, baseT, "x^y",   nothing, ^),
    ]
    return arith, elementary
end

# ------------------------------------------------------- linear algebra --

n = 32
A0 = rand(n, n) .- 0.5
B0 = rand(n, n) .- 0.5
S0 = A0 + transpose(A0)
P0 = S0 * transpose(S0)          # symmetric positive definite
b0 = rand(n)

# make(T) builds the typed operands once and returns a zero-argument
# closure that does the work and reduces to a real scalar
function la_row(T, baseT, name, make::F; iters::Int = 3) where {F<:Function}
    d = nsper(make(T), iters, trials = 5)
    f = nsper(make(baseT), iters, trials = 5)
    return "| `$name` | $(fmt(d)) | $(fmt(f)) | $(ratio(d, f))x |"
end

"""
    matmul_row(n) -> markdown table row

Benchmark dense square matrix multiplication at size `n`.  The operands are
constructed outside the timed closure so the measurement covers multiplication
and the reduction that keeps its result live.
"""
function matmul_row(T, baseT, n::Int)
    a = rand(n, n) .- 0.5
    b = rand(n, n) .- 0.5
    return la_row(T, baseT, "A * B  (n=$n)", T -> begin
        Ad = T.(a)
        Bd = T.(b)
        () -> sum(abs, Ad * Bd)
    end)
end

function linear_rows(T, baseT; include_sylvester::Bool = true)
    matmul = [matmul_row(T, baseT, n) for n in (4, 8, 16, 32, 64)]
    la = [
        matmul...,
        la_row(T, baseT, "lu(A)",               T -> (Ad = T.(A0); () -> sum(abs, lu(Ad).factors))),
        la_row(T, baseT, "qr(A)",               T -> (Ad = T.(A0); () -> sum(abs, qr(Ad).factors))),
        la_row(T, baseT, "A \\ b",              T -> (Ad = T.(A0); bd = T.(b0); () -> sum(abs, Ad \ bd))),
        la_row(T, baseT, "eigen(S)  symmetric", T -> (Sd = T.(S0); () -> sum(abs, eigen(Sd).values))),
        la_row(T, baseT, "eigen(A)  general",   T -> (Ad = T.(A0); () -> sum(abs, eigen(Ad).values))),
        la_row(T, baseT, "svd(A)",              T -> (Ad = T.(A0); () -> sum(svdvals(Ad)))),
    ]
    mf = [
        la_row(T, baseT, "exp(A)   (n=32)",     T -> (Ad = T.(A0); () -> sum(abs, exp(Ad)))),
        la_row(T, baseT, "sqrt(P)  spd",        T -> (Pd = T.(P0); () -> sum(abs, sqrt(Pd)))),
        la_row(T, baseT, "log(P)   spd",        T -> (Pd = T.(P0); () -> sum(abs, log(Pd)))),
    ]
    if include_sylvester
        push!(mf, la_row(T, baseT, "sylvester(A, B, S)",
                         T -> (Ad = T.(A0); Bd = T.(B0); Sd = T.(S0); () -> sum(abs, sylvester(Ad, Bd, Sd)))))
    else
        push!(mf, "| `sylvester(A, B, S)` | unavailable | unavailable | — |")
    end
    return la, mf
end

# ------------------------------------------------------------- assemble --

vinfo = string(VERSION)
arith64, elementary64 = scalar_rows(Double64, Float64)
la64, mf64 = linear_rows(Double64, Float64)
arith32, elementary32 = scalar_rows(Double32, Float32)
la32, mf32 = linear_rows(Double32, Float32)

function precision_section(name, based_name, ratio_name, big_ratio_name,
                           digits, arith, elementary, la, mf)
    return """
## $name

`$name` carries ~$digits significant decimal digits.  `$based_name` is the
native baseline; `BigFloat` timings use the default 256-bit precision.

### Scalar Arithmetic

| operation | $name | $based_name | $ratio_name | BigFloat | $big_ratio_name |
|:----------|---------:|--------:|--------:|---------:|--------:|
$(join(arith, "\n"))

### Elementary Functions

| function | $name | $based_name | $ratio_name | BigFloat | $big_ratio_name |
|:---------|---------:|--------:|--------:|---------:|--------:|
$(join(elementary, "\n"))

### Linear Algebra

`$based_name` timings use LAPACK/BLAS; `$name` uses pure-Julia generic
algorithms (GenericLinearAlgebra / GenericSchur), so these ratios combine the
precision cost with the loss of BLAS blocking and SIMD.  Matrix multiplication
is measured at several square sizes; the remaining operations use n = 32.

| operation | $name | $based_name | $ratio_name |
|:----------|---------:|--------:|--------:|
$(join(la, "\n"))

### Matrix Functions (n = 32 unless noted)

| operation | $name | $based_name | $ratio_name |
|:----------|---------:|--------:|--------:|
$(join(mf, "\n"))
"""
end

double64_section = precision_section(
    "Double64", "Float64", "D64/F64", "Big/D64", "32", arith64, elementary64, la64, mf64)
double32_section = precision_section(
    "Double32", "Float32", "D32/F32", "Big/D32", "14", arith32, elementary32, la32, mf32)

report = """
# DoubleFloats Benchmark Report

*Generated by `docs/reports/benchmarks.jl` on Julia $vinfo.*

This report covers a representative sample of operations; **it does not
cover all available functions**.  Timings are best-of-trials amortized
averages on the machine that ran the script — treat them as indicative
magnitudes, not precise measurements.

$double64_section

$double32_section

## Notes

- Entries below ~10 ns are at the resolution of the timing loop; treat
  them (and their ratios) as "too fast to matter" rather than exact.
- `Double64` and `Double32` values are immutable bitstypes; vectors of them are stored
  inline, which is where much of the advantage over `BigFloat` comes from.
- Matrix-function timings include the full dense algorithm
  (scaling-and-squaring for `exp`, Schur-based methods for `sqrt`/`log`).
- The `Double32` Sylvester row is unavailable: its generic Schur path currently
  fails for `Complex{Double32}`, so reporting a timing would be misleading.
"""

outpath = joinpath(@__DIR__, "benchmark_report.md")
open(outpath, "w") do io
    write(io, report)
end
println("wrote ", outpath)
