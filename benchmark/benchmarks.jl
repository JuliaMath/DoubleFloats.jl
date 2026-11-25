# The regression suite. It defines `SUITE`, in the layout PkgBenchmark and
# AirspeedVelocity expect, and uses only names that exist in every version it
# is asked to compare. Each benchmark is a loop over a vector, so one
# evaluation takes microseconds and needs no tuning.
#
# To compare two versions on this machine, see compare.jl.

using BenchmarkTools
using DoubleFloats
using LinearAlgebra

const SUITE = BenchmarkGroup()
const N = 1024

# Deterministic inputs that do not depend on Julia's random streams.
function uniform(n, lo, hi, seed)
    state = UInt64(seed)
    out = Vector{Float64}(undef, n)
    for i in 1:n
        state = state * 0x5851f42d4c957f2d + 0x14057b7ef767814f
        out[i] = lo + (hi - lo) * ((state >> 11) * 0x1.0p-53)
    end
    return out
end

function inputs(::Type{T}, lo, hi, seed = 1) where {T}
    heads = uniform(N, lo, hi, seed)
    tails = uniform(N, -1.0, 1.0, seed + 1)
    unit = eps(HI(one(T))) / 4          # keeps the low word within the pair
    return T[T(h) + T(h) * T(t) * unit for (h, t) in zip(heads, tails)]
end

function sumover(f::F, xs) where {F}
    acc = zero(eltype(xs))
    @inbounds for x in xs
        acc += f(x)
    end
    return acc
end

function sumover(f::F, xs, ys) where {F}
    acc = zero(eltype(xs))
    @inbounds for i in eachindex(xs, ys)
        acc += f(xs[i], ys[i])
    end
    return acc
end

function countover(f::F, xs, ys) where {F}
    acc = 0
    @inbounds for i in eachindex(xs, ys)
        acc += f(xs[i], ys[i])
    end
    return acc
end

# Function => the range its inputs are drawn from.
const UNARY = (
    exp => (-5.0, 5.0),
    exp2 => (-5.0, 5.0),
    exp10 => (-3.0, 3.0),
    expm1 => (-0.3, 0.3),
    log => (0.1, 20.0),
    log2 => (0.1, 20.0),
    log10 => (0.1, 20.0),
    log1p => (-0.3, 0.3),
    sin => (-3.0, 3.0),
    cos => (-3.0, 3.0),
    tan => (-1.5, 1.5),
    sinpi => (-1.0, 1.0),
    cospi => (-1.0, 1.0),
    asin => (-0.9, 0.9),
    acos => (-0.9, 0.9),
    atan => (-5.0, 5.0),
    sinh => (-3.0, 3.0),
    cosh => (-3.0, 3.0),
    tanh => (-3.0, 3.0),
    asinh => (-5.0, 5.0),
    acosh => (1.1, 9.0),
    atanh => (-0.9, 0.9),
    sqrt => (0.1, 20.0),
    cbrt => (0.1, 20.0),
    inv => (0.1, 20.0),
    abs => (-5.0, 5.0),
    floor => (-50.0, 50.0),
    round => (-50.0, 50.0),
)

const WIDE = (
    "sin, 10 to 100" => (sin, (10.0, 100.0)),
    "cos, 10 to 100" => (cos, (10.0, 100.0)),
    "exp, -600 to 600" => (exp, (-600.0, 600.0)),
    "log, 1e-200 to 1e200" => (log, (1.0e-200, 1.0e200)),
    "sinh, 100 to 700" => (sinh, (100.0, 700.0)),
)

for T in (Double64, Double32)
    name = string(T)
    group = SUITE[name] = BenchmarkGroup()

    xs = inputs(T, 0.5, 2.0, 11)
    ys = inputs(T, 0.5, 2.0, 13)
    zs = inputs(T, 0.5, 2.0, 17)
    arithmetic = group["arithmetic"] = BenchmarkGroup()
    for f in (+, -, *, /, hypot, min)
        arithmetic[string(f)] = @benchmarkable sumover($f, $xs, $ys)
    end
    arithmetic["fma"] = @benchmarkable begin
        acc = zero($T)
        @inbounds for i in eachindex($xs)
            acc += fma($xs[i], $ys[i], $zs[i])
        end
        acc
    end
    arithmetic["x + Float64"] = @benchmarkable sumover(x -> x + 1.5, $xs)
    arithmetic["x * Float64"] = @benchmarkable sumover(x -> x * 1.5, $xs)
    arithmetic["x ^ 3"] = @benchmarkable sumover(x -> x^3, $xs)
    arithmetic["x ^ y"] = @benchmarkable sumover(^, $xs, $ys)
    arithmetic["sum"] = @benchmarkable sum($xs)
    arithmetic["from words"] = @benchmarkable sumover(x -> $T(HI(x), LO(x)), $xs)

    compare = group["compare"] = BenchmarkGroup()
    for f in (==, <, isless, isequal)
        compare[string(f)] = @benchmarkable countover($f, $xs, $ys)
    end
    compare["sort"] = @benchmarkable sort($xs)
    compare["x < Float64"] = @benchmarkable countover(<, $xs, $(HI.(ys)))

    scalar = group["scalar"] = BenchmarkGroup()
    batch = group["batch"] = BenchmarkGroup()
    for (f, (lo, hi)) in UNARY
        v = inputs(T, lo, hi, 19)
        scalar[string(f)] = @benchmarkable sumover($f, $v)
        dest = similar(v)
        batch[string(f)] = @benchmarkable DoubleFloats.simdmap!($f, $dest, $v)
    end
    for (label, (f, (lo, hi))) in WIDE
        T === Double32 && hi > 80 && continue
        v = inputs(T, lo, hi, 23)
        scalar[label] = @benchmarkable sumover($f, $v)
    end
    scalar["atan(y, x)"] = @benchmarkable sumover(atan, $xs, $ys)
    broadcastdest = similar(xs)
    batch["broadcast exp"] = @benchmarkable $broadcastdest .= exp.($xs)

    text = group["text"] = BenchmarkGroup()
    short = xs[1:64]
    strings = string.(short)
    text["string"] = @benchmarkable foreach(string, $short)
    text["parse"] = @benchmarkable foreach(s -> parse($T, s), $strings)
    text["Float64"] = @benchmarkable sumover(Float64, $xs)
    text["BigFloat"] = @benchmarkable foreach(BigFloat, $short)

    matrices = group["matrix"] = BenchmarkGroup()
    A = reshape(inputs(T, -1.0, 1.0, 29)[1:256], 16, 16)
    B = reshape(inputs(T, -1.0, 1.0, 31)[1:256], 16, 16)
    v = inputs(T, -1.0, 1.0, 37)[1:16]
    matrices["A * B, 16"] = @benchmarkable $A * $B
    matrices["A * v, 16"] = @benchmarkable $A * $v
    matrices["dot, 1024"] = @benchmarkable dot($xs, $ys)
    matrices["exp(A), 8"] = @benchmarkable exp($(A[1:8, 1:8]))
    matrices["lu, 16"] = @benchmarkable lu($A)
    matrices["A \\ v, 16"] = @benchmarkable $A \ $v
end
