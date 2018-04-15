#export spread, tld, sld

function floor(x::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
    (isinteger(x) || !isfinite(x)) && return x
    # !isinteger(LO(x)), LO(x) is mixed or fractional
    if isinteger(HI(x))
        if isfractional(LO(x))
            if signbit(LO(x))
                Double(E, HI(x)-one(T), zero(T))
            else
                Double(E, HI(x), zero(T))
            end
        else # LO(x) is mixed: +/- int.frac
            Double(E, HI(x), floor(LO(x)))
        end
    else # HI(x) is mixed or fractional
        Double(E, floor(HI(x)), zero(T))
    end
end

function ceil(x::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
    (isinteger(x) || !isfinite(x)) && return x
    # !isinteger(LO(x)), LO(x) is mixed or fractional
    if isinteger(HI(x))
        if isfractional(LO(x))
            if signbit(LO(x))
                Double(E, HI(x), zero(T))
            else
                Double(E, HI(x)+one(T), zero(T))
            end
        else # LO(x) is mixed: +/- int.frac
            Double(E, HI(x), ceil(LO(x)))
        end
    else # HI(x) is mixed or fractional
        Double(E, ceil(HI(x)), zero(T))
    end
end


function trunc(x::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
    (isinteger(x) || !isfinite(x)) && return x
    if isneg(x)
        ceil(x)
    else
        floor(x)
    end
end

function round(x::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
    (isinteger(x) || !isfinite(x)) && return x
    if isnonneg(x)
        trunc(x + 0.5)
    else
        -trunc(-x + 0.5)
    end
end

function round(x::Double{T,E}, ::RoundingMode{:Up}) where {T<:AbstractFloat,E<:Emphasis}
    (isinteger(x) || !isfinite(x)) && return x
    return ceil(x)
end

function round(x::Double{T,E}, ::RoundingMode{:Down}) where {T<:AbstractFloat,E<:Emphasis}
    (isinteger(x) || !isfinite(x)) && return x
    return floor(x)
end

function round(x::Double{T,E}, ::RoundingMode{:RoundToZero}) where {T<:AbstractFloat,E<:Emphasis}
    (isinteger(x) || !isfinite(x)) && return x
    return isneg(x) ? ceil(x) : floor(x)
end

function round(x::Double{T,E}, ::RoundingMode{:RoundFromZero}) where {T<:AbstractFloat,E<:Emphasis}
    (isinteger(x) || !isfinite(x)) && return x
    return isneg(x) ? floor(x) : ceil(x)
end

function round(x::Double{T,E}, ::RoundingMode{:RoundNearest}) where {T<:AbstractFloat,E<:Emphasis}
    (isinteger(x) || !isfinite(x)) && return x
    if isnonneg(x)
        trunc(x + 0.5)
    else
        -trunc(-x + 0.5)
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
