isnotfinite(x::Float64) = reinterpret(UInt64,x) & 0x7ff0000000000000 === 0x7ff0000000000000
isqnan(x::Float64) = reinterpret(UInt64,x) & 0x7ff8000000000000 === 0x7ff8000000000000
isainf(x::Float64) = reinterpret(UInt64,x) & 0x7ff8000000000000 === 0x7ff0000000000000

isnotfinite(x::Float32) = reinterpret(UInt32,x) & 0x7f800000 === 0x7f800000
isqnan(x::Float32) = reinterpret(UInt32,x)      & 0x7fc00000 === 0x7fc00000
isainf(x::Float32) = reinterpret(UInt32,x)      & 0x7fc00000 === 0x7f800000

isnotfinite(x::DoubleFloat{T}) where {T<:IEEEFloat} = isnan(LO(x))
isqnan(x::DoubleFloat{T}) where {T<:IEEEFloat} = isqnan(HI(x))
isainf(x::DoubleFloat{T}) where {T<:IEEEFloat} = isainf(HI(x))

isnotfinite(x::AbstractFloat) = !isfinite(x)
isqnan(x::AbstractFloat) = isnan(x)
isainf(x::AbstractFloat) = isinf(x)
  
include("ops/op_fp_dd.jl")
include("ops/op_fpfp_dd.jl")
include("ops/op_fpdd_dd.jl")
include("ops/op_dd_dd.jl")
include("ops/op_ddfp_dd.jl")
include("ops/op_ddsi_dd.jl")
include("ops/op_dddd_dd.jl")
include("ops/op_fp_db.jl")
include("ops/op_db_db.jl")
include("ops/op_fpfp_db.jl")
include("ops/op_fpdb_db.jl")
include("ops/op_dbfp_db.jl")
include("ops/op_dbsi_db.jl")
include("ops/op_dbdb_db.jl")
include("ops/arith.jl")
