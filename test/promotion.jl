@testset "promote $T" for T in (Double16, Double32, Double64)


@test promote_type(DoubleFloat{Float64}}, DoubleFloat{Float32}) == DoubleFloat{Float64}

end
#=
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

promote_rule(::Type{DoubleFloat{Float64}}, ::Type{BigFloat}) = DoubleFloat{Float64}
promote_rule(::Type{DoubleFloat{Float32}}, ::Type{BigFloat}) = DoubleFloat{Float32}
promote_rule(::Type{DoubleFloat{Float16}}, ::Type{BigFloat}) = DoubleFloat{Float16}
promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{Float64}}) = DoubleFloat{Float64}
promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{Float32}}) = DoubleFloat{Float32}
promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{Float16}}) = DoubleFloat{Float16}

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

promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{BigInt}) = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float32}}}, ::Type{BigInt}) = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float16}}}, ::Type{BigInt}) = DoubleFloat{DoubleFloat{Float16}}

promote_rule(::Type{BigInt}, ::Type{DoubleFloat{DoubleFloat{Float64}}}) = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{BigInt}, ::Type{DoubleFloat{DoubleFloat{Float32}}}) = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{BigInt}, ::Type{DoubleFloat{DoubleFloat{Float16}}}) = DoubleFloat{DoubleFloat{Float16}}

promote_rule(::Type{DoubleFloat{DoubleFloat{Float64}}}, ::Type{BigFloat}) = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float32}}}, ::Type{BigFloat}) = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{DoubleFloat{DoubleFloat{Float16}}}, ::Type{BigFloat}) = DoubleFloat{DoubleFloat{Float16}}

promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{DoubleFloat{Float64}}}) = DoubleFloat{DoubleFloat{Float64}}
promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{DoubleFloat{Float32}}}) = DoubleFloat{DoubleFloat{Float32}}
promote_rule(::Type{BigFloat}, ::Type{DoubleFloat{DoubleFloat{Float16}}}) = DoubleFloat{DoubleFloat{Float16}}
=#
