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

# Also provide arithmetic to add two floating point numbers in a higher precision
# without first converting them
"""
    add2(x::T, y::T) where {T<:AbstractFloat}

Add `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then adding.
"""
add2(x::T, y::T) where {T<:AbstractFloat} = add_fpfp_db(x, y)

"""
    ⊕(x::T, y::T) where {T<:AbstractFloat}

Add `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then adding.
This is the inline version of [`add2`](@ref) and written as ``\\oplus``.
"""
⊕(x::T, y::T) where {T<:AbstractFloat} = add2(x, y)


"""
    sub2(x::T, y::T) where {T<:AbstractFloat}

Subtract `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then subtracting.
"""
sub2(x::T, y::T) where {T<:AbstractFloat} = sub_fpfp_db(x, y)

"""
    ⊖(x::T, y::T) where {T<:AbstractFloat}

Subtract `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then subtracting.
This is the inline version of [`sub2`](@ref) and written as `\\ominus`.
"""
⊖(x::T, y::T) where {T<:AbstractFloat} = sub2(x, y)

"""
    mul2(x::T, y::T) where {T<:AbstractFloat}

Multiply `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then multiplying.
"""
mul2(x::T, y::T) where {T<:AbstractFloat} = mul_fpfp_db(x, y)

"""
    ⊗(x::T, y::T) where {T<:AbstractFloat}

Multiply `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then multiplying.
This is the inline version of [`mul2`](@ref) and written as `\\otimes`.
"""
⊗(x::T, y::T) where {T<:AbstractFloat} = mul2(x, y)

"""
    div(x::T, y::T) where {T<:AbstractFloat}

Divide `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then dividing.
"""
div2(x::T, y::T) where {T<:AbstractFloat} = dvi_fpfp_db(x, y)

"""
    ⊘(x::T, y::T) where {T<:AbstractFloat}

Divide `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then dividing.
This is the inline version of [`div2`](@ref) and written as ``\\oslash``.
"""
⊘(x::T, y::T) where {T<:AbstractFloat} = div2(x, y)
