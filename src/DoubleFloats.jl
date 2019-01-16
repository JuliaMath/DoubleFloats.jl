"""
    DoubleFloats

A package for extended precision floating point math.

exported types: `Double64`, `Double32`, `Double16`
"""
module DoubleFloats

abstract type MultipartFloat <: AbstractFloat end

export DoubleFloat,
       Double64, Double32, Double16,
       @d64_str, @d32_str, @d16_str,
       MultipartFloat, HI, LO, HILO,
       stringtyped, showtyped,
       isnonzero, ispositive, isnegative, isnonpositive, isnonnegative,
       isposinf, isneginf, isfractional, isnormal,
       nan, inf, posinf, neginf,
       ulp,
       intpart, fracpart, fmod,
       square, cube,
       add2, sub2, mul2, div2,
       ⊕, ⊖, ⊗, ⊘
       #spread, sld, tld,
       #signs

using Base.MathConstants: pi, golden, ℯ, eulergamma, catalan

using LinearAlgebra
using Polynomials

# using LinearAlgebra
import Base: hash, promote_type, promote_rule, convert,
             string, show, parse, eltype,
             signbit, sign, abs, flipsign, copysign,
             significand, exponent, precision, widen,
             (+), (-), (*), (/), (\), (^), inv, sqrt, cbrt,
             (==), (!=), (<), (<=), (>=), (>), isequal, isless,
             IEEEFloat, iszero, isone, isinf, isnan, isinf, isfinite, issubnormal,
             isinteger, isodd, iseven, zero, one,
             typemax, typemin, floatmax, floatmin, maxintfloat,
             min, max, minmax, minimum, maximum,
             floor, ceil, trunc, round, div, fld, cld,
             rem, mod, rem2pi, mod2pi, divrem, fldmod,
             prevfloat, nextfloat, eps, fma, muladd,
             modf, frexp, ldexp, sqrt, cbrt, hypot,
             log, exp, log1p, expm1, log2, log10,
             sin, cos, tan, csc, sec, cot, sincos, sinpi, cospi,
             asin, acos, atan, acsc, asec, acot,
             sinh, cosh, tanh, csch, sech, coth,
             asinh, acosh, atanh, acsch, asech, acoth,
             BigFloat, BigInt,
             Int8, Int16, Int32, Int64, Int128,
             Float64, Float32, Float16

# import LinearAlgebra: normalize
using Random

using AccurateArithmetic

include("Double.jl")   # Double64, Double32, Double16

include("doubletriple/double.jl")
include("doubletriple/double_consts.jl")
include("doubletriple/triple.jl")
include("doubletriple/triple_consts.jl")
include("doubletriple/triple_pi.jl")

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
include("math/prearith/divrem.jl")

include("math/arithmetic/fma.jl")
include("math/arithmetic/modpi.jl")
include("math/arithmetic/normalize_hypot.jl")
include("math/arithmetic/mixedarith.jl")
include("math/ops.jl")

include("math/elementary/sequences.jl")
include("math/elementary/explog.jl")
include("math/elementary/trig.jl")
include("math/elementary/arctrig.jl")
include("math/elementary/hyptrig.jl")
include("math/elementary/archyptrig.jl")
include("math/elementary/templated.jl")

include("extras/random.jl")


end # module DoubleFloats
