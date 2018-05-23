@inline function (==)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return (LO(x) === LO(y)) && (HI(x) === HI(y))
end
@inline function (!=)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:AbstractFloat}
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
    return iszero(LO(x)) && (HI(x) === y)
end
@inline function (==)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return iszero(LO(y)) && (HI(y) === x)
end
@inline function (!=)(x::DoubleFloat{T}, y::T) where {T<:AbstractFloat}
    return !iszero(LO(x)) || (HI(x) !== y)
end
@inline function (!=)(x::T, y::DoubleFloat{T}) where {T<:AbstractFloat}
    return !iszero(LO(y)) || (HI(y) !== x)
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
