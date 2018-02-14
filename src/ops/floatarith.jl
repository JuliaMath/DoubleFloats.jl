import Base: inv, sqrt, (+), (-), (*), (/)

function inv(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(inv_2(a))
end

function sqr(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sqr_2(a))
end

function cub(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(cub_2(a))
end

function sqrt(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sqrt_2(a))
end

@inline function (+)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(add_2(a, b))
end
@inline function (+)(::Type{E}, ab::Tuple{T, T}) where {T<:AbstractFloat, E<:Emphasis}
   return (+)(E, ab[1]. ab[2])
end

@inline function (-)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sub_2(a, b))
end
@inline function (-)(::Type{E}, ab::Tuple{T, T}) where {T<:AbstractFloat, E<:Emphasis}
   return (-)(E, ab[1]. ab[2])
end

@inline function (*)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(mul_2(a, b))
end
@inline function (*)(::Type{E}, ab::Tuple{T, T}) where {T<:AbstractFloat, E<:Emphasis}
   return (*)(E, ab[1]. ab[2])
end

@inline function (/)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(div_2(a, b))
end
@inline function (/)(::Type{E}, ab::Tuple{T, T}) where {T<:AbstractFloat, E<:Emphasis}
   return (/)(E, ab[1]. ab[2])
end

#=
leads to ambiguities

@inline (+)(::Type{E}, a::F1, b::F2) where
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (+)(E, promote(a, b))

@inline (-)(::Type{E}, a::F1, b::F2) where
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (-)(E, promote(a, b))

@inline (*)(::Type{E}, a::F1, b::F2) where
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (*)(E, promote(a, b))

@inline (/)(::Type{E}, a::F1, b::F2) where
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (/)(E, promote(a, b))
=#
