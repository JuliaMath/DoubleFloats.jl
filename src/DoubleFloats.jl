__precompile__()

module DoubleFloats

export Double, FastDouble,
       Emphasis, Accuracy, Performance,
       MultipartFloat, HI, LO, HILO,
       isnonzero, ispos, isneg, isnonpos, isnonneg,
       isposinf, isneginf, isfractional,
       nan, inf,
       intpart, fracpart, fmod,
       square, cube,
       #spread, sld, tld,
       #signs

if VERSION >= v"0.7.0-"
    import Base: IEEEFloat, isone
    using Base.MathConstants: pi, golden, ℯ, eulergamma, catalan
else
    const IEEEFloat = Union{Float64, Float32, Float16}
    export isone
end


if isdefined(Base, :stdout)
    import Base: stdout
    const StdOutStream = Base.stdout
else
    import Base: STDOUT
    const StdOutStream = Base.STDOUT
end


import Base: hash, promote_type, promote_rule, convert,
             string, show, parse,
             (+), (-), (*), (/), (\), (^), abs, inv, sqrt, cbrt,
             (==), (!=), (<), (<=), (>=), (>), isequal, isless,
             iszero, isinf, isnan, isinf, isfinite, issubnormal,
             isinteger, isodd, iseven, zero, one,
             typemax, typemin, realmax, realmin,
             min, max, minmax, minimum, maximum,
             floor, ceil, trunc, round, div, fld, cld, rem, mod,
             prevfloat, nextfloat, eps, fma, muladd,
             modf, frexp, ldexp, sqrt, cbrt, hypot,
             log, exp, log1p, expm1, log2, log10,
             sin, cos, tan, csc, sec, cot, sincos, sinpi, cospi,
             asin, acos, atan, acsc, asec, acot,
             sinh, cosh, tanh, csch, sech, coth,
             asinh, acosh, atanh, acsch, asech, acoth,
             muladd, fma



using AccurateArithmetic

abstract type MultipartFloat{T} <: AbstractFloat end

include("Emphasis.jl") # Accuracy, Performance
include("Double.jl")   # Double, FastDouble

include("type/promote.jl")
include("type/constructors.jl")
include("type/predicates.jl")
include("type/compare.jl")
include("type/values.jl")

include("buildingblocks/double.jl")
include("buildingblocks/triple.jl")

include("support/maxmin.jl")

include("ops/fma.jl")
include("ops/prelims.jl")
include("ops/op.jl")
include("ops/floorceil.jl")
include("ops/intfrac.jl")

include("math/sequences.jl")

include("math/explog.jl")
include("math/trig.jl")
include("math/arctrig.jl")
include("math/trigh.jl")
include("math/arctrigh.jl")
include("math/moremath.jl")

include("support/random.jl")

end # module DoubleFloats
