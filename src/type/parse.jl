macro d64_str(val::String)
    quote
      begin
        local oldprec = precision(BigFloat)
        setprecision(BigFloat, 254)
        local dbl = Double64(BigFloat($val))
        setprecision(BigFloat, oldprec)
        dbl
      end
    end
end

macro d32_str(val::String)
    quote
      begin
        local oldprec = precision(BigFloat)
        setprecision(BigFloat, 126)
        local dbl = Double64(BigFloat($val))
        setprecision(BigFloat, oldprec)
        dbl
      end
    end
end

macro d16_str(val::String)
    quote
      begin
        local oldprec = precision(BigFloat)
        setprecision(BigFloat, 62)
        local dbl = Double64(BigFloat($val))
        setprecision(BigFloat, oldprec)
        dbl
      end
    end
end

# constructors
Double16(str::T) where {T<:AbstractString} = @d16_str(:($str))
Double32(str::T) where {T<:AbstractString} = @d32_str(:($str))
Double64(str::T) where {T<:AbstractString} = @d64_str(:($str))

#=

function splitnumstring(str::AbstractString, dlm)
    strs = String.(split(str, dlm))
    strs = map(x->(isempty(x) ? "0.0" : x), strs)
    n = length(strs)
    if n > 1
        strs
    elseif n == 1
        [strs[1], "0.0"]
    else
        ["0.0", "0.0"]
    end
end

# constructors
Double16(str::T) where {T<:AbstractString} = tryparse(Double16, str)
Double32(str::T) where {T<:AbstractString} = tryparse(Double32, str)
Double64(str::T) where {T<:AbstractString} = tryparse(Double64, str)

function Base.tryparse(::Type{Double64}, str::T) where {T<:AbstractString}
     str = strip(str)
     if startswith(str, "DoubleFloat{Float64}")
         str = string("Double64", str[length("DoubleFloat{Float64}")+1:end])
     end
     if !startswith(str, "Double64(")
         str = string("Double64(", str, ")")
     end
     return trytypedparse(Double64, str)
end

function Base.tryparse(::Type{Double32}, str::T) where {T<:AbstractString}
     str = strip(str)
     if startswith(str, "DoubleFloat{Float32}")
         str = string("Double32", str[length("DoubleFloat{Float32}")+1:end])
     end
     if !startswith(str, "Double32(")
         str = string("Double32(", str, ")")
     end
     return trytypedparse(Double32, str)
end

function Base.tryparse(::Type{Double16}, str::T) where {T<:AbstractString}
     str = strip(str)
     if startswith(str, "DoubleFloat{Float16}")
         str = string("Double16", str[length("DoubleFloat{Float16}")+1:end])
     end
     if !startswith(str, "Double16(")
         str = string("Double16(", str, ")")
     end
     return trytypedparse(Double16, str)
end


function trytypedparse(::Type{Double64}, str::T) where {T<:AbstractString}
     str = str[1+length("Double64("):length(str)-1]
     histr, lostr = splitnumstring(str, ", ")
     hi = Float64(Meta.parse(histr))
     lo = Float64(Meta.parse(lostr))
     result = Double64(hi, lo)
     return result
end

function trytypedparse(::Type{Double32}, str::T) where {T<:AbstractString}
     str = str[1+length("Double32("):end-1]
     histr, lostr = splitnumstring(str, ", ")
     hi = Float32(Meta.parse(histr))
     lo = Float32(Meta.parse(lostr))
     result = Double32(hi, lo)
     return result
end

function trytypedparse(::Type{Double16}, str::T) where {T<:AbstractString}
     str = str[1+length("Double16("):end-1]
     histr, lostr = splitnumstring(str, ", ")
     hi = Float16(Meta.parse(histr))
     lo = Float16(Meta.parse(lostr))
     result = Double16(hi, lo)
     return result
end
=#
