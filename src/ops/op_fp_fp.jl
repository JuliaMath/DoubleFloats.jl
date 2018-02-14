@inline function abs_fp_fp(x::T) where {T<:AbstractFloat}
   return abs(x)
end

@inline function neg_fp_fp(x::T) where {T<:AbstractFloat}
   return neg(x)
end

@inline function sqrt_fp_fp(x::T) where {T<:AbstractFloat}
   return sqrt(x)
end

@inline function inv_fp_fp(x::T) where {T<:AbstractFloat}
   return inv(x)
end
