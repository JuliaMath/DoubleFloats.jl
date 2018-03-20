function (==)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis}
    return (LO(x) === LO(y)) && (HI(x) === HI(y))
end
function (!=)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis}
    return (LO(x) !== LO(y)) || (HI(x) !== HI(y))
end
function (<)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) < LO(y))
end
function (>)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) > LO(y))
end
function (<=)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis}
    return (HI(x) < HI(y)) || (HI(x) === HI(y) && LO(x) <= LO(y))
end
function (>=)(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis}
    return (HI(x) > HI(y)) || (HI(x) === HI(y) && LO(x) >= LO(y))
end

function isequal(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis}
    return x == y
end
function isless(x::Double{T,E}, y::Double{T,E}) where {T<:Real,E<:Emphasis}
    return x < y
end

function (==)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis}
    return iszero(LO(x)) && (HI(x) === y)
end
function (==)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis}
    return iszero(LO(y)) && (HI(y) === x)
end
function (!=)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis}
    return !iszero(LO(x)) || (HI(x) !== y)
end
function (!=)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis}
    return !iszero(LO(y)) || (HI(y) !== x)
end

function (<)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis}
    return (HI(x) < y) || ((HI(x) == y) && signbit(LO(x)))
end
function (<)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis}
    return (x < HI(y)) || ((x == HI(y)) && !signbit(LO(y)))
end
function (>)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis}
    return (HI(x) > y) || ((HI(x) == y) && (LO(x) < zero(T)))
end
function (>)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis}
    return (x > HI(y)) || ((x == HI(y)) && signbit(LO(y)))
end
function (<=)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis}
    return (HI(x) < y) || ((HI(x) == y) && (LO(x) <= zero(T)))
end
function (<=)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis}
    return (x < HI(y)) || ((x == HI(y)) && (LO(y) >= zero(T)))
end
function (>=)(x::Double{T,E}, y::T) where {T<:Real, E<:Emphasis}
    return (HI(x) > y) || ((HI(x) == y) && (LO(x) <= zero(T)))
end
function (>=)(x::T, y::Double{T,E}) where {T<:Real, E<:Emphasis}
    return (x > HI(y)) || ((x == HI(y)) && (LO(y) >= zero(T)))
end
