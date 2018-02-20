import Base: floor, ceil, trunc, fld, cld

#export spread, tld, sld

function floor(x::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
    (!isfinite(x) || isinteger(x)) && return x
    if isinteger(HI(x))
        if signbit(LO(x))
              Double(E, HI(x)-one(T), zero(T))
        else
              Double(E, HI(x), zero(T))
        end
    else
        Double(E, floor(HI(x)), zero(T))
    end
end


function ceil(x::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
    (!isfinite(x) || isinteger(x)) && return x
    if isinteger(HI(x))
        if signbit(LO(x))
              Double(E, HI(x), zero(T))
        else
              Double(E, HI(x)+one(T), zero(T))
        end
    else
        Double(E, ceil(HI(x)), zero(T))
    end
end

function trunc(x::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
    (!isfinite(x) || isinteger(x)) && return x
    if isinteger(HI(x))
        if signbit(LO(x))
              signbit(HI(x)) ? Double(E, HI(x), zero(T)) : Double(E, HI(x)-one(T), zero(T))
        else
              signbit(HI(x)) ? Double(E, HI(x)+one(T), zero(T)) : Double(E, HI(x), zero(T))
        end
    else
        signbit(HI(x)) ? Double(E, ceil(HI(x)), zero(T)) :  Double(E, floor(HI(x)), zero(T))
    end
end

"""
     spread(x)

the nearest integer to x, away from zero

spread complements trunc()
"""
function spread(x::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
    (!isfinite(x) || isinteger(x)) && return x
    if isinteger(HI(x))
        if signbit(LO(x))
              signbit(HI(x)) ? Double(E, HI(x)-one(T), zero(T)) : Double(E, HI(x), zero(T))
        else
              signbit(HI(x)) ? Double(E, HI(x), zero(T)) : Double(E, HI(x)+one(T), zero(T))
        end
    else
        signbit(HI(x)) ? Double(E, floor(HI(x)), zero(T)) :  Double(E, ceil(HI(x)), zero(T))
    end
end

"""
    tld(x, y)

Truncate the result of x/y.
""" tld

"""
    sld(x, y)

Spread the result of x/y.
""" sld

for (F,G) in ((:fld, :floor), (:cld, :ceil), (:tld, :trunc), (:sld, :spread))
    @eval begin
        function $F(x::Double{T,E}, y::T) where {T<:AbstractFloat,E<:Emphasis}
            z = x / y
            return $G(z)
        end
    end
end
