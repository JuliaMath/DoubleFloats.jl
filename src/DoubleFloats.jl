module DoubleFloats

export Double, FastDouble,
       Emphasis, Accuracy, Performance,
       HI, LO, HILO,
       sqr, cub,
       MultipartFloat, AbstractDouble,
       spread, sld, tld,
       nan, inf,
       signs

if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
    const IEEEFloat = Union{Float64, Float32, Float16}
end

import Base: (+), (-), (*), (/), (\), (^), abs, inv,
             (==), (!=), (<), (<=), (>=), (>), isequal, isless,
             iszero, isinf, isnan, isinf, isfinite, issubnormal, 
             isinteger, isodd, iseven, zero, one

if VERSION >= v"0.7.0-"
    import Base:isone
else
    export isone
end

using AccurateArithmetic

abstract type MultipartFloat{T} <: AbstractFloat end
abstract type AbstractDouble{T} <: MultipartFloat{T} end


include("blocks/double.jl")

include("traits.jl")
include("type/DoubleFloat.jl")
include("type/promote.jl")
include("type/string_show.jl")
include("type/val_isa_cmp.jl")

include("ops/prelims.jl")
include("ops/intfloat.jl")

include("ops/op.jl")
#=
include("ops/floatarith.jl")
include("ops/arith.jl")
=#

end # module DoubleFloats
