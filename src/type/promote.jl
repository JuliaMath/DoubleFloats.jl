promote_rule(::Type{DoubleFloat{Float64}}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float64}}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float32}

promote_rule(::Type{DoubleFloat{Float64}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{Float32}
promote_rule(::Type{DoubleFloat{Float16}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{Float16}

promote_rule(::Type{DoubleFloat{Float64}}, ::Type{T}) where {T<:Integer} = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{T}) where {T<:Integer} = DoubleFloat{Float32}
promote_rule(::Type{DoubleFloat{Float16}}, ::Type{T}) where {T<:Integer} = DoubleFloat{Float16}

promote_rule(::Type{DoubleFloat{Float64}}, ::Type{T}) where {T<:Base.BigInt} = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{T}) where {T<:Base.BigInt} = DoubleFloat{Float32}
promote_rule(::Type{DoubleFloat{Float16}}, ::Type{T}) where {T<:Base.BigInt} = DoubleFloat{Float16}

promote_rule(::Type{DoubleFloat{Float64}}, ::Type{T}) where {T<:Base.BigFloat} = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{T}) where {T<:Base.BigFloat} = DoubleFloat{Float32}
promote_rule(::Type{DoubleFloat{Float16}}, ::Type{T}) where {T<:Base.BigFloat} = DoubleFloat{Float16}

promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{DoubleFloat{DoubleFloat{Float32}}}) = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{DoubleFloat{DoubleFloat{Float16}}}) = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float32}}}, ::Type{DoubleFloat{DoubleFloat{Float16}}}) = DoubleFloat{DoubleFloat{Float32}}

promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{DoubleFloat{Float64}}) = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float32}}}, ::Type{DoubleFloat{Float64}}) = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float32}}}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float32}}}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float16}}}, ::Type{DoubleFloat{Float64}}) = DoubleFloat{DoubleFloat{Float16}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float16}}}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{DoubleFloat{Float16}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float16}}}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{DoubleFloat{Float16}}

promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float32}}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float16}}}, ::Type{T}) where {T<:IEEEFloat} = DoubleFloat{DoubleFloat{Float16}}

promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{T}) where {T<:Integer} = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float32}}}, ::Type{T}) where {T<:Integer} = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float16}}}, ::Type{T}) where {T<:Integer} = DoubleFloat{DoubleFloat{Float16}}

promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{T}) where {T<:Base.BigInt} = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float32}}}, ::Type{T}) where {T<:Base.BigInt} = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float16}}}, ::Type{T}) where {T<:Base.BigInt} = DoubleFloat{DoubleFloat{Float16}}

promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{T}) where {T<:Base.BigFloat} = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float32}}}, ::Type{T}) where {T<:Base.BigFloat} = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float16}}}, ::Type{T}) where {T<:Base.BigFloat} = DoubleFloat{DoubleFloat{Float16}}
