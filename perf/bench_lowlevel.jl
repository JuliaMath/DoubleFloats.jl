using Random
using DoubleFloats

try
    using BenchmarkTools
catch err
    error("BenchmarkTools is required to run perf/bench_lowlevel.jl in the active Julia environment")
end

Random.seed!(1)
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1.0
BenchmarkTools.DEFAULT_PARAMETERS.samples = 2000

const N = 1024
const XS = rand(N) .+ 0.5
const YS = rand(N) .* 0.5
const XLO = rand(N) .* eps(Float64)
const YLO = rand(N) .* eps(Float64)
const ZS = rand(N) .+ 0.5
const ZLO = rand(N) .* eps(Float64)
const XT = [(rand() + 0.5, rand() * eps(Float64)) for _ in 1:N]

function bench_two_sum(xs, ys)
    acc = 0.0
    @inbounds for i in eachindex(xs, ys)
        hi, lo = DoubleFloats.two_sum(xs[i], ys[i])
        acc += hi + lo
    end
    acc
end

function bench_two_diff(xs, ys)
    acc = 0.0
    @inbounds for i in eachindex(xs, ys)
        hi, lo = DoubleFloats.two_diff(xs[i], ys[i])
        acc += hi + lo
    end
    acc
end

function bench_two_hilo_sum(xs, ys)
    acc = 0.0
    @inbounds for i in eachindex(xs, ys)
        a = max(xs[i], ys[i])
        b = min(xs[i], ys[i])
        hi, lo = DoubleFloats.two_hilo_sum(a, b)
        acc += hi + lo
    end
    acc
end

function bench_two_prod(xs, ys)
    acc = 0.0
    @inbounds for i in eachindex(xs, ys)
        hi, lo = DoubleFloats.two_prod(xs[i], ys[i])
        acc += hi + lo
    end
    acc
end

function bench_two_inv(xs)
    acc = 0.0
    @inbounds for x in xs
        hi, lo = DoubleFloats.two_inv(x)
        acc += hi + lo
    end
    acc
end

function bench_two_dvi(xs, ys)
    acc = 0.0
    @inbounds for i in eachindex(xs, ys)
        hi, lo = DoubleFloats.two_dvi(xs[i], ys[i])
        acc += hi + lo
    end
    acc
end

function bench_two_sqrt(xs)
    acc = 0.0
    @inbounds for x in xs
        hi, lo = DoubleFloats.two_sqrt(x)
        acc += hi + lo
    end
    acc
end

function bench_inv_dd_dd(xt)
    acc = 0.0
    @inbounds for x in xt
        hi, lo = DoubleFloats.inv_dd_dd(x)
        acc += hi + lo
    end
    acc
end

function bench_fma_dddd(xh, xl, yh, yl, zh, zl)
    acc = 0.0
    @inbounds for i in eachindex(xh)
        z = DoubleFloats.fma(xh[i], xl[i], yh[i], yl[i], zh[i], zl[i])
        acc += DoubleFloats.HI(z) + DoubleFloats.LO(z)
    end
    acc
end

function bench_fma_fpdd(xh, yh, zh, zl)
    acc = 0.0
    @inbounds for i in eachindex(xh)
        z = DoubleFloats.fma(xh[i], yh[i], zh[i], zl[i])
        acc += DoubleFloats.HI(z) + DoubleFloats.LO(z)
    end
    acc
end

function bench_fma_ddfp(xh, xl, yh, yl, zh)
    acc = 0.0
    @inbounds for i in eachindex(xh)
        z = DoubleFloats.fma(xh[i], xl[i], yh[i], yl[i], zh[i])
        acc += DoubleFloats.HI(z) + DoubleFloats.LO(z)
    end
    acc
end

function report(name, benchmarkable)
    trial = run(benchmarkable)
    println(rpad(name, 16), BenchmarkTools.prettytime(median(trial).time))
end

println("Low-level finite-path benchmarks")
report("two_sum", @benchmarkable bench_two_sum($XS, $YS))
report("two_diff", @benchmarkable bench_two_diff($XS, $YS))
report("two_hilo_sum", @benchmarkable bench_two_hilo_sum($XS, $YS))
report("two_prod", @benchmarkable bench_two_prod($XS, $YS))
report("two_inv", @benchmarkable bench_two_inv($XS))
report("two_dvi", @benchmarkable bench_two_dvi($XS, $YS))
report("two_sqrt", @benchmarkable bench_two_sqrt($XS))
report("inv_dd_dd", @benchmarkable bench_inv_dd_dd($XT))
report("fma_dddd", @benchmarkable bench_fma_dddd($XS, $XLO, $YS, $YLO, $ZS, $ZLO))
report("fma_fpdd", @benchmarkable bench_fma_fpdd($XS, $YS, $ZS, $ZLO))
report("fma_ddfp", @benchmarkable bench_fma_ddfp($XS, $XLO, $YS, $YLO, $ZS))
