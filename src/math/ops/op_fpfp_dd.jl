@inline add_fpfp_dd(x::T, y::T) where {T<:AbstractFloat} = two_sum(x, y)
@inline sub_fpfp_dd(x::T, y::T) where {T<:AbstractFloat} = two_diff(x, y)
@inline mul_fpfp_dd(x::T, y::T) where {T<:AbstractFloat} = two_prod(x, y)
@inline dvi_fpfp_dd(x::T, y::T) where {T<:AbstractFloat} = two_dvi(x, y)
# seems to help
@inline add_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = two_sum(x, y)
@inline sub_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = two_diff(x, y)
@inline mul_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = two_prod(x, y)
@inline dvi_fpfp_dd(x::T, y::T) where {T<:IEEEFloat} = two_dvi(x, y)
