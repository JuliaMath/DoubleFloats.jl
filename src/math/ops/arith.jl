abs(x::DoubleFloat{T}) where {T<:IEEEFloat} = abs_db_db(x)
(-)(x::DoubleFloat{T}) where {T<:IEEEFloat} = neg_db_db(x)
negabs(x::DoubleFloat{T}) where {T<:IEEEFloat} = negabs_db_db(x)
inv(x::DoubleFloat{T}) where {T<:IEEEFloat} = inv_db_db(x)

square(x::DoubleFloat{T}) where {T<:IEEEFloat} = square_db_db(x)
cube(x::DoubleFloat{T}) where {T<:IEEEFloat} = cube_db_db(x)

sqrt(x::DoubleFloat{T}) where {T<:IEEEFloat} = sqrt_db_db(x)
cbrt(x::DoubleFloat{T}) where {T<:IEEEFloat} = cbrt_db_db(x)

(+)(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat} = add_fpdb_db(x, y)
(+)(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat} = add_dbfp_db(x, y)
(+)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = add_dbdb_db(x, y)

(-)(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat} = sub_fpdb_db(x, y)
(-)(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat} = sub_dbfp_db(x, y)
(-)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = sub_dbdb_db(x, y)

(*)(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat} = mul_fpdb_db(x, y)
(*)(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat} = mul_dbfp_db(x, y)
(*)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = mul_dbdb_db(x, y)

(/)(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat} = dvi_fpdb_db(x, y)
(/)(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat} = dvi_dbfp_db(x, y)
(/)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = dvi_dbdb_db(x, y)

# Also provide arithmetic to add two floating point numbers in a higher precision
# without first converting them
"""
    add2(x::T, y::T) where {T<:IEEEFloat}

Add `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then adding.
"""
add2(x::T, y::T) where {T<:IEEEFloat} = add_fpfp_db(x, y)

"""
    ⊕(x::T, y::T) where {T<:IEEEFloat}

Add `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then adding.
This is the inline version of [`add2`](@ref) and written as ``\\oplus``.
"""
⊕(x::T, y::T) where {T<:IEEEFloat} = add2(x, y)


"""
    sub2(x::T, y::T) where {T<:IEEEFloat}

Subtract `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then subtracting.
"""
sub2(x::T, y::T) where {T<:IEEEFloat} = sub_fpfp_db(x, y)

"""
    ⊖(x::T, y::T) where {T<:IEEEFloat}

Subtract `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then subtracting.
This is the inline version of [`sub2`](@ref) and written as `\\ominus`.
"""
⊖(x::T, y::T) where {T<:IEEEFloat} = sub2(x, y)

"""
    mul2(x::T, y::T) where {T<:IEEEFloat}

Multiply `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then multiplying.
"""
mul2(x::T, y::T) where {T<:IEEEFloat} = mul_fpfp_db(x, y)

"""
    ⊗(x::T, y::T) where {T<:IEEEFloat}

Multiply `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then multiplying.
This is the inline version of [`mul2`](@ref) and written as `\\otimes`.
"""
⊗(x::T, y::T) where {T<:IEEEFloat} = mul2(x, y)

"""
    div(x::T, y::T) where {T<:IEEEFloat}

Divide `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then dividing.
"""
div2(x::T, y::T) where {T<:IEEEFloat} = dvi_fpfp_db(x, y)

"""
    ⊘(x::T, y::T) where {T<:IEEEFloat}

Divide `x` and `y` as if they are `DoubleFloat{T}` numbers. This is more
efficient as first converting to `DoubleFloat{T}` and then dividing.
This is the inline version of [`div2`](@ref) and written as ``\\oslash``.
"""
⊘(x::T, y::T) where {T<:IEEEFloat} = div2(x, y)
