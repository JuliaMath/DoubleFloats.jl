function Base.lerpi(j::Integer, d::Integer, a::DoubleFloat{T}, b::DoubleFloat{T}) where {T}
    t = DoubleFloat{T}(j)/d
    a = fma(-t, a, a)
    return fma(t, b, a)
end
