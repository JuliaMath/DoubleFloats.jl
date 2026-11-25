const FloatSigned = Union{IEEEFloat, Signed}

Base.:(+)(x::DoubleFloat{T}, y::FloatSigned, z::FloatSigned) where {T<:IEEEFloat}  = +(x, DoubleFloat{T}(y), DoubleFloat{T}(z))
Base.:(*)(x::DoubleFloat{T}, y::FloatSigned, z::FloatSigned) where {T<:IEEEFloat}  = *(x, DoubleFloat{T}(y), DoubleFloat{T}(z))
Base.:(+)(x::FloatSigned, y::DoubleFloat{T}, z::FloatSigned) where {T<:IEEEFloat}  = +(DoubleFloat{T}(x), y, DoubleFloat{T}(z))
Base.:(*)(x::FloatSigned, y::DoubleFloat{T}, z::FloatSigned) where {T<:IEEEFloat}  = *(DoubleFloat{T}(x), y, DoubleFloat{T}(z))
Base.:(+)(x::FloatSigned, y::FloatSigned, z::DoubleFloat{T}) where {T<:IEEEFloat}  = +(DoubleFloat{T}(x), DoubleFloat{T}(y), z)
Base.:(*)(x::FloatSigned, y::FloatSigned, z::DoubleFloat{T}) where {T<:IEEEFloat}  = *(DoubleFloat{T}(x), DoubleFloat{T}(y), z)
