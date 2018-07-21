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
     str = str[1+length("Double64("):end-1]
     histr, lostr = split(str, ", ")
     hi = Meta.parse(histr)
     lo = Meta.parse(lostr)
     result = Double64(hi, lo)
     return result
end

function trytypedparse(::Type{Double32}, str::T) where {T<:AbstractString}
     str = str[1+length("Double32("):end-1]
     histr, lostr = split(str, ", ")
     hi = Meta.parse(histr)
     lo = Meta.parse(lostr)
     result = Double32(hi, lo)
     return result
end

function trytypedparse(::Type{Double16}, str::T) where {T<:AbstractString}
     str = str[1+length("Double16("):end-1]
     histr, lostr = split(str, ", ")
     hi = Meta.parse(histr)
     lo = Meta.parse(lostr)
     result = Double16(hi, lo)
     return result
end


#=
function Base.tryparse(::Type{QuadrupleF64}, str::T) where {T<:AbstractString}
     str = str[1+length("QuadrupleF64("):end-1]
     hihistr, hilostr, lohistr, lolostr = split(str, ", ")
     hihi = Meta.parse(hihistr)
     hilo = Meta.parse(hilostr)
     lohi = Meta.parse(lohistr)
     lolo = Meta.parse(lolostr)
     hi = Double64(hihi, hilo)
     lo = Double64(lohi, lolo)
     result = QuadrupleF64(hi, lo)
     return result
end

function Base.tryparse(::Type{QuadrupleF32}, str::T) where {T<:AbstractString}
     str = str[1+length("QuadrupleF32("):end-1]
     hihistr, hilostr, lohistr, lolostr = split(str, ", ")
     hihi = Meta.parse(hihistr)
     hilo = Meta.parse(hilostr)
     lohi = Meta.parse(lohistr)
     lolo = Meta.parse(lolostr)
     hi = Double32(hihi, hilo)
     lo = Double32(lohi, lolo)
     result = QuadrupleF32(hi, lo)
     return result
end

function Base.tryparse(::Type{QuadrupleF16}, str::T) where {T<:AbstractString}
     str = str[1+length("QuadrupleF16("):end-1]
     hihistr, hilostr, lohistr, lolostr = split(str, ", ")
     hihi = Meta.parse(hihistr)
     hilo = Meta.parse(hilostr)
     lohi = Meta.parse(lohistr)
     lolo = Meta.parse(lolostr)
     hi = Double16(hihi, hilo)
     lo = Double16(lohi, lolo)
     result = QuadrupleF16(hi, lo)
     return result
end
=#
