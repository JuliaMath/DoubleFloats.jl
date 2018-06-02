__precompile__()

module DoubleFloats

abstract type MultipartFloat <: AbstractFloat end

export DoubleFloat,
       DoubleF64, DoubleF32, DoubleF16,
       MultipartFloat, HI, LO, HILO,
       typedstring, showtyped,
       isnonzero, ispos, isneg, isnonpos, isnonneg,
       isposinf, isneginf, isfractional,
       nan, inf, posinf, neginf,
       intpart, fracpart, fmod,
       square, cube
       #spread, sld, tld,
       #signs

if VERSION >= v"0.7.0-"
    import Base: IEEEFloat, isone
    using Base.MathConstants: pi, golden, ℯ, eulergamma, catalan
else
    const IEEEFloat = Union{Float64, Float32, Float16}
    export isone
end

# using LinearAlgebra
import Base: hash, promote_type, promote_rule, convert,
             string, show, parse,
             signbit, sign, abs, flipsign, copysign,
             (+), (-), (*), (/), (\), (^), inv, sqrt, cbrt,
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
             asinh, acosh, atanh, acsch, asech, acoth

# import LinearAlgebra: normalize
using Random

using AccurateArithmetic

include("Double.jl")   # DoubleF64, DoubleF16, DoubleF16 

include("doubletriple/double.jl")
include("doubletriple/triple.jl")

include("type/constructors.jl")
include("type/promote.jl")
include("type/convert.jl")
include("type/compare.jl")
include("type/predicates.jl")
include("type/specialvalues.jl")
include("type/string.jl")
include("type/show.jl")
include("type/parse.jl")



include("math/prearith/prearith.jl")
include("math/prearith/floorceiltrunc.jl")
include("math/arithmetic/fma.jl")
include("math/arithmetic/normalize_hypot.jl")
include("math/ops.jl")

include("math/elementary/sequences.jl")
include("math/elementary/explog.jl")
include("math/elementary/trig.jl")
include("math/elementary/arctrig.jl")
include("math/elementary/hyptrig.jl")
include("math/elementary/archyptrig.jl")

include("extras/random.jl")


end # module DoubleFloats
