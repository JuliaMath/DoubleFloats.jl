# Operations on `DoubleFloat` values, built on the tuple kernels. In names,
# `db` is a `DoubleFloat` and `fp` a single word.

# --- DoubleFloat in, DoubleFloat out ---------------------------------------

@inline function inv_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    yhi, ylo = x.hi, x.lo
    thi = inv(yhi)
    # NB: ylo == 0 does NOT make the reciprocal exact; unsafe_inv_dd_dd_
    #     handles it properly and must not be skipped
    (!isfinite(thi) || !isfinite(yhi) || !isfinite(ylo)) && return unsafe_double(T, zero_error_result(thi)...)
    zhi, zlo = unsafe_inv_dd_dd_(yhi, ylo)
    isfinite(zhi) || return unsafe_double(T, unsafe_inv_dd_dd(yhi, ylo)...)
    return unsafe_double(T, zhi, zlo)
end

@inline function square_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    isnotfinite(x) && return unsafe_double(T, square_dd_dd((x.hi, x.lo))...)
    zhi, zlo = square_dd_dd_((x.hi, x.lo))
    isfinite(zhi) || return unsafe_double(T, square_dd_dd((x.hi, x.lo))...)
    return unsafe_double(T, zhi, zlo)
end

@inline function cube_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    zhi, zlo = cube_dd_dd((x.hi, x.lo))
    return unsafe_double(T, zhi, zlo)
end

@inline function sqrt_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    zhi, zlo = sqrt_dd_dd((x.hi, x.lo))
    return unsafe_double(T, zhi, zlo)
end

@inline function cbrt_db_db(x::DoubleFloat{T}) where {T<:IEEEFloat}
    zhi, zlo = cbrt_dd_dd((x.hi, x.lo))
    return unsafe_double(T, zhi, zlo)
end

# Here the reciprocal head is between 2^-256 and 2^256 in magnitude.
# The normalized low limb bounds the correction to a few ulps, so the
# finite fast path in inv_db_db applies throughout the window.
@inline _batch_inv_range(x) = _batch_abs_bounded(x, 0x1p-256, 0x1p256)

_batch_kernel(::typeof(inv), ::Type{Double64}, ::Type{Double64}) = _BatchKernel(_batch_inv_range, _batch_inv)

# --- two words in, DoubleFloat out -----------------------------------------

@inline function add_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(add_fpfp_dd(x, y))
end

@inline function sub_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(sub_fpfp_dd(x, y))
end

@inline function mul_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(mul_fpfp_dd(x, y))
end

@inline function dvi_fpfp_db(x::T, y::T) where {T<:IEEEFloat}
    return DoubleFloat{T}(dvi_fpfp_dd(x, y))
end

# --- word and DoubleFloat in -----------------------------------------------

@inline function add_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return add_fpdb_db_nonfinite(x, y)
    zhi, zlo = add_fpdd_dd(x, (y.hi, y.lo))
    return unsafe_double(T, zhi, zlo)
end

@inline function sub_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return sub_fpdb_db_nonfinite(x, y)
    zhi, zlo = sub_fpdd_dd(x, (y.hi, y.lo))
    return unsafe_double(T, zhi, zlo)
end

@inline function mul_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return mul_fpdb_db_nonfinite(x, y)
    zhi, zlo = mul_fpdd_dd(x, (y.hi, y.lo))
    return unsafe_double(T, zhi, zlo)
end

@inline function dvi_fpdb_db(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return dvi_fpdb_db_nonfinite(x, y)
    zhi, zlo = dvi_fpdd_dd(x, (y.hi, y.lo))
    return unsafe_double(T, zhi, zlo)
end

@inline function add_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x + HI(y)
    return unsafe_double(T, z, z)
end

@inline function sub_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x - HI(y)
    return unsafe_double(T, z, z)
end

@inline function mul_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x * HI(y)
    return unsafe_double(T, z, z)
end

@inline function dvi_fpdb_db_nonfinite(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = x / HI(y)
    return unsafe_double(T, z, z)
end

# --- DoubleFloat and word in -----------------------------------------------

@inline function add_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return add_dbfp_db_nonfinite(x, y)
    zhi, zlo = add_ddfp_dd((x.hi, x.lo), y)
    return unsafe_double(T, zhi, zlo)
end

@inline function sub_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return sub_dbfp_db_nonfinite(x, y)
    zhi, zlo = sub_ddfp_dd((x.hi, x.lo), y)
    return unsafe_double(T, zhi, zlo)
end

@inline function mul_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return mul_dbfp_db_nonfinite(x, y)
    zhi, zlo = mul_ddfp_dd((x.hi, x.lo), y)
    return unsafe_double(T, zhi, zlo)
end

@inline function dvi_dbfp_db(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return dvi_dbfp_db_nonfinite(x, y)
    zhi, zlo = dvi_ddfp_dd((x.hi, x.lo), y)
    return unsafe_double(T, zhi, zlo)
end

@inline function add_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    z = HI(x) + y
    return unsafe_double(T, z, z)
end

@inline function sub_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    z = HI(x) - y
    return unsafe_double(T, z, z)
end

@inline function mul_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    z = HI(x) * y
    return unsafe_double(T, z, z)
end

@inline function dvi_dbfp_db_nonfinite(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    z = HI(x) / y
    return unsafe_double(T, z, z)
end

# --- two DoubleFloats in ---------------------------------------------------

Base.:(+)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x + unsafe_double(T, y[1], y[2])
Base.:(+)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = unsafe_double(T, x[1], x[2]) + y

Base.:(-)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x - unsafe_double(T, y[1], y[2])
Base.:(-)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = unsafe_double(T, x[1], x[2]) - y

Base.:(*)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x * unsafe_double(T, y[1], y[2])
Base.:(*)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = unsafe_double(T, x[1], x[2]) * y

Base.:(/)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat} = x / unsafe_double(T, y[1], y[2])
Base.:(/)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = unsafe_double(T, x[1], x[2]) / y

@inline function add_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return add_dbdb_db_nonfinite(x, y)
    zhi, zlo = add_dddd_dd_((x.hi, x.lo), (y.hi, y.lo))
    isfinite(zhi) || return unsafe_double(T, add_dddd_dd((x.hi, x.lo), (y.hi, y.lo))...)
    return unsafe_double(T, zhi, zlo)
end

@inline function sub_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return sub_dbdb_db_nonfinite(x, y)
    zhi, zlo = sub_dddd_dd_((x.hi, x.lo), (y.hi, y.lo))
    isfinite(zhi) || return unsafe_double(T, sub_dddd_dd((x.hi, x.lo), (y.hi, y.lo))...)
    return unsafe_double(T, zhi, zlo)
end

@inline function mul_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (isnotfinite(x) | isnotfinite(y)) && return mul_dbdb_db_nonfinite(x, y)
    zhi, zlo = mul_dddd_dd_((x.hi, x.lo), (y.hi, y.lo))
    isfinite(zhi) || return unsafe_double(T, mul_dddd_dd((x.hi, x.lo), (y.hi, y.lo))...)
    return unsafe_double(T, zhi, zlo)
end

@inline function dvi_dbdb_db(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    (iszero(HI(y)) | isnotfinite(x) | isnotfinite(y)) && return dvi_dbdb_db_nonfinite(x, y)
    zhi, zlo = dvi_dddd_dd_((x.hi, x.lo), (y.hi, y.lo))
    isfinite(zhi) || return unsafe_double(T, dvi_dddd_dd((x.hi, x.lo), (y.hi, y.lo))...)
    return unsafe_double(T, zhi, zlo)
end

@inline function add_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = HI(x) + HI(y)
    return unsafe_double(T, z, z)
end

@inline function sub_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = HI(x) - HI(y)
    return unsafe_double(T, z, z)
end

@inline function mul_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = HI(x) * HI(y)
    return unsafe_double(T, z, z)
end

@inline function dvi_dbdb_db_nonfinite(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    z = HI(x) / HI(y)
    return unsafe_double(T, z, z)
end

# --- Base operators --------------------------------------------------------

Base.inv(x::DoubleFloat{T}) where {T<:IEEEFloat} = inv_db_db(x)

square(x::DoubleFloat{T}) where {T<:IEEEFloat} = square_db_db(x)
cube(x::DoubleFloat{T}) where {T<:IEEEFloat} = cube_db_db(x)

Base.abs2(x::DoubleFloat{T}) where {T<:IEEEFloat} = square(x)

Base.sqrt(x::DoubleFloat{T}) where {T<:IEEEFloat} = sqrt_db_db(x)
Base.cbrt(x::DoubleFloat{T}) where {T<:IEEEFloat} = cbrt_db_db(x)

(Base.:(+))(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat} = add_fpdb_db(x, y)
(Base.:(+))(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat} = add_dbfp_db(x, y)
(Base.:(+))(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = add_dbdb_db(x, y)

(Base.:(-))(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat} = sub_fpdb_db(x, y)
(Base.:(-))(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat} = sub_dbfp_db(x, y)
(Base.:(-))(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = sub_dbdb_db(x, y)

(Base.:(*))(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat} = mul_fpdb_db(x, y)
(Base.:(*))(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat} = mul_dbfp_db(x, y)
(Base.:(*))(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = mul_dbdb_db(x, y)

(Base.:(/))(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat} = dvi_fpdb_db(x, y)
(Base.:(/))(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat} = dvi_dbfp_db(x, y)
(Base.:(/))(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat} = dvi_dbdb_db(x, y)

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

# --- cube root of a word, as a pair ------------------------------------

function two_cbrt(a::T) where {T<:FloatWithFMA}
    return HILO(unsafe_double(T, a, zero(T))^(one(T)/3))
end
