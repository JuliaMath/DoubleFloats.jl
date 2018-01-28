import Base: inv, sqrt, (+), (-), (*), (/)

export sqr, cub

function sqr(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sqr_acc(a)...,)
end

function cub(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(cub_acc(a)...,)
end

function inv(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(inv_acc(a)...,)
end

function sqrt(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sqrt_acc(a)...,)
end

function (+)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(add_acc(a, b)...,)
end

@inline (+)(::Type{E}, a::F1, b::F2) where {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (+)(E, promote(a, b)...)

function (-)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(sub_acc(a, b)...,)
end
@inline (-)(::Type{E}, a::F1, b::F2) where {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (-)(E, promote(a, b)...)

function (*)(::Type{E}, a::T, b::T) where {T<:SysFloat, E<:Emphasis}
   return Double{T,E}(mul_acc(a, b)...,)
end
@inline (*)(::Type{E}, a::F1, b::F2) where {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (*)(E, promote(a, b)...)

function inv(::Type{E}, a::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(inv_acc(a)...,)
end

function (/)(::Type{E}, a::T, b::T) where {T<:AbstractFloat, E<:Emphasis}
   return Double{T,E}(div_acc(a)...,)
end
@inline (/)(::Type{E}, a::F1, b::F2) where {E<:Emphasis, F1<:AbstractFloat, F2<:AbstractFloat} = (/)(E, promote(a, b)...) lo)
