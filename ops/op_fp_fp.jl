@inline abs_fp_fp(x::T) where {T<:AbstractFloat} = abs(x)
@inline negabs_fp_fp(x::T) where {T<:AbstractFloat} = -abs(x)
@inline neg_fp_fp(x::T) where {T<:AbstractFloat} = -x
@inline inv_fp_fp(x::T) where {T<:AbstractFloat} = inv(x)


@inline function powr2_fp_fp(x::T) where {T<:AbstractFloat}
    return x*x
end

@inline function powr3_fp_fp(x::T) where {T<:AbstractFloat}
    x2 = powr2_fp_fp(x)
    return x2 * x
end

@inline function powr4_fp_fp(x::T) where {T<:AbstractFloat}
    x2 = powr2_fp_fp(x)
    return x2 * x2
end

@inline function powr5_fp_fp(x::T) where {T<:AbstractFloat}
    x2 = powr2_fp_fp(x)
    x3 = x2 * x
    return x2 * x3
end

@inline function powr6_fp_fp(x::T) where {T<:AbstractFloat}
    x3 = powr3_fp_fp(x)
    return x3 * x3
end


@inline root2_fp_fp(x::T) where {T<:AbstractFloat} = sqrt(x)
@inline root3_fp_fp(x::T) where {T<:AbstractFloat} = cbrt(x)

@inline function root4_fp_fp(x::T) where {T<:AbstractFloat}
    return sqrt(sqrt(x))
end

@inline function root5_fp_fp(x::T) where {T<:AbstractFloat}
    exp(0.2 * log(x)) 
end

@inline function root6_fp_fp(x::T) where {T<:AbstractFloat}
    return cbrt(sqrt(x))
end
