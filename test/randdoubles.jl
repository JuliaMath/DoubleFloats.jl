function randdouble(::Type{T}, n::Int=1; emin::Int=exponent_min(T), emax::Int=exponent_max(T), signed::Bool=false) where T<:AbstractFloat
    r1 = randfloat(T, n, emin=emin, emax=emax, signed=signed)[1]
    ex = exponent(r1) - 53
    r2 = ldexp(rand(T), ex)
    r2 = copysign(r2, rand(-1:2:1))
    return (r1, r2)
end

bf(x::Tuple{T,T}) where {T} = BigFloat(x[1])+BigFloat(x[2])
bf(x::Double{T,E}) where {T,E} = BigFloat(HI(x))+BigFloat(LO(x))

function addbf_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where {T}
    xbf = bf(x)
    ybf = bf(y)
    res = xbf+ybf
    hi = T(res)
    lo = T(res-hi)
    return hi, lo
end

function subbf_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where {T}
    xbf = bf(x)
    ybf = bf(y)
    res = xbf-ybf
    hi = T(res)
    lo = T(res-hi)
    return hi, lo
end

function mulbf_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where {T}
    xbf = bf(x)
    ybf = bf(y)
    res = xbf*ybf
    hi = T(res)
    lo = T(res-hi)
    return hi, lo
end

function invbf_dd_dd(x::Tuple{T,T}) where {T}
    xbf = bf(x)
    res = BigFloat(1.0)/xbf
    hi = T(res)
    lo = T(res-hi)
    return hi, lo
end


function dvibf_dddd_dd(x::Tuple{T,T}, y::Tuple{T,T}) where {T}
    xbf = bf(x)
    ybf = bf(y)
    res = xbf/ybf
    hi = T(res)
    lo = T(res-hi)
    return hi, lo
end


function addbf_dbdb_db(x::Double{T,E}, y::Tuple{T,E}) where {T,E}
    hi, lo = addbf_dddd_dd(HILO(x), HILO(y))
    return Double(E,hi,lo)
end
function subbf_dbdb_db(x::Double{T,E}, y::Tuple{T,E}) where {T,E}
    hi, lo = subbf_dddd_dd(HILO(x), HILO(y))
    return Double(E,hi,lo)
end
function mulbf_dbdb_db(x::Double{T,E}, y::Tuple{T,E}) where {T,E}
    hi, lo = mulbf_dddd_dd(HILO(x), HILO(y))
    return Double(E,hi,lo)
end
function invbf_db_db(x::Double{T,E}, y::Tuple{T,E}) where {T,E}
    hi, lo = invbf_dd_dd(HILO(x), HILO(y))
    return Double(E,hi,lo)
end
function dvibf_dbdb_db(x::Double{T,E}, y::Tuple{T,E}) where {T,E}
    hi, lo = dvibf_dddd_dd(HILO(x), HILO(y))
    return Double(E,hi,lo)
end

function tst(n,emin,emax)
    mx4 = 0.0; mx5=0.0
    for i in 1:n
        r1 = randdouble(Float64;emin=emin, emax=emax)
        r2 = randdouble(Float64;emin=emin, emax=emax)
        r3 = dvibf_dddd_dd(r1, r2)
        r4 = DoubleFloats.dvi_dddd_dd(r1, r2); r4 = DoubleFloats.add_2(HI(r4),LO(r4))
        r5 = DoubleFloats.dvi_dddd_dd_fast(r1, r2); r5 = DoubleFloats.add_2(HI(r5),LO(r5))
        ulp = eps(LO(r3))/2
        r4ulps = abs(LO(r3)-LO(r4))/ulp
        r5ulps = abs(LO(r3)-LO(r5))/ulp
        mx4 = max(mx4,r4ulps)
        mx5 = max(mx5,r5ulps)
    end
    return mx4, mx5, Float16(mx5/mx4)
end

