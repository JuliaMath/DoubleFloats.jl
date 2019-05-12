@inline function Double64(str::S) where {S<:AbstractString}
  oldprec = precision(BigFloat)
  setprecision(BigFloat, 254)
  result = Double64(BigFloat(str))
  setprecision(BigFloat, oldprec)
  return result
end

macro df64_str(val::AbstractString)
  :(Double64($val))
end

@inline function Double32(str::S) where {S<:AbstractString}
  oldprec = precision(BigFloat)
  setprecision(BigFloat, 126)
  result = Double32(BigFloat(str))
  setprecision(BigFloat, oldprec)
  return result
end

macro df32_str(val::AbstractString)
  :(Double32($val))
end

@inline function Double16(str::S) where {S<:AbstractString}
  oldprec = precision(BigFloat)
  setprecision(BigFloat, 62)
  result = Double16(BigFloat(str))
  setprecision(BigFloat, oldprec)
  return result
end

macro df16_str(val::AbstractString)
  :(Double16($val))
end

function tryparse(::Type{DoubleFloat{Float64}}, str::S; base::Int=10) where {S<:AbstractString}
    x = tryparse(BigFloat, str, base=base)
    return ifelse(isnothing(x), nothing, DoubleFloat{Float64}(x))
end

function tryparse(::Type{DoubleFloat{Float32}}, str::S; base::Int=10) where {S<:AbstractString}
    x = tryparse(BigFloat, str, base=base)
    return ifelse(isnothing(x), nothing, DoubleFloat{Float32}(x))
end

function tryparse(::Type{DoubleFloat{Float16}}, str::S; base::Int=10) where {S<:AbstractString}
    x = tryparse(BigFloat, str, base=base)
    return ifelse(isnothing(x), nothing, DoubleFloat{Float16}(x))
end

function tryparse(::Type{Complex{DoubleFloat{Float64}}}, str::S; base::Int=10) where {S<:AbstractString}
    x = tryparse(Complex{BigFloat}, str)
    return ifelse(isnothing(x), nothing, Complex{DoubleFloat{Float64}}(x))
end

function tryparse(::Type{Complex{DoubleFloat{Float32}}}, str::S; base::Int=10) where {S<:AbstractString}
    x = tryparse(Complex{BigFloat}, str)
    return ifelse(isnothing(x), nothing, Complex{DoubleFloat{Float32}}(x))
end

function tryparse(::Type{Complex{DoubleFloat{Float16}}}, str::S; base::Int=10) where {S<:AbstractString}
    x = tryparse(Complex{BigFloat}, str)
    return ifelse(isnothing(x), nothing, Complex{DoubleFloat{Float16}}(x))
end

@inline function Complex{Double64}(str::S) where {S<:AbstractString}
  oldprec = precision(BigFloat)
  setprecision(BigFloat, 508)
  cplxbf = tryparse(Complex{BigFloat}, str)
  result = Complex{Double64}(Double64(real(cplxbf)), Double64(imag(cplxbf)))
  setprecision(BigFloat, oldprec)
  return result
end

@inline function Complex{Double32}(str::S) where {S<:AbstractString}
  oldprec = precision(BigFloat)
  setprecision(BigFloat, 254)
  cplxbf = tryparse(Complex{BigFloat}, str)
  result = Complex{Double32}(Double32(real(cplxbf)), Double32(imag(cplxbf)))
  setprecision(BigFloat, oldprec)
  return result
end

@inline function Complex{Double16}(str::S) where {S<:AbstractString}
  oldprec = precision(BigFloat)
  setprecision(BigFloat, 120)
  cplxbf = tryparse(Complex{BigFloat}, str)
  result = Complex{Double16}(Double16(real(cplxbf)), Double16(imag(cplxbf)))
  setprecision(BigFloat, oldprec)
  return result
end
