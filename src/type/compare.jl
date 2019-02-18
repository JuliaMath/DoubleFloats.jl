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


@inline function (==)(x::DoubleFloat{T}, y::F) where {T<:IEEEFloat, F<:AbstractFloat}
    return (==)(x, DoubleFloat{T}(y))
end
@inline function (==)(x::F, y::DoubleFloat{T}) where {T<:IEEEFloat, F<:AbstractFloat}
    return (==)(DoubleFloat{T}(x), y)
end
@inline function (!=)(x::DoubleFloat{T}, y::F) where {T<:IEEEFloat, F<:AbstractFloat}
    return (!=)(x, DoubleFloat{T}(y))
end
@inline function (!=)(x::F, y::DoubleFloat{T}) where {T<:IEEEFloat, F<:AbstractFloat}
    return (!=)(DoubleFloat{T}(x), y)
end

@inline function (<)(x::DoubleFloat{T}, y::F) where {T<:IEEEFloat, F<:AbstractFloat}
    return (<)(x, DoubleFloat{T}(y))
end
@inline function (<)(x::F, y::DoubleFloat{T}) where {T<:IEEEFloat, F<:AbstractFloat}
    return (<)(DoubleFloat{T}(x), y)
end
@inline function (>)(x::DoubleFloat{T}, y::F) where {T<:IEEEFloat, F<:AbstractFloat}
    return (>)(x, DoubleFloat{T}(y))
end
@inline function (>)(x::F, y::DoubleFloat{T}) where {T<:IEEEFloat, F<:AbstractFloat}
    return (>)(DoubleFloat{T}(x), y)
end
@inline function (<=)(x::DoubleFloat{T}, y::F) where {T<:IEEEFloat, F<:AbstractFloat}
        return (<=)(x, DoubleFloat{T}(y))
end
@inline function (<=)(x::F, y::DoubleFloat{T}) where {T<:IEEEFloat, F<:AbstractFloat}
    return (<=)(DoubleFloat{T}(x), y)
end
@inline function (>=)(x::DoubleFloat{T}, y::F) where {T<:IEEEFloat, F<:AbstractFloat}
        return (>=)(x, DoubleFloat{T}(y))
end
@inline function (>=)(x::F, y::DoubleFloat{T}) where {T<:IEEEFloat, F<:AbstractFloat}
    return (>=)(DoubleFloat{T}(x), y)
end

@inline function isequal(x::DoubleFloat{T}, y::F) where {T<:IEEEFloat, F<:AbstractFloat}
    return isequal(x, DoubleFloat{T}(y))
end
@inline function isequal(x::F, y::DoubleFloat{T}) where {T<:IEEEFloat, F<:AbstractFloat}
    return isequal(DoubleFloat{T}(x), y)
end

@inline function isless(x::DoubleFloat{T}, y::F) where {T<:IEEEFloat, F<:AbstractFloat}
    return isless(x, DoubleFloat{T}(y))
end
@inline function isless(x::F, y::DoubleFloat{T}) where {T<:IEEEFloat, F<:AbstractFloat}
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
