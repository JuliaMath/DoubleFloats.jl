@inline add_fpfp_dd(x::T, y::T) where {T<:AbstractFloat} = add_2(x, y)
@inline sub_fpfp_dd(x::T, y::T) where {T<:AbstractFloat} = sub_2(x, y)
@inline mul_fpfp_dd(x::T, y::T) where {T<:AbstractFloat} = mul_2(x, y)
@inline dvi_fpfp_dd(x::T, y::T) where {T<:AbstractFloat} = dvi_2(x, y)
# seems to help
@inline add_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = add_2(x, y)
@inline sub_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = sub_2(x, y)
@inline mul_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = mul_2(x, y)
@inline dvi_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = dvi_2(x, y)
