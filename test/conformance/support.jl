# Properties of the Base contract (docs/apothecary.md §3 to §5, §9).
#
# Each property has a key. A key listed in broken.txt names a property the
# package does not yet satisfy: its test is recorded as broken, not failed. A
# fix removes the key in the same commit; a listed property that starts to
# pass is reported as an error, so the list cannot go stale. A stage of the
# 2.0 plan is complete when its keys are gone from the list.
#
# To rebuild the list from the present behaviour:
#
#     CONFORMANCE_RECORD=1 julia --project=. test/runtests.jl

const CONFORMANCE_BROKEN = Set(filter(!isempty, readlines(joinpath(@__DIR__, "broken.txt"))))
const CONFORMANCE_RECORD = get(ENV, "CONFORMANCE_RECORD", "") == "1"
const CONFORMANCE_FAILED = String[]

function property(f, key::AbstractString)
    # Some of the defects under test change the global BigFloat precision.
    # Restore it, so that one property cannot disturb the tests that follow.
    saved = precision(BigFloat)
    result = try
        f()
    catch err
        err
    finally
        setprecision(BigFloat, saved)
    end
    if CONFORMANCE_RECORD
        result === true || push!(CONFORMANCE_FAILED, key)
        return @test true
    end
    broken = key in CONFORMANCE_BROKEN
    (result === true) == broken &&
        println("conformance: ", key, broken ? " now holds; remove it from broken.txt" : " fails")
    return @test result === true broken = broken
end

# Whether calling `f` throws an exception of type `E`.
function throws(f, E)
    try
        f()
    catch err
        return err isa E
    end
    return false
end

const CONFORMANCE_TYPES = (Double64, Double32, Double16)
typename(::Type{DoubleFloat{F}}) where {F} = string("Double", 8 * sizeof(F))
wordof(::Type{DoubleFloat{F}}) where {F} = F

# A pair built from its words and satisfying hi == RN(hi + lo), whatever the
# public constructor does with its arguments.
function words(::Type{T}, hi, lo) where {T}
    F = wordof(T)
    x = T(F(hi))
    iszero(lo) && return x
    y = T(F(hi), F(lo))
    @assert HI(y) + LO(y) == HI(y) "not a normalized pair"
    return y
end

# The exact value of a finite pair.
exact(x::DoubleFloat) = Rational{BigInt}(HI(x)) + Rational{BigInt}(LO(x))
exact(x::Union{AbstractFloat,Integer,Rational}) = Rational{BigInt}(x)

# What ==, <, isequal, isless must return, from exact values.
isnanlike(x) = x isa DoubleFloat ? isnan(HI(x)) : (x isa AbstractFloat && isnan(x))
isinflike(x) = x isa DoubleFloat ? isinf(HI(x)) : (x isa AbstractFloat && isinf(x))
negative(x) = x isa DoubleFloat ? signbit(HI(x)) : signbit(x)
# Position on the extended real line: -Inf, finite, +Inf.
rank(x) = isinflike(x) ? (negative(x) ? -1 : 1) : 0

function refeq(a, b)
    (isnanlike(a) || isnanlike(b)) && return false
    rank(a) == rank(b) || return false
    return rank(a) != 0 || exact(a) == exact(b)
end
function reflt(a, b)
    (isnanlike(a) || isnanlike(b)) && return false
    rank(a) != rank(b) && return rank(a) < rank(b)
    return rank(a) == 0 && exact(a) < exact(b)
end
refisequal(a, b) =
    isnanlike(a) || isnanlike(b) ? (isnanlike(a) && isnanlike(b)) : (refeq(a, b) && negative(a) == negative(b))
function refisless(a, b)
    isnanlike(a) && return false
    isnanlike(b) && return true
    reflt(a, b) && return true
    return refeq(a, b) && negative(a) && !negative(b)      # -0.0 before 0.0
end

# Values that exercise the order: zeros, neighbours, extremes, non-finite.
function ordervalues(::Type{T}) where {T}
    F = wordof(T)
    third = words(T, F(1) / 3, 0)
    xs = T[
        words(T, 0, 0),
        words(T, -0.0, 0),
        words(T, 1, 0),
        words(T, -1, 0),
        words(T, 1, eps(F) / 4),
        words(T, 1, -eps(F) / 8),
        words(T, 1, eps(F) / 8),
        words(T, F(1) / 3, eps(F(1) / 3) / 4),
        third,
        words(T, 2, 0),
        words(T, 0.5, 0),
        words(T, floatmax(F), 0),
        words(T, -floatmax(F), 0),
        words(T, floatmin(F), 0),
        words(T, nextfloat(zero(F)), 0),
        T(F(Inf)),
        T(F(-Inf)),
        T(F(NaN)),
    ]
    push!(xs, floatmax(T) * 2)           # the other stored form of infinity
    return xs
end
