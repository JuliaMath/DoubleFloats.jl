promote_rule(::Type{DoubleFloat{Float64}}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float64}}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float32}

promote_rule(::Type{DoubleFloat{Float64}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{Float32}
promote_rule(::Type{DoubleFloat{Float16}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{Float16}

promote_rule(::Type{DoubleFloat{Float64}}, ::Type{T}) where {T<:Integer} = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{T}) where {T<:Integer} = DoubleFloat{Float32}
promote_rule(::Type{DoubleFloat{Float16}}, ::Type{T}) where {T<:Integer} = DoubleFloat{Float16}

promote_rule(::Type{DoubleFloat{Float64}}, ::Type{BigInt}) = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{BigInt}) = DoubleFloat{Float32}
promote_rule(::Type{DoubleFloat{Float16}}, ::Type{BigInt}) = DoubleFloat{Float16}
promote_rule(::Type{BigInt}, ::Type{DoubleFloat{Float64}}) = DoubleFloat{Float64}
promote_rule(::Type{BigInt}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{Float32}
promote_rule(::Type{BigInt}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float16}

promote_rule(::Type{DoubleFloat{Float64}}, ::Type{BigFloat}) = BigFloat
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{BigFloat}) = BigFloat
promote_rule(::Type{DoubleFloat{Float16}}, ::Type{BigFloat}) = BigFloat
promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{Float64}}) = BigFloat
promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{Float32}}) = BigFloat
promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{Float16}}) = BigFloat

promote_rule(::Type{AbstractIrrational}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float16}
promote_rule(::Type{AbstractIrrational}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{Float32}
promote_rule(::Type{AbstractIrrational}, ::Type{DoubleFloat{Float64}}) = DoubleFloat{Float64}

promote_rule(::Type{DoubleFloat{T}}, ::Type{Real}) where {T<:IEEEFloat} = DoubleFloat{T}

widen(::Type{DoubleFloat{Float16}}) = DoubleFloat{Float32}
widen(::Type{DoubleFloat{Float32}}) = DoubleFloat{Float64}
widen(::Type{DoubleFloat{Float64}}) = BigFloat
