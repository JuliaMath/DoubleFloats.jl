#=
    A Robust Complex Division in Scilab
    by Michael Baudin, Robert L. Smith
=#

function cdiv(x::Complex{DoubleFloat{T}},
             y::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    a, b = reim(x)
    c, d = reim(y)
    if abs(d) <= abs(c)
        e, f = robustdiv(a, b, c, d)
    else
        e, f = robustdiv(b, a, d, c)
        f = -f
    end
    z = Complex{DoubleFloat{T}}(e, f)
    return z
end

function robustdiv(a::DF, b::DF, c::DF, d::DF) where {T, DF<:DoubleFloat{T}}
    r = d / c
    t = inv( fma(r, d, c) )
    e = robustcomp(a,b,c,d,r,t)
    a = -a
    f = robustcomp(b,a,c,d,r,t)
    return e, f
end

function robustcomp(a,b,c,d,r,t)
    if !iszero(r)
        if !iszero(b) & !iszero(r)
            e = fma(b, r, a) * t
        else
            e = a * t + (b * t) * r
        end
    else
        e = fma(d, (b/c), a) * t
    end
    return e
end
