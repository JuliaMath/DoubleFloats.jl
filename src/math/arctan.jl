#=
http://mathworld.wolfram.com/InverseTangent.html cites Acton 1990
=#

function atan(x::T) where {T<:AbstractFloat}
    return atan(x)
end

function atan(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    b = one(Double{T,Accuracy})
    a = inv(sqrt(b+square(x)))
    result = x * a
    while abs(a) < abs(b)
        a = (a + b) / 2
        b = sqrt(a * b)
    end

    result = result * inv(a)
    return result
end

function atan(x::Double{T,Performance}) where {T<:AbstractFloat}
    result = arctan(Double{T,Accuracy}(x))
    return Double(Performance, HILO(result))
end
