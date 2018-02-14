module DoubleFloats

export Double, FastDouble,
       Emphasis, Accuracy, Performance,
       HI, LO, HILO,
       sqr, cub,
       MultipartFloat, AbstractDouble,
       spread, sld, tld,
       nan, inf

import Base: abs, inv, sqrt, cbrt,
             (+), (-), (*), (/), (\)
             # div, fld, cld, rem, mod, divrem, fldmod,
             # (^)

if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
    const IEEEFloat = Union{Float64, Float32, Float16}
end


using AccurateArithmetic

abstract type MultipartFloat{T} <: AbstractFloat end
abstract type AbstractDouble{T} <: MultipartFloat{T} end

include("traits.jl")

include("type/DoubleFloat.jl")
include("type/promote.jl")
include("type/string_show.jl")
include("type/val_isa_cmp.jl")

include("ops/prelims.jl")
include("ops/intfloat.jl")
include("ops/floatarith.jl")
include("ops/arith.jl")


end # module DoubleFloats
