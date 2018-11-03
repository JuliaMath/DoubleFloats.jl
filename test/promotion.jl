@testset "promote $T" for T in (Double16, Double32, Double64)

f2 = 2.0
  
@test promote_type(DoubleFloat{Float64}, DoubleFloat{Float32}) == DoubleFloat{Float64}
@test promote_type(DoubleFloat{Float64}, DoubleFloat{Float16}) == DoubleFloat{Float64}
@test promote_type(DoubleFloat{Float32}, DoubleFloat{Float16}) == DoubleFloat{Float32}

@test promote_type(DoubleFloat{Float64}, BigFloat) == DoubleFloat{Float64}
@test promote_type(DoubleFloat{Float32}, BigFloat) == DoubleFloat{Float32}
@test promote_type(DoubleFloat{Float16}, BigFloat) == DoubleFloat{Float16}

@test promote_type(DoubleFloat{Float64}, BigInt) == DoubleFloat{Float64}
@test promote_type(DoubleFloat{Float32}, BigInt) == DoubleFloat{Float32}
@test promote_type(DoubleFloat{Float16}, BigInt) == DoubleFloat{Float16}

@test promote(DoubleFloat{Float64}(f2), DoubleFloat{Float32}(f2))[2] == DoubleFloat{Float64}(f2)
@test promote(DoubleFloat{Float64}(f2), DoubleFloat{Float16}(f2))[2] == DoubleFloat{Float64}(f2)
@test promote(DoubleFloat{Float32}(f2), DoubleFloat{Float16}(f2))[2] == DoubleFloat{Float32}(f2)

@test promote(DoubleFloat{Float64}(f2), BigFloat(f2))[2] == DoubleFloat{Float64}(f2)
@test promote(DoubleFloat{Float32}(f2), BigFloat(f2))[2] == DoubleFloat{Float32}(f2)
@test promote(DoubleFloat{Float16}(f2), BigFloat(f2))[2] == DoubleFloat{Float16}(f2)

@test promote(DoubleFloat{Float64}(f2), BigInt(f2))[2] == DoubleFloat{Float64}(f2)
@test promote(DoubleFloat{Float32}(f2), BigInt(f2))[2] == DoubleFloat{Float32}(f2)
@test promote(DoubleFloat{Float16}(f2), BigInt(f2))[2] == DoubleFloat{Float16}(f2)

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
