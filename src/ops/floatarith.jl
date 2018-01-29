import Base: inv, sqrt, (+), (-), (*), (/)

function sqr(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sqr_hilo(a)...,)
end

function cub(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(cub_hilo(a)...,)
end

function sqrt(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sqrt_hilo(a)...,)
end

function (+)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(add_hilo(a, b)...,)
end
@inline (+)(::Type{E}, a::F1, b::F2) where 
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (+)(E, promote(a, b)...,)

function (-)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sub_hilo(a, b)...,)
end
@inline (-)(::Type{E}, a::F1, b::F2) where 
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (-)(E, promote(a, b)...,)

function (*)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(mul_hilo(a, b)...,)
end
@inline (*)(::Type{E}, a::F1, b::F2) where 
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (*)(E, promote(a, b)...,)

function inv(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(inv_hilo(a)...,)
end

function sqrt(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sqrt_hilo(a)...,)
end

function (/)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(div_hilo(a, b)...,)
end
@inline (/)(::Type{E}, a::F1, b::F2) where 
    {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (/)(E, promote(a, b)...,)
