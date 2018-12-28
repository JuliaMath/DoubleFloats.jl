@inline function (==)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    if ((LO(x) === LO(y)) && (HI(x) === HI(y)))
        return true
    end
    return (LO(x) === zero(T)) && (LO(y) === zero(T)) && (HI(x) == HI(y))
end
@inline function (!=)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    if (LO(x) === zero(T)) && (LO(y) === zero(T))
        return (HI(x) != HI(y))
    end
    return (LO(x) !== LO(y)) || (HI(x) !== HI(y))
end
@inline function (<)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) < LO(y))
end
@inline function (>)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) > LO(y))
end
@inline function (<=)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) <= LO(y))
end
@inline function (>=)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) >= LO(y))
end

@inline function isequal(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return x == y
end
@inline function isless(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return x < y
end

@inline function (==)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    iszero(LO(x)) || return false
    (HI(x) === y) && return true
    return ((HI(x) == zero(T)) && (y == zero(T)))
end
@inline function (==)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    iszero(LO(y)) || return false
    (HI(y) === x) && return true
    return ((HI(y) == zero(T)) && (x == zero(T)))
end
@inline function (!=)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    !iszero(LO(x)) && return true
    (HI(x) === y) && return false
    return ((HI(x) != zero(T)) || (y != zero(T)))
end
@inline function (!=)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return !iszero(LO(y)) || (HI(y) !== x)
    !iszero(LO(y)) && return true
    (HI(y) === x) && return false
    return ((HI(y) != zero(T)) || (x != zero(T)))
end

@inline function (<)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    return (HI(x) < y) || ((HI(x) == y) && signbit(LO(x)))
end
@inline function (<)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (x < HI(y)) || ((x == HI(y)) && !signbit(LO(y)))
end
@inline function (>)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    return (HI(x) > y) || ((HI(x) == y) && (LO(x) < zero(T)))
end
@inline function (>)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (x > HI(y)) || ((x == HI(y)) && signbit(LO(y)))
end
@inline function (<=)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    return (HI(x) < y) || ((HI(x) == y) && (LO(x) <= zero(T)))
end
@inline function (<=)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (x < HI(y)) || ((x == HI(y)) && (LO(y) >= zero(T)))
end
@inline function (>=)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    return (HI(x) > y) || ((HI(x) == y) && (LO(x) <= zero(T)))
end
@inline function (>=)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (x > HI(y)) || ((x == HI(y)) && (LO(y) >= zero(T)))
end

@inline function (==)(x::DoubleFloat{T}, y::Integer) where {T<:AbstractFloat}
    return (==)(x, DoubleFloat{T}(y))
end
@inline function (==)(x::Integer, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (==)(DoubleFloat{T}(x), y)
end
@inline function (!=)(x::DoubleFloat{T}, y::Integer) where {T<:AbstractFloat}
    return (!=)(x, DoubleFloat{T}(y))
end
@inline function (!=)(x::Integer, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (!=)(DoubleFloat{T}(x), y)
end

@inline function (<)(x::DoubleFloat{T}, y::Integer) where {T<:AbstractFloat}
    return (<)(x, DoubleFloat{T}(y))
end
@inline function (<)(x::Integer, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (<)(DoubleFloat{T}(x), y)
end
@inline function (>)(x::DoubleFloat{T}, y::Integer) where {T<:AbstractFloat}
    return (>)(x, DoubleFloat{T}(y))
end
@inline function (>)(x::Integer, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (>)(DoubleFloat{T}(x), y)
end
@inline function (<=)(x::DoubleFloat{T}, y::Integer) where {T<:AbstractFloat}
        return (<=)(x, DoubleFloat{T}(y))
end
@inline function (<=)(x::Integer, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (<=)(DoubleFloat{T}(x), y)
end
@inline function (>=)(x::DoubleFloat{T}, y::Integer) where {T<:AbstractFloat}
        return (>=)(x, DoubleFloat{T}(y))
end
@inline function (>=)(x::Integer, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (>=)(DoubleFloat{T}(x), y)
end

# mixing numbers and tuples

@inline function (==)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:AbstractFloat}
    return (LO(x) === LO(y)) && (HI(x) === HI(y))
end
@inline function (!=)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:AbstractFloat}
    return (LO(x) !== LO(y)) || (HI(x) !== HI(y))
end
@inline function (<)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:AbstractFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) < LO(y))
end
@inline function (>)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:AbstractFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) > LO(y))
end
@inline function (<=)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:AbstractFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) <= LO(y))
end
@inline function (>=)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:AbstractFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) >= LO(y))
end

@inline function isequal(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:AbstractFloat}
    return x == y
end
@inline function isless(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:AbstractFloat}
    return x < y
end

@inline function (==)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (LO(x) === LO(y)) && (HI(x) === HI(y))
end
@inline function (!=)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (LO(x) !== LO(y)) || (HI(x) !== HI(y))
end
@inline function (<)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) < LO(y))
end
@inline function (>)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) > LO(y))
end
@inline function (<=)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) <= LO(y))
end
@inline function (>=)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) >= LO(y))
end

@inline function isequal(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return x == y
end
@inline function isless(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return x < y
end
