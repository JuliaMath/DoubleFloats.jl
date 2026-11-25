Base.promote_rule(::Type{DoubleFloat{Float64}}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{Float64}
Base.promote_rule(::Type{DoubleFloat{Float64}}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float64}
Base.promote_rule(::Type{DoubleFloat{Float32}}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float32}

Base.promote_rule(::Type{DoubleFloat{Float64}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{Float64}
Base.promote_rule(::Type{DoubleFloat{Float32}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{Float32}
Base.promote_rule(::Type{DoubleFloat{Float16}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{Float16}

Base.promote_rule(::Type{DoubleFloat{Float64}}, ::Type{T}) where {T<:Integer} = DoubleFloat{Float64}
Base.promote_rule(::Type{DoubleFloat{Float32}}, ::Type{T}) where {T<:Integer} = DoubleFloat{Float32}
Base.promote_rule(::Type{DoubleFloat{Float16}}, ::Type{T}) where {T<:Integer} = DoubleFloat{Float16}

Base.promote_rule(::Type{DoubleFloat{Float64}}, ::Type{BigInt}) = DoubleFloat{Float64}
Base.promote_rule(::Type{DoubleFloat{Float32}}, ::Type{BigInt}) = DoubleFloat{Float32}
Base.promote_rule(::Type{DoubleFloat{Float16}}, ::Type{BigInt}) = DoubleFloat{Float16}
Base.promote_rule(::Type{BigInt}, ::Type{DoubleFloat{Float64}}) = DoubleFloat{Float64}
Base.promote_rule(::Type{BigInt}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{Float32}
Base.promote_rule(::Type{BigInt}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float16}

Base.promote_rule(::Type{DoubleFloat{Float64}}, ::Type{BigFloat}) = BigFloat
Base.promote_rule(::Type{DoubleFloat{Float32}}, ::Type{BigFloat}) = BigFloat
Base.promote_rule(::Type{DoubleFloat{Float16}}, ::Type{BigFloat}) = BigFloat
Base.promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{Float64}}) = BigFloat
Base.promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{Float32}}) = BigFloat
Base.promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{Float16}}) = BigFloat

Base.promote_rule(::Type{AbstractIrrational}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float16}
Base.promote_rule(::Type{AbstractIrrational}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{Float32}
Base.promote_rule(::Type{AbstractIrrational}, ::Type{DoubleFloat{Float64}}) = DoubleFloat{Float64}

Base.promote_rule(::Type{DoubleFloat{T}}, ::Type{Real}) where {T<:IEEEFloat} = DoubleFloat{T}

Base.widen(::Type{DoubleFloat{Float16}}) = DoubleFloat{Float32}
Base.widen(::Type{DoubleFloat{Float32}}) = DoubleFloat{Float64}
Base.widen(::Type{DoubleFloat{Float64}}) = BigFloat
