@inline function (==)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (LO(x) === LO(y)) && (HI(x) === HI(y))
end
@inline function (!=)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (LO(x) !== LO(y)) || (HI(x) !== HI(y))
end
@inline function (<)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) < LO(y))
end
@inline function (>)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) > LO(y))
end
@inline function (<=)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) <= LO(y))
end
@inline function (>=)(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) >= LO(y))
end

@inline function isequal(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return x == y || (isnan(x) && isnan(y))
end
@inline function isless(x::DoubleFloat{T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return x < y
end

@inline function (==)(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    return iszero(LO(x)) && (HI(x) === y)
end
@inline function (==)(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return iszero(LO(y)) && (HI(y) === x)
end
@inline function (!=)(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    return !iszero(LO(x)) || (HI(x) !== y)
end
@inline function (!=)(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return !iszero(LO(y)) || (HI(y) !== x)
end

@inline function (<)(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    return (HI(x) < y) || ((HI(x) == y) && signbit(LO(x)))
end
@inline function (<)(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (x < HI(y)) || ((x == HI(y)) && !signbit(LO(y)))
end
@inline function (>)(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    return (HI(x) > y) || ((HI(x) == y) && (LO(x) < zero(T)))
end
@inline function (>)(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (x > HI(y)) || ((x == HI(y)) && signbit(LO(y)))
end
@inline function (<=)(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    return (HI(x) < y) || ((HI(x) == y) && (LO(x) <= zero(T)))
end
@inline function (<=)(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (x < HI(y)) || ((x == HI(y)) && (LO(y) >= zero(T)))
end
@inline function (>=)(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    return (HI(x) > y) || ((HI(x) == y) && (LO(x) <= zero(T)))
end
@inline function (>=)(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (x > HI(y)) || ((x == HI(y)) && (LO(y) >= zero(T)))
end

@inline function isequal(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    return isequal(x, DoubleFloat{T}(y))
end
@inline function isequal(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return isequal(DoubleFloat{T}(x), y)
end
@inline function isless(x::DoubleFloat{T}, y::T) where {T<:IEEEFloat}
    return isless(x, DoubleFloat{T}(y))
end
@inline function isless(x::T, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return isless(DoubleFloat{T}(x), y)
end



@inline function (==)(x::DoubleFloat{T}, y::Integer) where {T<:IEEEFloat}
    return (==)(x, DoubleFloat{T}(y))
end
@inline function (==)(x::Integer, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (==)(DoubleFloat{T}(x), y)
end
@inline function (!=)(x::DoubleFloat{T}, y::Integer) where {T<:IEEEFloat}
    return (!=)(x, DoubleFloat{T}(y))
end
@inline function (!=)(x::Integer, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (!=)(DoubleFloat{T}(x), y)
end

@inline function (<)(x::DoubleFloat{T}, y::Integer) where {T<:IEEEFloat}
    return (<)(x, DoubleFloat{T}(y))
end
@inline function (<)(x::Integer, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (<)(DoubleFloat{T}(x), y)
end
@inline function (>)(x::DoubleFloat{T}, y::Integer) where {T<:IEEEFloat}
    return (>)(x, DoubleFloat{T}(y))
end
@inline function (>)(x::Integer, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (>)(DoubleFloat{T}(x), y)
end
@inline function (<=)(x::DoubleFloat{T}, y::Integer) where {T<:IEEEFloat}
        return (<=)(x, DoubleFloat{T}(y))
end
@inline function (<=)(x::Integer, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (<=)(DoubleFloat{T}(x), y)
end
@inline function (>=)(x::DoubleFloat{T}, y::Integer) where {T<:IEEEFloat}
        return (>=)(x, DoubleFloat{T}(y))
end
@inline function (>=)(x::Integer, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (>=)(DoubleFloat{T}(x), y)
end

@inline function isequal(x::DoubleFloat{T}, y::Integer) where {T<:IEEEFloat}
    return isequal(x, DoubleFloat{T}(y))
end

@inline function isequal(x::Integer, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return isequal(DoubleFloat{T}(x), y)
end

@inline function isless(x::DoubleFloat{T}, y::Integer) where {T<:IEEEFloat}
    return isless(x, DoubleFloat{T}(y))
end

@inline function isless(x::Integer, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return isless(DoubleFloat{T}(x), y)
end



# mixing numbers and tuples

@inline function (==)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    return (LO(x) === LO(y)) && (HI(x) === HI(y))
end
@inline function (!=)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    return (LO(x) !== LO(y)) || (HI(x) !== HI(y))
end
@inline function (<)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) < LO(y))
end
@inline function (>)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) > LO(y))
end
@inline function (<=)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) <= LO(y))
end
@inline function (>=)(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) >= LO(y))
end

@inline function isequal(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    return x == y
end
@inline function isless(x::DoubleFloat{T}, y::Tuple{T,T}) where {T<:IEEEFloat}
    return x < y
end

@inline function (==)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (LO(x) === LO(y)) && (HI(x) === HI(y))
end
@inline function (!=)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (LO(x) !== LO(y)) || (HI(x) !== HI(y))
end
@inline function (<)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) < LO(y))
end
@inline function (>)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) > LO(y))
end
@inline function (<=)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) <= LO(y))
end
@inline function (>=)(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) >= LO(y))
end

@inline function isequal(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return x == y
end
@inline function isless(x::Tuple{T,T}, y::DoubleFloat{T}) where {T<:IEEEFloat}
    return x < y
end


@inline function (==)(x::DoubleFloat{T}, y::Rational) where {T<:IEEEFloat}
    yy = DoubleFloat{T}(numerator(y)) / denominator(y)
    return x == yy
end
@inline function (!=)(x::DoubleFloat{T}, y::Rational) where {T<:IEEEFloat}
    yy = DoubleFloat{T}(numerator(y)) / denominator(y)
    return x != yy
end
@inline function (<)(x::DoubleFloat{T}, y::Rational) where {T<:IEEEFloat}
    yy = DoubleFloat{T}(numerator(y)) / denominator(y)
    return x < yy
end
@inline function (>)(x::DoubleFloat{T}, y::Rational) where {T<:IEEEFloat}
    yy = DoubleFloat{T}(numerator(y)) / denominator(y)
    return x > yy
end
@inline function (<=)(x::DoubleFloat{T}, y::Rational) where {T<:IEEEFloat}
    yy = DoubleFloat{T}(numerator(y)) / denominator(y)
    return x <= yy
end
@inline function (>=)(x::DoubleFloat{T}, y::Rational) where {T<:IEEEFloat}
    yy = DoubleFloat{T}(numerator(y)) / denominator(y)
    return x >= yy
end

@inline function isequal(x::DoubleFloat{T}, y::Rational) where {T<:IEEEFloat}
    yy = DoubleFloat{T}(numerator(y)) / denominator(y)
    return isequal(x, yy)
end
@inline function isless(x::DoubleFloat{T}, y::Rational) where {T<:IEEEFloat}
    yy = DoubleFloat{T}(numerator(y)) / denominator(y)
    return isless(x, yy)
end



@inline function (==)(x::Rational, y::DoubleFloat{T}) where {T<:IEEEFloat}
    xx = DoubleFloat{T}(numerator(x)) / denominator(x)
    return xx == y
end
@inline function (!=)(x::Rational, y::DoubleFloat{T}) where {T<:IEEEFloat}
    xx = DoubleFloat{T}(numerator(x)) / denominator(x)
    return xx != y
end
@inline function (<)(x::Rational, y::DoubleFloat{T}) where {T<:IEEEFloat}
    xx = DoubleFloat{T}(numerator(x)) / denominator(x)
    return xx < y
end
@inline function (>)(x::Rational, y::DoubleFloat{T}) where {T<:IEEEFloat}
    xx = DoubleFloat{T}(numerator(x)) / denominator(x)
    return xx > y
end
@inline function (<=)(x::Rational, y::DoubleFloat{T}) where {T<:IEEEFloat}
    xx = DoubleFloat{T}(numerator(x)) / denominator(x)
    return xx <= y
end
@inline function (>=)(x::Rational, y::DoubleFloat{T}) where {T<:IEEEFloat}
    xx = DoubleFloat{T}(numerator(x)) / denominator(x)
    return xx >= y
end

@inline function isequal(x::Rational, y::DoubleFloat{T}) where {T<:IEEEFloat}
    xx = DoubleFloat{T}(numerator(x)) / denominator(x)
    return isequal(xx, y)
end
@inline function isless(x::Rational, y::DoubleFloat{T}) where {T<:IEEEFloat}
    xx = DoubleFloat{T}(numerator(x)) / denominator(x)
    return isless(xx, y)
end
