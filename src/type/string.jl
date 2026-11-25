function string(x::DoubleFloat{T}) where {T<:IEEEFloat}
    (!isfinite(HI(x)) || iszero(LO(x))) && return string(HI(x))
    str = string(Float128(x))
    eat = findlast('e', str)
    isnothing(eat) && return str
    str[eat+2:end] === "00" && return(str[1:eat-1])
    
    zat = eat - 1
    while str[zat] === '0'
        zat -= 1
    end
    if (str[zat] === '.') zat += 1 end
    str[1:zat] * str[eat:end]
end

function string(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    xreal, ximag = reim(x)
    sepstr = signbit(ximag) ? " - " : " + "
    imstr = isfinite(ximag) ? "im" : "*im"
    string(xreal) * sepstr * string(ximag) * imstr
end

"""
    stringtyped
    
a `full representation of a DoubleFloat as a string
""" stringtyped

function stringtyped(x::Double64)
    str = string("Double64(", HI(x), ", ", LO(x), ")")
    return str
end
function stringtyped(x::Double32)
    str = string("Double32(", HI(x), ", ", LO(x), ")")
    return str
end
function stringtyped(x::Double16)
    str = string("Double16(", HI(x), ", ", LO(x), ")")
    return str
end

function stringtyped(x::Complex{DoubleFloat{Float64}})
    rea, ima = reim(x)
    str = string("ComplexDF64(", stringtyped(rea), ", ", stringtyped(imag(x)), ")")
    return str
end
function stringtyped(x::Complex{DoubleFloat{Float32}})
    rea, ima = reim(x)
    str = string("ComplexDF32(", stringtyped(rea), ", ", stringtyped(imag(x)), ")")
    return str
end
function stringtyped(x::Complex{DoubleFloat{Float16}})
    rea, ima = reim(x)
    str = string("ComplexDF16(", stringtyped(rea), ", ", stringtyped(imag(x)), ")")
    return str
end
