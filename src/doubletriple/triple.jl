function triple(::Type{T}, x::BigFloat) where {T<:Base.IEEEFloat}
    prec = precision(BigFloat)
    setprecision(BigFloat, 768)
    hi = T(x)
    md = T(x - hi)
    lo = T(x - hi - md)
    setprecision(BigFloat, prec)
    return hi,md,lo
end

function triple(::Type{T}, x::String) where {T<:Base.IEEEFloat}
    prec = precision(BigFloat)
    setprecision(BigFloat, 768)
    z = parse(BigFloat, x)
    hi = T(z)
    md = T(z - hi)
    lo = T(z - hi - md)
    setprecision(BigFloat, prec)
    return hi,md,lo
end

triple64(x::BigFloat) = triple(Float64, x)
triple32(x::BigFloat) = triple(Float32, x)
triple16(x::BigFloat) = triple(Float16, x)

triple64(x::String) = triple(Float64, x)
triple32(x::String) = triple(Float32, x)
triple16(x::String) = triple(Float16, x)

function triple_inv(::Type{T}, x::BigFloat) where {T<:Base.IEEEFloat}
    prec = precision(BigFloat)
    setprecision(BigFloat, 768)
    x = inv(x)
    hi = T(x)
    md = T(x - hi)
    lo = T(x - hi - md)
    setprecision(BigFloat, prec)
    return hi,md,lo
end

triple64inv(x::BigFloat) = triple_inv(Float64, x)
triple32inv(x::BigFloat) = triple_inv(Float32, x)
triple16inv(x::BigFloat) = triple_inv(Float16, x)

#=
Basic building blocks for a triple-double intermediate format
Christoph Quirin Lauter
Thème NUM — Systèmes numériques, Projet Arénaire
Rapport de recherche n 5702 — Septembre 2005 — 67 pages
=#

# Algorithm 3.3

function renorm(hi::T, md::T, lo::T) where {T<:AbstractFloat}
    md, lo = add_2(md, lo)
    hi, m  = add_2(hi, md)
    md, lo = add_2(m,  md)
    return hi, md, lo
end


function renorm_hilo(hi::T, md::T, lo::T) where {T<:AbstractFloat}
    md, lo = add_2(md, lo)
    hi, m  = add_2(hi, md)
    md, lo = add_2(m,  md)
    return hi, md, lo
end

# Algorithm 4.1  (relerr 4.5 .. 16 u^2)

function add222(ahilo, bhilo)
    ahi, alo = ahilo
    bhi, blo = bhilo
    if abs(ahi) >= abs(bhi)
        t1 = ahi + bhi
        t2 = ahi - t1
        t3 = t2  + bhi
        t4 = t3  + blo
        t5 = t4  + alo
    else
        t1 = ahi + bhi
        t2 = bhi - t1
        t3 = t2  + ahi
        t4 = t3  + alo
        t5 = t4  + blo
    end
    return zhi, zlo
end


# Algorithm 4.6  (relerr 16 u^2)

function mul222(ahilo, bhilo)
    ahi, alo = ahilo
    bhi, blo = bhilo
    t1, t2 = mul_2(ahi, bhi)
    t3 = ahi * blo
    t4 = alo * bhi
    t5 = t3 + t4
    t6 = t2 + t5
    zhi, zlo = add_2(t1, t6)
    return zhi, zlo
end

# addition

# Algorithm 5.1 (Add33)
# (ahi,amd,alo) + (bhi,bmd,blo) :: (zhi,zmd,zlo)

function add333(ahi::T, amd::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = add_2(ahi, bhi)
    t2, t3 = add_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t6 = alo + blo
    t5 = t3 + t4
    t8 = t5 + t6
    zmd, zlo = add_2(t7, t8)
    return zhi, zmd, zlo
end

@inline function add333(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return add333(a[1], a[2], a[3], b[1], b[2], b[3])
end

function add332(ahi::T, amd::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = add_2(ahi, bhi)
    t2, t3 = add_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t6 = alo + blo
    t5 = t3 + t4
    zmd = t5 + t6
    zmd += t7
    return zhi, zmd
end

@inline function add332(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return add332(a[1], a[2], a[3], b[1], b[2], b[3])
end

function add323(ahi::T, amd::T, alo::T, bhi::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = add_2(ahi, bhi)
    t2, t3 = add_2(amd, blo)
    t7, t4 = add_2(t1, t2)
    t5 = t3 + t4
    t8 = t5 + alo
    zmd, zlo = add_2(t7, t8)
    return zhi, zmd, zlo
end

@inline function add323(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return add323(a[1], a[2], a[3], b[1], b[2])
end

function add322(ahi::T, amd::T, alo::T, bhi::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = add_2(ahi, bhi)
    t2, t3 = add_2(amd, blo)
    t7, t4 = add_2(t1, t2)
    t5 = t3 + t4
    zmd = t5 + alo
    zmd += t7
    return zhi, zmd
end

@inline function add322(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return add322(a[1], a[2], a[3], b[1], b[2])
end

function add223(ahi::T, amd::T, bhi::T, bmd::T) where {T<:AbstractFloat}
    zhi, t1 = add_2(ahi, bhi)
    t2, t3 = add_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t5 = t3 + t4
    zmd, zlo = add_2(t7, t5)
    return zhi, zmd, zlo
end

@inline function add223(a::Tuple{T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return add223(a[1], a[2]f, b[1], b[2])
end


function add313(ahi::T, amd::T, alo::T, b::T) where {T<:AbstractFloat}
    zhi, t1 = add_2(ahi, b)
    t7, t4 = add_2(t1, amd)
    t8 = t4 + alo
    zmd, zlo = add_2(t7, t8)
    return zhi, zmd, zlo
end

add133(b::T, ahi::T, amd::T, alo::T) where {T<:AbstractFloat} = add313(ahi, amd, alo, b)

add313(a::Tuple(T,T,T), b::Tuple(T)) where {T<:AbstractFloat} =
    add313(a[1], a[2], a[3], b)
    
add133(b::Tuple(T), a::Tuple(T,T,T)) where {T<:AbstractFloat} =
    add313(a[1], a[2], a[3], b)


# subtraction

function sub333(ahi::T, amd::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = sub_2(ahi, bhi)
    t2, t3 = sub_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t6 = alo - blo
    t5 = t3 + t4
    t8 = t5 + t6
    zmd, zlo = add_2(t7, t8)
    return zhi, zmd, zlo
end

@inline function sub333(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return sub333(a[1], a[2], a[3], b[1], b[2], b[3])
end

function sub332(ahi::T, amd::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = sub_2(ahi, bhi)
    t2, t3 = sub_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t6 = alo - blo
    t5 = t3 + t4
    t8 = t5 + t6
    zmd = t7 + t8
    return zhi, zmd
end

@inline function sub332(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return sub332(a[1], a[2], a[3], b[1], b[2], b[3])
end

function sub323(ahi::T, amd::T, alo::T, bhi::T, bmd::T) where {T<:AbstractFloat}
    zhi, t1 = sub_2(ahi, bhi)
    t2, t3 = sub_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t5 = t3 + t4
    t8 = t5 + alo
    zmd, zlo = add_2(t7, t8)
    return zhi, zmd, zlo
end

@inline function sub323(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return sub323(a[1], a[2], a[3], b[1], b[2])
end

function sub322(ahi::T, amd::T, alo::T, bhi::T, bmd::T) where {T<:AbstractFloat}
    zhi, t1 = sub_2(ahi, bhi)
    t2, t3 = sub_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t5 = t3 + t4
    zmd = t5 + alo
    zmd += t7
    return zhi, zmd
end

@inline function sub322(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return sub322(a[1], a[2], a[3], b[1], b[2])
end

function sub233(ahi::T, amd::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = sub_2(ahi, bhi)
    t2, t3 = sub_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t5 = t3 + t4
    t8 = t5 - blo
    zmd, zlo = add_2(t7, t8)
    return zhi, zmd, zlo
end

@inline function sub233(a::Tuple{T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return sub233(a[1], a[2], b[1], b[2], b[3])
end

function sub232(ahi::T, amd::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = sub_2(ahi, bhi)
    t2, t3 = sub_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t5 = t3 + t4
    zmd = t5 - blo
    zmd += t7
    return zhi, zmd
end

@inline function sub232(a::Tuple{T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return sub232(a[1], a[2], b[1], b[2], b[3])
end

function sub223(ahi::T, amd::T, bhi::T, bmd::T) where {T<:AbstractFloat}
    zhi, t1 = sub_2(ahi, bhi)
    t2, t3 = sub_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t5 = t3 + t4
    zmd, zlo = add_2(t7, t5)
    return zhi, zmd, zlo
end

@inline function sub223(a::Tuple{T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return sub223(a[1], a[2], b[1], b[2])
end


function sub313(ahi::T, amd::T, alo::T, b::T) where {T<:AbstractFloat}
    zhi, t1 = sub_2(ahi, b)
    t7, t4 = add_2(t1, amd)
    t8 = t4 + alo
    zmd, zlo = add_2(t7, t8)
    return zhi, zmd, zlo
end

function sub312(ahi::T, amd::T, alo::T, b::T) where {T<:AbstractFloat}
    zhi, t1 = sub_2(ahi, b)
    t7, t4 = add_2(t1, amd)
    zlo = t4 + alo
    zlo += t7
    return zhi, zlo
end

sub313(a::Tuple(T,T,T), b::Tuple(T)) where {T<:AbstractFloat} =
    sub313(a[1], a[2], a[3], b)

sub312(a::Tuple(T,T,T), b::Tuple(T)) where {T<:AbstractFloat} =
    sub312(a[1], a[2], a[3], b)


# Algorithm 6.1
# (ahi,alo) * (bhi,blo) :: (zhi,zmd,zlo)

function mul223(ahi::T, alo::T, bhi::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = mul_2(ahi, bhi)
    t2, t3 = mul_2(ahi, blo)
    t4, t5 = mul_2(alo, bhi)
    t6 = alo * blo
    t7, t8 = add_2(t2, t3, t4, t5)
    t9, t10 = add_2(t1, t6)
    zmd, zlo = add_2(t7, t8, t9, t10)
    return zhi, zmd, zlo
end

@inline function mul223(a::Tuple{T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return mul223(a[1], a[2], b[1], b[2])
end


function mul323(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
  ahi, amd, alo = a
  bhi, blo = b
  p0,q0 = mul_2(ahi, bhi)
  p1,q1 = mul_2(ahi, blo)
  p2,q2 = mul_2(amd, bhi)
  p4,q4 = mul_2(amd, blo)
  p5,q5 = mul_2(alo, bhi)

  # Start Accumulation
  p1,p2,q0 = add_3(p1, p2, q0)

  # Six-Three Sum  of p2, q1, q2, p3, p4, p5
  p2,q1,q2 = add_3(p2, q1, q2)
  p3,p4 = add_2(p4, p5)
  # compute (s0, s1, s2) = (p2, q1, q2) + (p3, p4, p5)
  s0,t0 = add_2(p2, p3)
  s1,t1 = add_2(q1, p4)
  s2 = q2
  s1,t0 = add_2(s1, t0)
  s2 += (t0 + t1)

  # O(eps^3) order terms
  s1 += alo*blo + q0 + q4 + q5
  #p0,p1,s0 = renormAs3(p0, p1, s0, s1+s2)
  s1 += s2
  s0,s1 = add_hilo_2(s0,s1)
  p1,s0 = add_hilo_2(p1,s0)
  p0,p1 = add_hilo_2(p0,p1)

  return p0,p1,s0
end

function mul322(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
  ahi, amd, alo = a
  bhi, blo = b
  p0,q0 = mul_2(ahi, bhi)
  p1,q1 = mul_2(ahi, blo)
  p2,q2 = mul_2(amd, bhi)
  p4,q4 = mul_2(amd, blo)
  p5,q5 = mul_2(alo, bhi)

  # Start Accumulation
  p1,p2,q0 = add_3(p1, p2, q0)

  # Six-Three Sum  of p2, q1, q2, p3, p4, p5
  p2,q1,q2 = add_3(p2, q1, q2)
  p3,p4 = add_2(p4, p5)
  # compute (s0, s1, s2) = (p2, q1, q2) + (p3, p4, p5)
  s0,t0 = add_2(p2, p3)
  s1,t1 = add_2(q1, p4)
  s2 = q2
  s1,t0 = add_2(s1, t0)
  s2 += (t0 + t1)

  # O(eps^3) order terms
  s1 += alo*blo + q0 + q4 + q5
  #p0,p1,s0 = renormAs3(p0, p1, s0, s1+s2)
  s1 += s2
  s0 += s1
  p1 += s0
  p0,p1 = add_hilo_2(p0,p1)

  return p0,p1
end

mul233(a::Tuple{T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat} =
    mul323(b,a)

mul232(a::Tuple{T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat} =
    mul322(b,a)


function mul333(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    ahi, amd, alo = a
    bhi, bmd, blo = b

    hi,t1 = mul_2(ahi, bhi)
    t2,t3 = mul_2(ahi, bmd)
    t4,t5 = mul_2(amd, bhi)
    t6,t7 = mul_2(amd, bmd)

    t8  = ahi * blo
    t9  = alo * bhi
    t10 = amd * blo
    t11 = alo * bmd
    t12 = t8  + t9
    t13 = t10 + t11

    t14, t15 = add_hilo_2(t1, t6)

    t16 = t7  + t15
    t17 = t12 + t13
    t18 = t16 + t17

    t19, t20 = add_hilo_2(t14, t18)
    t21, t22 = add_hilo_2(t2, t3, t4, t5)
    md,  lo  = add_hilo_2(t21, t22, t19, t20)

    return hi, md, lo
end


function mul332(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    ahi, amd, alo = a
    bhi, bmd, blo = b

    hi,t1 = mul_2(ahi, bhi)
    t2,t3 = mul_2(ahi, bmd)
    t4,t5 = mul_2(amd, bhi)
    t6,t7 = mul_2(amd, bmd)

    t8  = ahi * blo
    t9  = alo * bhi
    t10 = amd * blo
    t11 = alo * bmd

    t14, lo = add_hilo_2(t1, t6)

    lo += t7
    lo += t8  + t9
    lo += t10 + t11
    lo += t16 + t17
    lo += t14
    lo += t5  + t4
    lo += t3  + t2

    return hi, lo
end


function mul313(a::Tuple{T,T,T}, b::Tuple{T}) where {T<:AbstractFloat}
  ahi, amd, alo = a
  p0,q0 = mul_2(ahi, b)
  p2,q2 = mul_2(amd, b)
  p5,q5 = mul_2(alo, b)

  # Start Accumulation
  p1,p2 = add_2(p2, q0)

  # Six-Three Sum  of p2, q1, q2, p3, 0, p5
  p2,q1,q2 = add_3(p2, q1, q2)

  # compute (s0, s1, s2) = (p2, q1, q2) + (p3, p4, p5)
  s0,t0 = add_2(p2, p5)
  s1,t1 = add_2(q1, 0)
  s2 = q2
  s1,t0 = add_2(s1, t0)
  s2 += (t0 + t1)

  # O(eps^3) order terms
  s1 += q0 + q5
  #p0,p1,s0 = renormAs3(p0, p1, s0, s1+s2)
  s1 += s2
  s0,s1 = add_hilo_2(s0,s1)
  p1,s0 = add_hilo_2(p1,s0)
  p0,p1 = add_hilo_2(p0,p1)

  return p0,p1,s0
end

mul133(a::Tuple{T], b::Tuple{T,T,T}) where {T<:AbstractFloat} = mul313(b, a)
    
function mul312(a::Tuple{T,T,T}, b::Tuple{T}) where {T<:AbstractFloat}
  ahi, amd, alo = a
  p0,q0 = mul_2(ahi, b)
  p2,q2 = mul_2(amd, b)
  p5,q5 = mul_2(alo, b)

  # Start Accumulation
  p1,p2 = add_2(p2, q0)

  # Six-Three Sum  of p2, q1, q2, p3, 0, p5
  p2,q1,q2 = add_3(p2, q1, q2)

  # compute (s0, s1, s2) = (p2, q1, q2) + (p3, p4, p5)
  s0,t0 = add_2(p2, p5)
  s1,t1 = add_2(q1, 0)
  s2 = q2
  s1,t0 = add_2(s1, t0)
  s2 += (t0 + t1)

  # O(eps^3) order terms
  s1 += q0 + q5
  #p0,p1,s0 = renormAs3(p0, p1, s0, s1+s2)
  s1 += s2
  s0 += s1
  p1 += s0
  p0,p1 = add_hilo_2(p0,p1)

  return p0,p1
end

mul132(a::Tuple{T], b::Tuple{T,T,T}) where {T<:AbstractFloat} = mul312(b, a)
