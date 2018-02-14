@inline function abs_fl_fl(x::T) where {T<:AbstractFloat}
   return abs(x)
end

@inline function neg_fl_fl(x::T) where {T<:AbstractFloat}
   return neg(x)
end

@inline function sqrt_fl_fl(x::T) where {T<:AbstractFloat}
   return sqrt(x)
end

@inline function inv_fl_fl(x::T) where {T<:AbstractFloat}
   return inv(x)
end
