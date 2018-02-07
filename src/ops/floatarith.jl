import Base: inv, sqrt, (+), (-), (*), (/)

function inv(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(inv_(a)...,)
end

function sqr(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sqr_(a)...,)
end

function cub(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(cub_(a)...,)
end

function sqrt(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sqrt_(a)...,)
end

function (+)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(add_(a, b)...,)
end
@inline (+)(::Type{E}, a::F1, b::F2) where 
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (+)(E, promote(a, b)...,)

function (-)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sub_(a, b)...,)
end
@inline (-)(::Type{E}, a::F1, b::F2) where 
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (-)(E, promote(a, b)...,)

function (*)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(mul_(a, b)...,)
end
@inline (*)(::Type{E}, a::F1, b::F2) where 
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (*)(E, promote(a, b)...,)

function (/)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(div_(a, b)...,)
end
@inline (/)(::Type{E}, a::F1, b::F2) where 
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (/)(E, promote(a, b)...,)
