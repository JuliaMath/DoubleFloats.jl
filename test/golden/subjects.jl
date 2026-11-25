# The golden corpus: what is evaluated, on which inputs, and how results are
# reduced to checksums. Used by `generate.jl` to record and by `../golden.jl`
# to compare. It must run unchanged on every revision it is asked to compare,
# so it uses only exported names and `simdmap!`.
#
# Requires `SplitMix64`, `next!`, `unitfloat!` from `../support/splitmix.jl`.

using CRC32c: crc32c
using LinearAlgebra

const GOLDEN_TYPES = (Double64, Double32, Double16)
const GOLDEN_BLOCK = 256

wordtype(::Type{DoubleFloat{F}}) where {F} = F

# ---------------------------------------------------------------------------
# Inputs. Pairs are built from words directly and satisfy hi == RN(hi + lo),
# so they do not depend on the package's arithmetic or on whether its pair
# constructor normalizes.

# A low word no larger than a quarter of the spacing at `hi`, scaled down by
# 2^-shift. Zero when `hi` is zero or not finite, or when the word underflows.
function lowword(hi::F, fraction::Float64, shift::Int) where {F}
    (isfinite(hi) && !iszero(hi)) || return zero(F)
    # Computed in Float64 and converted once. `ldexp` on a subnormal Float32
    # is not used: its result differs between Julia 1.12 and 1.13.
    lo = F(fraction * Float64(eps(hi)) / 4 * exp2(-shift))
    return (hi + lo == hi) ? lo : zero(F)
end

pair(::Type{T}, hi, lo) where {T} = T(wordtype(T)(hi), wordtype(T)(lo))

const STRUCTURED_HEADS = let
    heads = Float64[0.0, -0.0, Inf, -Inf, NaN, pi, exp(1.0), 0.1, 1 / 3, 10.0, 100.0, 1.0e-5, 1.0e5]
    append!(heads, ldexp(1.0, k) for k in -12:12)
    # Magnitudes at or near where the package changes route.
    for v in (
        0.005,
        0.045,
        0.09817477042468103,
        0.25,
        0.36,
        0.5,
        0.75,
        1.0,
        1.5,
        2.0,
        3.0,
        5.0,
        6.28125,
        8.0,
        11.0,
        16.0,
        32.0,
        64.0,
        88.0,
        89.0,
        709.0,
        710.0,
        745.0,
    )
        append!(heads, (prevfloat(v), v, nextfloat(v)))
    end
    vcat(heads, -heads[6:end])
end

function structured(::Type{T}) where {T}
    F = wordtype(T)
    xs = T[]
    for h in STRUCTURED_HEADS
        hi = F(h)
        for (fraction, shift) in ((0.0, 0), (0.9, 0), (-0.9, 0), (0.7, 20))
            push!(xs, pair(T, hi, lowword(hi, fraction, shift)))
        end
    end
    for hi in (
        floatmin(F),
        -floatmin(F),
        nextfloat(zero(F)),
        floatmax(F),
        -floatmax(F),
        floatmax(F) / 2,
        eps(F),
        prevfloat(one(F)),
        nextfloat(one(F)),
    )
        push!(xs, pair(T, hi, lowword(hi, 0.0, 0)))
        push!(xs, pair(T, hi, lowword(hi, 0.6, 0)))
    end
    return xs
end

# One pseudo-random pair with |hi| in 2^[-range, range].
function randompair(::Type{T}, g::SplitMix64, range::Int) where {T}
    F = wordtype(T)
    mantissa = 1.0 + unitfloat!(g)
    exponent = round(Int, (2 * unitfloat!(g) - 1) * range)
    sign = next!(g) % Bool ? -1.0 : 1.0
    hi = F(sign * ldexp(mantissa, exponent))
    fraction = 2 * unitfloat!(g) - 1
    shift = (0, 0, 0, 1, 3, 9, 30, 0)[1 + next!(g) % 8]
    return pair(T, hi, lowword(hi, fraction, shift))
end

function randoms(::Type{T}, seed::Integer) where {T}
    F = wordtype(T)
    g = SplitMix64(seed)
    top = exponent(floatmax(F))
    xs = T[]
    for range in (3, min(40, top ÷ 2), (9 * top) ÷ 10)
        append!(xs, randompair(T, g, range) for _ in 1:1024)
    end
    for _ in 1:1024                       # linear in [-8, 8]
        hi = F(16 * unitfloat!(g) - 8)
        push!(xs, pair(T, hi, lowword(hi, 2 * unitfloat!(g) - 1, 0)))
    end
    return xs
end

scalarinputs(::Type{T}) where {T} = vcat(structured(T), randoms(T, 0x0d0f10a7))

# Dense vectors in ranges where batch kernels admit whole blocks.
const BATCH_RANGES = ((0.005, 0.045), (0.05, 0.3), (0.3, 1.0), (1.0, 6.0), (6.0, 80.0), (-1.0, 1.0), (-6.0, 6.0))

function batchinputs(::Type{T}) where {T}
    F = wordtype(T)
    g = SplitMix64(0x0ba7c4)
    xs = T[]
    for (a, b) in BATCH_RANGES, _ in 1:512
        hi = F(a + (b - a) * unitfloat!(g))
        push!(xs, pair(T, hi, lowword(hi, 2 * unitfloat!(g) - 1, 0)))
    end
    return xs
end

# ---------------------------------------------------------------------------
# Reduction of a result to bytes. NaN has one encoding whatever its sign or
# payload, and the low word of a non-finite value is not recorded: neither is
# specified, and NaN signs differ between processors.

function emit(io::IO, y::Base.IEEEFloat)
    if isnan(y)
        write(io, "NaN")
    else
        write(io, reinterpret(Unsigned, y))
    end
end
function emit(io::IO, y::DoubleFloat)
    emit(io, HI(y))
    isfinite(HI(y)) && emit(io, LO(y))
end
emit(io::IO, y::Bool) = write(io, y ? 0x01 : 0x00)
emit(io::IO, y::Base.BitInteger) = write(io, Int128(y))
emit(io::IO, y::Complex) = (emit(io, real(y)); emit(io, imag(y)))
emit(io::IO, y::Union{Tuple,AbstractArray}) = foreach(v -> emit(io, v), y)
emit(io::IO, y::AbstractString) = write(io, y)
# The exact value, independent of precision and of how Julia prints it.
function emit(io::IO, y::BigFloat)
    isfinite(y) || return write(io, isnan(y) ? "NaN" : y > 0 ? "Inf" : "-Inf")
    iszero(y) && return write(io, signbit(y) ? "-0" : "0")
    significand, power, sign = Base.decompose(y)
    shift = trailing_zeros(significand)
    write(io, string(sign * (significand >> shift)), "p", string(power + shift))
end
emit(io::IO, y) = write(io, string(y))             # BigInt, Rational, types, nothing

function attempt(f, args...)
    try
        return f(args...)
    catch err
        return string("throws ", nameof(typeof(err)))
    end
end

# Checksums, one per block of results.
function digests(results::AbstractVector)
    out = String[]
    for start in 1:GOLDEN_BLOCK:length(results)
        io = IOBuffer()
        for i in start:min(start + GOLDEN_BLOCK - 1, length(results))
            emit(io, results[i])
            write(io, 0xff)
        end
        push!(out, string(crc32c(take!(io)); base = 16, pad = 8))
    end
    return out
end

# ---------------------------------------------------------------------------
# Subjects.

const UNARY = (
    :exp,
    :exp2,
    :exp10,
    :expm1,
    :log,
    :log2,
    :log10,
    :log1p,
    :sin,
    :cos,
    :tan,
    :cot,
    :sincos,
    :sinpi,
    :cospi,
    :tanpi,
    :asin,
    :acos,
    :atan,
    :acsc,
    :asec,
    :acot,
    :sinh,
    :cosh,
    :tanh,
    :csch,
    :sech,
    :coth,
    :asinh,
    :acosh,
    :atanh,
    :acsch,
    :asech,
    :acoth,
    :sqrt,
    :cbrt,
    :inv,
    :abs,
    :abs2,
    :-,
    :square,
    :cube,
    :floor,
    :ceil,
    :trunc,
    :round,
    :modf,
    :intpart,
    :fracpart,
    :significand,
    :exponent,
    :eps,
    :ulp,
    :nextfloat,
    :prevfloat,
    :sign,
    :signbit,
    :iszero,
    :isone,
    :isnan,
    :isinf,
    :isfinite,
    :isinteger,
    :issubnormal,
    :Float64,
    :Float32,
    :BigFloat,
    :string,
)

const BINARY = (:+, :-, :*, :/, :^, :hypot, :atan, :rem, :mod, :min, :max, :(==), :<, :<=, :isless, :isequal)

const COMPLEX_UNARY = (:exp, :log, :sqrt, :sin, :cos, :tan, :sinh, :cosh, :tanh, :asin, :acos, :atan, :abs, :inv)

const BATCH_UNARY = (
    :exp,
    :exp2,
    :exp10,
    :expm1,
    :log,
    :log2,
    :log10,
    :log1p,
    :sin,
    :cos,
    :tan,
    :atan,
    :sinh,
    :cosh,
    :tanh,
    :asinh,
    :acosh,
    :atanh,
    :sqrt,
)

resolve(name::Symbol) = isdefined(Base, name) ? getfield(Base, name) : getfield(DoubleFloats, name)

roundtrip(x::T) where {T} = parse(T, string(x))
fromwords(x::T) where {T} = T(BigFloat(HI(x)) + BigFloat(LO(x)))

# A subject is a key, the argument tuples it is evaluated on, and a thunk that
# returns one result per tuple.
struct Subject
    key::String
    arguments::Vector{Any}
    results::Function
end

each(f, arguments) = Subject("", collect(Any, arguments), () -> Any[attempt(f, a...) for a in arguments])
named(key, s::Subject) = Subject(key, s.arguments, s.results)

# A subject whose result is one array, recorded element by element.
function whole(f, args...)
    arguments = Any[args]
    results = function ()
        r = attempt(f, args...)
        return r isa AbstractArray ? collect(Any, vec(r)) : Any[r]
    end
    return Subject("", arguments, results)
end

function matrixsubjects!(list, ::Type{T}, key) where {T}
    g = SplitMix64(0x3a7)
    F = wordtype(T)
    entry() = (hi = F(2 * unitfloat!(g) - 1); pair(T, hi, lowword(hi, 2 * unitfloat!(g) - 1, 0)))
    # Matrix results pass through LinearAlgebra, whose generic kernels change
    # between Julia versions. Products of 2x2 matrices (different on Julia
    # 1.12) and matrix-vector products (different from Julia 1.14) are left
    # out for that reason; what is kept agrees on Julia 1.12, 1.13, and 1.15.
    for n in (5, 8)
        A = [entry() for _ in 1:n, _ in 1:n]
        B = [entry() for _ in 1:n, _ in 1:n]
        push!(list, named(string("matmul", n, "/", key), whole(*, A, B)))
        push!(list, named(string("matexp", n, "/", key), whole(exp, A)))
    end
    return list
end

"""
    subjects() -> Vector{Subject}

Everything the corpus records, keyed by `"subject/type"`.
"""
function subjects()
    list = Subject[]
    for T in GOLDEN_TYPES
        key = string("Double", 8 * sizeof(wordtype(T)))
        add(name, s) = push!(list, named(string(name, "/", key), s))
        xs = scalarinputs(T)
        ys = circshift(xs, 1)
        zs = reverse(xs)
        for name in UNARY
            add(name, each(resolve(name), tuple.(xs)))
        end
        add("roundtrip", each(roundtrip, tuple.(xs)))
        add("fromwords", each(fromwords, tuple.(xs)))
        for name in BINARY
            f = resolve(name)
            add(string(name, "2"), each(f, collect(zip(xs, ys))))
            add(string(name, "2r"), each(f, collect(zip(xs, zs))))
            add(string(name, "2word"), each(f, [(x, HI(y)) for (x, y) in zip(xs, ys)]))
            add(string(name, "2int"), each(f, [(x, 3) for x in xs]))
        end
        add("fma", each(fma, collect(zip(xs, ys, zs))))
        add("fromint", each(T, tuple.((0, 1, -1, 7, 2^24 + 1, 2^53 + 1, 2^62 + 1, typemax(Int64), typemin(Int64)))))
        T === Double16 && continue
        cs = [complex(x, y) for (x, y) in zip(xs, ys)]
        for name in COMPLEX_UNARY
            # Complex square root of Double64 is computed by libquadmath, whose
            # result on ARM macOS with Julia 1.12.0 differs from every other
            # platform and version tested. It is not recorded.
            (name === :sqrt && T === Double64) && continue
            add(string("complex", name), each(resolve(name), tuple.(cs)))
        end
        vs = batchinputs(T)
        for name in BATCH_UNARY
            f = resolve(name)
            add(string("batch", name), whole((v) -> DoubleFloats.simdmap!(f, similar(v), v), vs))
        end
        matrixsubjects!(list, T, key)
    end
    return list
end

"""
    golden() -> Dict{String,Vector{String}}

Evaluate every subject and return its block checksums.
"""
golden() = Dict(s.key => digests(s.results()) for s in subjects())
