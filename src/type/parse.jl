function Base.tryparse(::Type{DoubleF64}, str::T) where {T<:AbstractString}
     str = str[1+length("DoubleF64("):end-1]
     histr, lostr = split(str, ", ")
     hi = Meta.parse(histr)
     lo = Meta.parse(lostr)
     result = DoubleF64(hi, lo)
     return result
end

function Base.tryparse(::Type{DoubleF32}, str::T) where {T<:AbstractString}
     str = str[1+length("DoubleF32("):end-1]
     histr, lostr = split(str, ", ")
     hi = Meta.parse(histr)
     lo = Meta.parse(lostr)
     result = DoubleF32(hi, lo)
     return result
end

function Base.tryparse(::Type{DoubleF16}, str::T) where {T<:AbstractString}
     str = str[1+length("DoubleF16("):end-1]
     histr, lostr = split(str, ", ")
     hi = Meta.parse(histr)
     lo = Meta.parse(lostr)
     result = DoubleF16(hi, lo)
     return result
end

function Base.tryparse(::Type{QuadrupleF64}, str::T) where {T<:AbstractString}
     str = str[1+length("QuadrupleF64("):end-1]
     hihistr, hilostr, lohistr, lolostr = split(str, ", ")
     hihi = Meta.parse(hihistr)
     hilo = Meta.parse(hilostr)
     lohi = Meta.parse(lohistr)
     lolo = Meta.parse(lolostr)
     hi = DoubleF64(hihi, hilo)
     lo = DoubleF64(lohi, lolo)
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
     hi = DoubleF32(hihi, hilo)
     lo = DoubleF32(lohi, lolo)
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
     hi = DoubleF16(hihi, hilo)
     lo = DoubleF16(lohi, lolo)
     result = QuadrupleF16(hi, lo)
     return result
end

