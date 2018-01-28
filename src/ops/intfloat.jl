import Base: floor, ceil, trunc, fld, cld

#export spread, tld, sld

function floor(x::Double{T,E}) where {T<:Real,E<:Emphasis}
    (!isfinite(x) || isinteger(x)) && return x
    if isinteger(hi(x))
        if signbit(lo(x))
              Double(E, hi(x)-one(T), zero(T))
        else
              Double(E, hi(x), zero(T))
        end
    else
        Double(E, floor(hi(x)), zero(T))
    end
end


function ceil(x::Double{T,E}) where {T<:Real,E<:Emphasis}
    (!isfinite(x) || isinteger(x)) && return x
    if isinteger(hi(x))
        if signbit(lo(x))
              Double(E, hi(x), zero(T))
        else
              Double(E, hi(x)+one(T), zero(T))
        end
    else
        Double(E, ceil(hi(x)), zero(T))
    end
end

function trunc(x::Double{T,E}) where {T<:Real,E<:Emphasis}
    (!isfinite(x) || isinteger(x)) && return x
    if isinteger(hi(x))
        if signbit(lo(x))
              signbit(hi(x)) ? Double(E, hi(x), zero(T)) : Double(E, hi(x)-one(T), zero(T))
        else
              signbit(hi(x)) ? Double(E, hi(x)+one(T), zero(T)) : Double(E, hi(x), zero(T))
        end
    else
        signbit(hi(x)) ? Double(E, ceil(hi(x)), zero(T)) :  Double(E, floor(hi(x)), zero(T))
    end
end

"""
     spread(x)

the nearest integer to x, away from zero

spread complements trunc()
"""
function spread(x::Double{T,E}) where {T<:Real,E<:Emphasis}
    (!isfinite(x) || isinteger(x)) && return x
    if isinteger(hi(x))
        if signbit(lo(x))
              signbit(hi(x)) ? Double(E, hi(x)-one(T), zero(T)) : Double(E, hi(x), zero(T)) 
        else
              signbit(hi(x)) ? Double(E, hi(x), zero(T)) : Double(E, hi(x)+one(T), zero(T))
        end
    else
        signbit(hi(x)) ? Double(E, floor(hi(x)), zero(T)) :  Double(E, ceil(hi(x)), zero(T))
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
        function $F(x::Double{T,E}, y::T) where {T<:Real,E<:Emphasis}
            z = x / y
            return $G(z)
        end
    end
end
