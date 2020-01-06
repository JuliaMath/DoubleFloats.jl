function floor(x::DoubleFloat{T}) where {T<:IEEEFloat}
    # !isinteger(LO(x)), LO(x) is mixed or fractional
    if isinteger(HI(x))
        if isfractional(LO(x))
            if signbit(LO(x))
                DoubleFloat{T}(HI(x)-one(T), zero(T))
            else
                DoubleFloat{T}(HI(x), zero(T))
            end
        else # LO(x) is mixed: +/- int.frac
            DoubleFloat(HI(x), floor(LO(x)))
        end
    else # HI(x) is mixed or fractional
        DoubleFloat{T}(floor(HI(x)), zero(T))
    end
end

floor(::Type{Int128}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int128(floor(x))
floor(::Type{Int64}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int64(floor(x))
floor(::Type{Int32}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int32(floor(x))
floor(::Type{Int16}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int16(floor(x))
floor(::Type{Integer}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int(floor(x))

function ceil(x::DoubleFloat{T}) where {T<:IEEEFloat}
    # !isinteger(LO(x)), LO(x) is mixed or fractional
    if isinteger(HI(x))
        if isfractional(LO(x))
            if signbit(LO(x))
                DoubleFloat{T}(HI(x), zero(T))
            else
                DoubleFloat{T}(HI(x)+one(T), zero(T))
            end
        else # LO(x) is mixed: +/- int.frac
            DoubleFloat(HI(x), ceil(LO(x)))
        end
    else # HI(x) is mixed or fractional
        DoubleFloat{T}(ceil(HI(x)), zero(T))
    end
end

ceil(::Type{Int128}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int128(ceil(x))
ceil(::Type{Int64}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int64(ceil(x))
ceil(::Type{Int32}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int32(ceil(x))
ceil(::Type{Int16}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int16(ceil(x))
ceil(::Type{Integer}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int(ceil(x))

function trunc(x::DoubleFloat{T}) where {T<:IEEEFloat}
    signbit(x) ? ceil(x) : floor(x)
end

trunc(::Type{Int128}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int128(trunc(x))
trunc(::Type{Int64}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int64(trunc(x))
trunc(::Type{Int32}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int32(trunc(x))
trunc(::Type{Int16}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int16(trunc(x))
trunc(::Type{Integer}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int(trunc(x))


function round(x::DoubleFloat{T}) where {T<:IEEEFloat}
    trunc(x + copysign(0.5, x))
end

round(::Type{Int128}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int128(round(x))
round(::Type{Int64}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int64(round(x))
round(::Type{Int32}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int32(round(x))
round(::Type{Int16}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int16(round(x))
round(::Type{Integer}, x::DoubleFloat{T}) where {T<:IEEEFloat} = Int(round(x))


function round(x::DoubleFloat{T}, ::RoundingMode{:Up}) where {T<:IEEEFloat}
    return ceil(x)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:Down}) where {T<:IEEEFloat}
    return floor(x)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:RoundToZero}) where {T<:IEEEFloat}
    return isnegative(x) ? ceil(x) : floor(x)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:RoundFromZero}) where {T<:IEEEFloat}
    return isnegative(x) ? floor(x) : ceil(x)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:Nearest}) where {T<:IEEEFloat}
    isnegative(x) && return -round(-x, RoundNearest)
    a = trunc(x + 0.5)
    return iseven(a) ? a : trunc(x - 0.5)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:NearestTiesAway}) where {T<:IEEEFloat}
    isnegative(x) && return -round(-x, RoundNearestTiesAway)
    !isinteger(x - 0.5) && return round(x, RoundNearest)
    return round(x + 0.5, RoundNearest)
end

function round(x::DoubleFloat{T}, ::RoundingMode{:NearestTiesUp}) where {T<:IEEEFloat}
    isnegative(x) && return -round(-x, RoundNearestTiesUp)
    !isinteger(x - 0.5) && return round(x, RoundUp)
    return round(x + 0.5, RoundNearest)
end

"""
     spread(x)
the nearest integer to x, away from zero
spread complements trunc()
"""
function spread(x::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(x) || isinteger(x)) && return x
    if isinteger(HI(x))
        if signbit(LO(x))
              signbit(HI(x)) ? DoubleFloat{T}(HI(x)-one(T), zero(T)) : DoubleFloat{T}(HI(x), zero(T))
        else
              signbit(HI(x)) ? DoubleFloat{T}(HI(x), zero(T)) : DoubleFloat{T}(HI(x)+one(T), zero(T))
        end
    else
        signbit(HI(x)) ? DoubleFloat{T}(floor(HI(x)), zero(T)) :  DoubleFloat{T}(ceil(HI(x)), zero(T))
    end
end

function spread(x::T) where {T<:IEEEFloat}
    (!isfinite(x) || isinteger(x)) && return x
    return trunc(x + sign(x))
end

"""
    tld(x, y)
Truncate the result of x/y.
"""
tld(x::T, y::T) where {T<:IEEEFloat} = trunc(x/y)

"""
    sld(x, y)
Spread the result of x/y.
""" sld
sld(x::T, y::T) where {T<:IEEEFloat} = spread(x/y)

for (F,G) in ((:tld, :trunc), (:sld, :spread))
    @eval begin
        function $F(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
            z = x / y
            return $G(z)
        end
    end
end

for (F,G) in ((:fld, :floor), (:cld, :ceil), (:tld, :trunc), (:sld, :spread))
    @eval begin
        function $F(x::DoubleFloat{T}, y::T1) where {T<:IEEEFloat, T1<:IEEEFloat}
            z = x / y
            return $G(z)
        end
        function $F(x::T1, y::DoubleFloat{T}) where {T<:IEEEFloat, T1<:IEEEFloat}
            z = x / y
            return $G(z)
        end
    end
end
