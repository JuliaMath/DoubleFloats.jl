
function floor(x::DoubleFloat{T}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    # !isinteger(LO(x)), LO(x) is mixed or fractional
    if isinteger(HI(x))
        if isfractional(LO(x))
            if signbit(LO(x))
                DoubleFloat(HI(x)-one(T), zero(T))
            else
                DoubleFloat(HI(x), zero(T))
            end
        else # LO(x) is mixed: +/- int.frac
            DoubleFloat(HI(x), floor(LO(x)))
        end
    else # HI(x) is mixed or fractional
        DoubleFloat(floor(HI(x)), zero(T))
    end
end

floor(::Type{Int128}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int128(floor(x))
floor(::Type{Int64}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int64(floor(x))
floor(::Type{Int32}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int32(floor(x))
floor(::Type{Int16}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int16(floor(x))
floor(::Type{Integer}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int(floor(x))

function ceil(x::DoubleFloat{T}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    # !isinteger(LO(x)), LO(x) is mixed or fractional
    if isinteger(HI(x))
        if isfractional(LO(x))
            if signbit(LO(x))
                DoubleFloat(HI(x), zero(T))
            else
                DoubleFloat(HI(x)+one(T), zero(T))
            end
        else # LO(x) is mixed: +/- int.frac
            DoubleFloat(HI(x), ceil(LO(x)))
        end
    else # HI(x) is mixed or fractional
        DoubleFloat(ceil(HI(x)), zero(T))
    end
end

ceil(::Type{Int128}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int128(ceil(x))
ceil(::Type{Int64}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int64(ceil(x))
ceil(::Type{Int32}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int32(ceil(x))
ceil(::Type{Int16}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int16(ceil(x))
ceil(::Type{Integer}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int(ceil(x))

function trunc(x::DoubleFloat{T}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    if isnegative(x)
        ceil(x)
    else
        floor(x)
    end
end

trunc(::Type{Int128}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int128(trunc(x))
trunc(::Type{Int64}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int64(trunc(x))
trunc(::Type{Int32}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int32(trunc(x))
trunc(::Type{Int16}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int16(trunc(x))
trunc(::Type{Integer}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int(trunc(x))


function round(x::DoubleFloat{T}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    if isnonnegative(x)
        trunc(x + 0.5)
    else
        -trunc(-x + 0.5)
    end
end

round(::Type{Int128}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int128(round(x))
round(::Type{Int64}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int64(round(x))
round(::Type{Int32}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int32(round(x))
round(::Type{Int16}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int16(round(x))
round(::Type{Integer}, x::DoubleFloat{T}) where {T<:AbstractFloat} = Int(round(x))


function round(x::DoubleFloat{T}, ::RoundingMode{:Up}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    return ceil(x)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:Down}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    return floor(x)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:RoundToZero}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    return isnegative(x) ? ceil(x) : floor(x)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:RoundFromZero}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    return isnegative(x) ? floor(x) : ceil(x)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:Nearest}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    isnegative(x) && return -round(-x, RoundNearest)
    a = trunc(x + 0.5)
    return iseven(a) ? a : trunc(x - 0.5)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:NearestTiesAway}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    isnegative(x) && return -round(-x, RoundNearestTiesAway)
    !isinteger(x - 0.5) && return round(x, RoundNearest)
    return round(x + 0.5, RoundNearest)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:NearestTiesUp}) where {T<:AbstractFloat}
    (isinteger(x) || !isfinite(x)) && return x
    isnegative(x) && return -round(-x, RoundNearestTiesUp)
    !isinteger(x - 0.5) && return round(x, RoundUp)
    return round(x + 0.5, RoundNearest)
end

"""
     spread(x)
the nearest integer to x, away from zero
spread complements trunc()
"""
function spread(x::DoubleFloat{T}) where {T<:AbstractFloat}
    (!isfinite(x) || isinteger(x)) && return x
    if isinteger(HI(x))
        if signbit(LO(x))
              signbit(HI(x)) ? DoubleFloat(HI(x)-one(T), zero(T)) : DoubleFloat(HI(x), zero(T))
        else
              signbit(HI(x)) ? DoubleFloat(HI(x), zero(T)) : DoubleFloat(HI(x)+one(T), zero(T))
        end
    else
        signbit(HI(x)) ? DoubleFloat(floor(HI(x)), zero(T)) :  DoubleFloat(ceil(HI(x)), zero(T))
    end
end

"""
    tld(x, y)
Truncate the result of x/y.
""" tld

"""
    sld(x, y)
Spread the result of x/y.
""" sld

for (F,G) in ((:fld, :floor), (:cld, :ceil), (:tld, :trunc), (:sld, :spread))
    @eval begin
        function $F(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
            z = x / y
            return $G(z)
        end
    end
end
