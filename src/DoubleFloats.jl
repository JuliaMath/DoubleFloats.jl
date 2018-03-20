module DoubleFloats

export MultipartFloat, 
       Emphasis, Accuracy, Performance,
       Double, FastDouble,
       HI, LO, HILO,
       ispos, isneg, isnonpos, isnonneg,
       isnonzero, isposinf, isneginf, isfractional,
       nan, inf,
       intpart, fracpart, fmod,
       square, cube
       #spread, sld, tld,
       #signs

if VERSION >= v"0.7.0-"
    import Base.stdout
    const StdOutStream = Base.stdout
    import Base: IEEEFloat, isone, stdout
    using Base.MathConstants: pi, golden, ℯ, eulergamma, catalan
else
    import Base.STDOUT
    const StdOutStream = Base.STDOUT
    const IEEEFloat = Union{Float64, Float32, Float16}
    export isone
end


import Base: hash, promote_type, promote_rule, convert, string, show, parse,
             (+), (-), (*), (/), (\), (^), abs, inv, sqrt, cbrt,
             (==), (!=), (<), (<=), (>=), (>), isequal, isless,
             iszero, isinf, isnan, isinf, isfinite, issubnormal, 
             isinteger, isodd, iseven, zero, one,
             floor, ceil, trunc, div, fld, cld, rem, mod,
             modf, frexp, ldexp, sqrt, cbrt,
             log, exp, log1p, expm1, log2, log10,
             sin, cos, tan, csc, sec, cot,
             asin, acos, atan, acsc, asec, acot,
             sinh, cosh, tanh, csch, sech, coth,
             asinh, acosh, atanh, acsch, asech, acoth



using AccurateArithmetic

abstract type MultipartFloat{T} <: AbstractFloat end

include("Emphasis.jl") # Accuracy, Performance
include("Double.jl")   # Double, FastDouble

include("type/promote.jl")
include("type/constructors.jl")
include("type/predicates.jl")
include("type/values.jl")

include("buildingblocks/double.jl")

include("ops/prelims.jl")
include("ops/op.jl")
include("ops/floorceil.jl")

include("type/intfrac.jl")



#=
include("blocks/double.jl")
include("blocks/triple.jl")
include("blocks/namedconsts.jl")


include("type/DoubleFloat.jl")
include("blocks/doubleconsts.jl")

include("type/promote.jl")
include("type/string_show.jl")


include("type/predicates.jl")
include("type/val_isa_cmp.jl")
include("type/parts.jl")

include("ops/prelims.jl")
include("ops/intfloat.jl")

include("ops/op.jl")
include("math/sequences.jl")
include("math/explog.jl")
include("math/pi_maps.jl")
include("math/trig.jl")
=#

end # module DoubleFloats
