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

include("ops/op_fp_fp.jl")
include("ops/op_fpfp_db.jl")
include("ops/op_dbfp_db.jl")
include("ops/op_fpdb_db.jl")
include("ops/op_db_db.jl")
include("ops/op_dbdb_db.jl")

#=
include("ops/floatarith.jl")
include("ops/arith.jl")
=#

end # module DoubleFloats
