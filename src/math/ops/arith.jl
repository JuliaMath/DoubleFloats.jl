

abs(x::DoubleFloat{T}) where {T<:AbstractFloat} = abs_db_db(x)
(-)(x::DoubleFloat{T}) where {T<:AbstractFloat} = neg_db_db(x)
negabs(x::DoubleFloat{T}) where {T<:AbstractFloat} = negabs_db_db(x)
inv(x::DoubleFloat{T}) where {T<:AbstractFloat} = inv_db_db(x)

square(x::DoubleFloat{T}) where {T<:AbstractFloat} = square_db_db(x)
cube(x::DoubleFloat{T}) where {T<:AbstractFloat} = cube_db_db(x)

sqrt(x::DoubleFloat{T}) where {T<:AbstractFloat} = sqrt_db_db(x)
cbrt(x::DoubleFloat{T}) where {T<:AbstractFloat} = cbrt_db_db(x)

(+)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat} = add_fpdb_db(x, y)
(+)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat} = add_dbfp_db(x, y)
(+)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat} = add_dbdb_db(x, y)

(-)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat} = sub_fpdb_db(x, y)
(-)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat} = sub_dbfp_db(x, y)
(-)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat} = sub_dbdb_db(x, y)

(*)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat} = mul_fpdb_db(x, y)
(*)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat} = mul_dbfp_db(x, y)
(*)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat} = mul_dbdb_db(x, y)

(/)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat} = dvi_fpdb_db(x, y)
(/)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat} = dvi_dbfp_db(x, y)
(/)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat} = dvi_dbdb_db(x, y)
