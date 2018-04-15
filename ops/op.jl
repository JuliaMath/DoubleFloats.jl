include("op_fp_fp.jl")
include("op_fp_dd.jl")
include("op_fp_db.jl")
include("op_fpfp_dd.jl")
include("op_fpfp_db.jl")
include("op_fpdd_dd.jl")
include("op_fpdb_db.jl")
include("op_ddfp_dd.jl")
include("op_dbfp_db.jl")
include("op_ddsi_dd.jl")
include("op_dbsi_db.jl")
include("op_dd_dd.jl")
include("op_db_db.jl")
include("op_dddd_dd.jl")
include("op_dbdb_db.jl")

abs(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = abs_db_db(x)
(-)(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = neg_db_db(x)
negabs(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = negabs_db_db(x)
inv(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = inv_db_db(x)

square(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = square_db_db(x)
cube(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = cube_db_db(x)

sqrt(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = sqrt_db_db(x)
cbrt(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = cbrt_db_db(x)

(+)(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = add_fpdb_db(x, y)
(+)(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis} = add_dbfp_db(x, y)
(+)(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = add_dbdb_db(x, y)

(-)(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = sub_fpdb_db(x, y)
(-)(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis} = sub_dbfp_db(x, y)
(-)(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = sub_dbdb_db(x, y)

(*)(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = mul_fpdb_db(x, y)
(*)(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis} = mul_dbfp_db(x, y)
(*)(x::Double{T,E}, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = mul_dbdb_db(x, y)

(/)(x::T, y::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = dvi_fpdb_db(x, y)
(/)(x::Double{T,E}, y::T) where {T<:AbstractFloat, E<:Emphasis} = dvi_dbfp_db(x, y)
(/)(x::Double{T,Accuracy}, y::Double{T,Accuracy}) where {T<:AbstractFloat} = dvi_dbdb_db(x, y)
(/)(x::Double{T,Performance}, y::Double{T,Performance}) where {T<:AbstractFloat} = dvi_dbdb_db(x, y)



