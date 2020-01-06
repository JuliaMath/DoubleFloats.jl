function triple(::Type{T}, x::BigFloat) where {T<:IEEEFloat}
    prec = precision(BigFloat)
    setprecision(BigFloat, 768)
    hi = T(x)
    md = T(x - hi)
    lo = T(x - hi - md)
    setprecision(BigFloat, prec)
    return hi, md, lo
end

function triple(::Type{T}, x::String) where {T<:IEEEFloat}
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

@inline function clean0s(hi::T, md::T, lo::T) where {T}
    if !iszero(hi)
        hi, md, lo
    elseif iszero(md)
        lo, md, hi
    else
        md, lo, hi
    end
end

@inline function clean0s(hi::T, lo::T) where {T}
    if !iszero(hi)
        hi, lo
    else
        lo, hi
    end
end


function triple_inv(::Type{T}, x::BigFloat) where {T<:IEEEFloat}
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

# Algorithm 3.3 [Triple-Double Building Blocks]

function renorm(hi::T, md::T, lo::T) where {T<:AbstractFloat}
    md, lo = two_sum(md, lo)
    hi, m  = two_sum(hi, md)
    md, lo = two_sum(m,  md)
    return hi, md, lo
end


function renorm_hilo(hi::T, md::T, lo::T) where {T<:AbstractFloat}
    md, lo = two_hilo_sum(md, lo)
    hi, m  = two_hilo_sum(hi, md)
    md, lo = two_hilo_sum(m,  md)
    return hi, md, lo
end

# Algorithm 4.1  (relerr 4.5 .. 16 u^2) [Triple-Double Building Blocks]

function add222(ahilo, bhilo)
    ahi, alo = ahilo
    bhi, blo = bhilo
    t1 = ahi + bhi
    if abs(ahi) >= abs(bhi)
        t2 = ahi - t1
        t3 = t2  + bhi
        t4 = t3  + blo
        t5 = t4  + alo
    else
        t2 = bhi - t1
        t3 = t2  + ahi
        t4 = t3  + alo
        t5 = t4  + blo
    end
    zhi, zlo = two_sum(t1, t5)
    zhi, zlo = clean0s(zhi, zlo)
    return zhi, zlo
end

"""
    _Basic building blocks for a triple-double intermediate format_

Christoph Quirin Lauter, 2005
""" TripleDouble_BuildingBlocks


# Algorithm 4.6  (relerr 16 u^2) [Triple-Double Building Blocks]
"""
    mul222( (ahi, alo), (bhi, blo) ) ↦ (chi, clo)

### Preconditions
- abs(alo) ≤ abs(ahi) * pow(2, -53)
- abs(blo) ≤ abs(bhi) * pow(2, -53)

### Postconditions
- abs(clo) ≤ abs(ahi) * pow(2, -53)
- chi + clo == ((ahi + alo) * (bhi + blo)) * (1 + ε), abs(ε) ≤ pow(2, -102)
- chi + clo == chi

#### [TripleDouble_BuildingBlocks](@ref)
"""
function mul222(ahilo, bhilo)
    ahi, alo = ahilo
    bhi, blo = bhilo
    t1, t2 = two_prod(ahi, bhi)
    t3 = ahi * blo
    t4 = alo * bhi
    t5 = t3 + t4
    t6 = t2 + t5
    zhi, zlo = two_sum(t1, t6)
    return zhi, zlo
end

# addition

# Algorithm 5.1 (Add33) [Triple-Double Building Blocks]
# (ahi,amd,alo) + (bhi,bmd,blo) :: (zhi,zmd,zlo)

function add333(ahi::T, amd::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = two_sum(ahi, bhi)
    t2, t3 = two_sum(amd, bmd)
    t7, t4 = two_sum(t1, t2)
    t6 = alo + blo
    t5 = t3 + t4
    t8 = t5 + t6
    zmd, zlo = two_sum(t7, t8)
    zhi, zmd, zlo = clean0s(zhi,zmd,zlo)
    return zhi, zmd, zlo
end

@inline function add333(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return add333(a[1], a[2], a[3], b[1], b[2], b[3])
end

function add332(ahi::T, amd::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = two_sum(ahi, bhi)
    t2, t3 = two_sum(amd, bmd)
    t7, t4 = two_sum(t1, t2)
    t6 = alo + blo
    t5 = t3 + t4
    zmd = t5 + t6
    zmd += t7
    zhi, zmd = clean0s(zhi, zmd)
    return zhi, zmd
end

@inline function add332(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return add332(a[1], a[2], a[3], b[1], b[2], b[3])
end

function add323(ahi::T, amd::T, alo::T, bhi::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = two_sum(ahi, bhi)
    t2, t3 = two_sum(amd, blo)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    t8 = t5 + alo
    zmd, zlo = two_sum(t7, t8)
    zhi, zmd, zlo = clean0s(zhi,zmd,zlo)
    return zhi, zmd, zlo
end

@inline function add323(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return add323(a[1], a[2], a[3], b[1], b[2])
end

function add322(ahi::T, amd::T, alo::T, bhi::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = two_sum(ahi, bhi)
    t2, t3 = two_sum(amd, blo)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    zmd = t5 + alo
    zmd += t7
    zhi, zmd = clean0s(zhi, zmd)
    return zhi, zmd
end

@inline function add322(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return add322(a[1], a[2], a[3], b[1], b[2])
end

function add223(ahi::T, amd::T, bhi::T, bmd::T) where {T<:AbstractFloat}
    zhi, t1 = two_sum(ahi, bhi)
    t2, t3 = two_sum(amd, bmd)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    zmd, zlo = two_sum(t7, t5)
    zhi, zmd, zlo = clean0s(zhi,zmd,zlo)
    return zhi, zmd, zlo
end

@inline function add223(a::Tuple{T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return add223(a[1], a[2], b[1], b[2])
end


function add313(ahi::T, amd::T, alo::T, b::T) where {T<:AbstractFloat}
    zhi, t1 = two_sum(ahi, b)
    t7, t4 = two_sum(t1, amd)
    t8 = t4 + alo
    zmd, zlo = two_sum(t7, t8)
    zhi, zmd, zlo = clean0s(zhi,zmd,zlo)
    return zhi, zmd, zlo
end

add133(b::T, ahi::T, amd::T, alo::T) where {T<:AbstractFloat} = add313(ahi, amd, alo, b)

add313(a::NTuple{3,T}, b::NTuple{1,T}) where {T<:AbstractFloat} =
    add313(a[1], a[2], a[3], b[1])

add133(b::NTuple{1,T}, a::NTuple{3,T}) where {T<:AbstractFloat} =
    add313(a[1], a[2], a[3], b[1])


# subtraction

function sub333(ahi::T, amd::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = two_diff(ahi, bhi)
    t2, t3 = two_diff(amd, bmd)
    t7, t4 = two_sum(t1, t2)
    t6 = alo - blo
    t5 = t3 + t4
    t8 = t5 + t6
    zmd, zlo = two_sum(t7, t8)
    zhi, zmd, zlo = clean0s(zhi,zmd,zlo)
    return zhi, zmd, zlo
end

@inline function sub333(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return sub333(a[1], a[2], a[3], b[1], b[2], b[3])
end

function sub332(ahi::T, amd::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = two_diff(ahi, bhi)
    t2, t3 = two_diff(amd, bmd)
    t7, t4 = two_sum(t1, t2)
    t6 = alo - blo
    t5 = t3 + t4
    t8 = t5 + t6
    zmd = t7 + t8
    zhi, zmd = clean0s(zhi, zmd)
    return zhi, zmd
end

@inline function sub332(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return sub332(a[1], a[2], a[3], b[1], b[2], b[3])
end

function sub323(ahi::T, amd::T, alo::T, bhi::T, bmd::T) where {T<:AbstractFloat}
    zhi, t1 = two_diff(ahi, bhi)
    t2, t3 = two_diff(amd, bmd)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    t8 = t5 + alo
    zmd, zlo = two_sum(t7, t8)
    zhi, zmd, zlo = clean0s(zhi,zmd,zlo)
    return zhi, zmd, zlo
end

@inline function sub323(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return sub323(a[1], a[2], a[3], b[1], b[2])
end

function sub322(ahi::T, amd::T, alo::T, bhi::T, bmd::T) where {T<:AbstractFloat}
    zhi, t1 = two_diff(ahi, bhi)
    t2, t3 = two_diff(amd, bmd)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    zmd = t5 + alo
    zmd += t7
    zhi, zmd = clean0s(zhi, zmd)
    return zhi, zmd
end

@inline function sub322(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return sub322(a[1], a[2], a[3], b[1], b[2])
end

function sub233(ahi::T, amd::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = two_diff(ahi, bhi)
    t2, t3 = two_diff(amd, bmd)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    t8 = t5 - blo
    zmd, zlo = two_sum(t7, t8)
    zhi, zmd, zlo = clean0s(zhi,zmd,zlo)
    return zhi, zmd, zlo
end

@inline function sub233(a::Tuple{T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return sub233(a[1], a[2], b[1], b[2], b[3])
end

function sub232(ahi::T, amd::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = two_diff(ahi, bhi)
    t2, t3 = two_diff(amd, bmd)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    zmd = t5 - blo
    zmd += t7
    zhi, zmd = clean0s(zhi, zmd)
    return zhi, zmd
end

@inline function sub232(a::Tuple{T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return sub232(a[1], a[2], b[1], b[2], b[3])
end

function sub223(ahi::T, amd::T, bhi::T, bmd::T) where {T<:AbstractFloat}
    zhi, t1 = two_diff(ahi, bhi)
    t2, t3 = two_diff(amd, bmd)
    t7, t4 = two_sum(t1, t2)
    t5 = t3 + t4
    zmd, zlo = two_sum(t7, t5)
    zhi, zmd, zlo = clean0s(zhi,zmd,zlo)
    return zhi, zmd, zlo
end

@inline function sub223(a::Tuple{T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return sub223(a[1], a[2], b[1], b[2])
end


function sub313(ahi::T, amd::T, alo::T, b::T) where {T<:AbstractFloat}
    zhi, t1 = two_diff(ahi, b)
    t7, t4 = two_sum(t1, amd)
    t8 = t4 + alo
    zmd, zlo = two_sum(t7, t8)
    zhi, zmd, zlo = clean0s(zhi,zmd,zlo)
    return zhi, zmd, zlo
end

function sub312(ahi::T, amd::T, alo::T, b::T) where {T<:AbstractFloat}
    zhi, t1 = two_diff(ahi, b)
    t7, t4 = two_sum(t1, amd)
    zlo = t4 + alo
    zlo += t7
    zhi, zlo = clean0s(zhi, zlo)
    return zhi, zlo
end

sub313(a::NTuple{3,T}, b::NTuple{1,T}) where {T<:AbstractFloat} =
    sub313(a[1], a[2], a[3], b)

sub312(a::NTuple{3,T}, b::NTuple{1,T}) where {T<:AbstractFloat} =
    sub312(a[1], a[2], a[3], b)


# Algorithm 6.1 [Triple-Double Building Blocks]
# (ahi,alo) * (bhi,blo) :: (zhi,zmd,zlo)

function mul223(ahi::T, alo::T, bhi::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = two_prod(ahi, bhi)
    t2, t3 = two_prod(ahi, blo)
    t4, t5 = two_prod(alo, bhi)
    t6 = alo * blo
    t7, t8 = two_sum(t2, t3, t4, t5)
    t9, t10 = two_sum(t1, t6)
    zmd, zlo = two_sum(t7, t8, t9, t10)
    return zhi, zmd, zlo
end

@inline function mul223(a::Tuple{T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return mul223(a[1], a[2], b[1], b[2])
end

function mul323(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
  ahi, amd, alo = a
  bhi, blo = b
  p0,q0 = two_prod(ahi, bhi)
  p1,q1 = two_prod(ahi, blo)
  p2,q2 = two_prod(amd, bhi)
  p4,q4 = two_prod(amd, blo)
  p5,q5 = two_prod(alo, bhi)

  # Start Accumulation
  p1,p2,q0 = three_sum(p1, p2, q0)

  # Six-Three Sum  of p2, q1, q2, p3, p4, p5
  p2,q1,q2 = three_sum(p2, q1, q2)
  p3,p4 = two_sum(p4, p5)
  # compute (s0, s1, s2) = (p2, q1, q2) + (p3, p4, p5)
  s0,t0 = two_sum(p2, p3)
  s1,t1 = two_sum(q1, p4)
  s2 = q2
  s1,t0 = two_sum(s1, t0)
  s2 += (t0 + t1)

  # O(eps^3) order terms
  s1 += alo*blo + q0 + q4 + q5
  #p0,p1,s0 = renormAs3(p0, p1, s0, s1+s2)
  s1 += s2
  s0,s1 = two_hilo_sum(s0,s1)
  p1,s0 = two_hilo_sum(p1,s0)
  p0,p1 = two_hilo_sum(p0,p1)

  return p0,p1,s0
end

mul323(a::Tuple{Float64, Float64, Float64}, b::Tuple{Float32, Float32}) =
    mul323(a, (Float64(b[1]), Float64(b[2])) )
mul323(a::Tuple{Float32, Float32, Float32}, b::Tuple{Float64, Float64}) =
    mul323((Float64(a[1]), Float64(a[2]), Float64(a[3])), b)


function mul322(a::Tuple{T,T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
  ahi, amd, alo = a
  bhi, blo = b
  p0,q0 = two_prod(ahi, bhi)
  p1,q1 = two_prod(ahi, blo)
  p2,q2 = two_prod(amd, bhi)
  p4,q4 = two_prod(amd, blo)
  p5,q5 = two_prod(alo, bhi)

  # Start Accumulation
  p1,p2,q0 = three_sum(p1, p2, q0)

  # Six-Three Sum  of p2, q1, q2, p3, p4, p5
  p2,q1,q2 = three_sum(p2, q1, q2)
  p3,p4 = two_sum(p4, p5)
  # compute (s0, s1, s2) = (p2, q1, q2) + (p3, p4, p5)
  s0,t0 = two_sum(p2, p3)
  s1,t1 = two_sum(q1, p4)
  s2 = q2
  s1,t0 = two_sum(s1, t0)
  s2 += (t0 + t1)

  # O(eps^3) order terms
  s1 += alo*blo + q0 + q4 + q5
  #p0,p1,s0 = renormAs3(p0, p1, s0, s1+s2)
  s1 += s2
  s0 += s1
  p1 += s0
  p0,p1 = two_hilo_sum(p0,p1)

  return p0,p1
end

mul322(a::Tuple{Float64, Float64, Float64}, b::Tuple{Float32, Float32}) =
    mul322(a, (Float64(b[1]), Float64(b[2])) )
mul322(a::Tuple{Float32, Float32, Float32}, b::Tuple{Float64, Float64}) =
    mul322((Float64(a[1]), Float64(a[2]), Float64(a[3])), b)


mul233(a::Tuple{T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat} =
    mul323(b,a)

mul232(a::Tuple{T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat} =
    mul322(b,a)


function mul333(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    ahi, amd, alo = a
    bhi, bmd, blo = b

    hi,t1 = two_prod(ahi, bhi)
    t2,t3 = two_prod(ahi, bmd)
    t4,t5 = two_prod(amd, bhi)
    t6,t7 = two_prod(amd, bmd)

    t8  = ahi * blo
    t9  = alo * bhi
    t10 = amd * blo
    t11 = alo * bmd
    t12 = t8  + t9
    t13 = t10 + t11

    t14, t15 = two_hilo_sum(t1, t6)

    t16 = t7  + t15
    t17 = t12 + t13
    t18 = t16 + t17

    t19, t20 = two_hilo_sum(t14, t18)
    t21, t22 = two_hilo_sumof4(t2, t3, t4, t5)
    md,  lo  = two_hilo_sumof4(t21, t22, t19, t20)

    return hi, md, lo
end


mul333(a::Tuple{Float64, Float64, Float64}, b::Tuple{Float32, Float32, Float32}) =
    mul333(a, (Float64(b[1]), Float64(b[2]), Float64(b[3])) )
mul333(a::Tuple{Float32, Float32, Float32}, b::Tuple{Float64, Float64, Float64}) =
    mul333((Float64(a[1]), Float64(a[2]), Float64(a[3])), b)


function mul332(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    ahi, amd, alo = a
    bhi, bmd, blo = b

    hi,t1 = two_prod(ahi, bhi)
    t2,t3 = two_prod(ahi, bmd)
    t4,t5 = two_prod(amd, bhi)
    t6,t7 = two_prod(amd, bmd)

    t8  = ahi * blo
    t9  = alo * bhi
    t10 = amd * blo
    t11 = alo * bmd

    t14, lo = two_hilo_sum(t1, t6)

    lo += t7
    lo += t8  + t9
    lo += t10 + t11
    lo += t16 + t17
    lo += t14
    lo += t5  + t4
    lo += t3  + t2

    return hi, lo
end

mul332(a::Tuple{Float64, Float64, Float64}, b::Tuple{Float32, Float32, Float32}) =
    mul332(a, (Float64(b[1]), Float64(b[2]), Float64(b[3])) )
mul332(a::Tuple{Float32, Float32, Float32}, b::Tuple{Float64, Float64, Float64}) =
    mul332((Float64(a[1]), Float64(a[2]), Float64(a[3])), b)

function mul313(a::Tuple{T,T,T}, b::Tuple{T}) where {T<:AbstractFloat}
  ahi, amd, alo = a
  bhi = b[1]
  p0,q0 = two_prod(ahi, bhi)
  p2,q2 = two_prod(amd, bhi)
  p5,q5 = two_prod(alo, bhi)

  # Start Accumulation
  p1,p2 = two_sum(p2, q0)

  p2,q1 = two_sum(p2, q2)

  s0,t0 = two_sum(p2, p5)
  s1,t0 = two_sum(q1, t0)

  # O(eps^3) order terms
  s1 += q5
  #p0,p1,s0 = renormAs3(p0, p1, s0, s1+s2)
  s1 += t0
  s0,s1 = two_hilo_sum(s0,s1)
  p1,s0 = two_hilo_sum(p1,s0)
  p0,p1 = two_hilo_sum(p0,p1)

  return p0,p1,s0
end

        
mul133(a::NTuple{1,T}, b::NTuple{3,T}) where {T<:AbstractFloat} = mul313(b, a)


function mul312(a::Tuple{T,T,T}, b::Tuple{T}) where {T<:AbstractFloat}
  ahi, amd, alo = a
  bhi = b[1]
  p0,q0 = two_prod(ahi, bhi)
  p2,q2 = two_prod(amd, bhi)
  p5,q5 = two_prod(alo, bhi)

  # Start Accumulation
  p1,p2 = two_sum(p2, q0)

  p2,q1 = two_sum(p2, q2)

  s0,t0 = two_sum(p2, p5)
  s1,t0 = two_sum(q1, t0)

  # O(eps^3) order terms
  s1 += q5
  #p0,p1,s0 = renormAs3(p0, p1, s0, s1+s2)
  s1 += t0
  p1 = p1 + (s0 + s1)
  p0,p1 = two_hilo_sum(p0,p1)

  return p0,p1
end


mul132(a::NTuple{1,T}, b::NTuple{3,T}) where {T<:AbstractFloat} = mul312(b, a)


function muladd222(a::Tuple{T,T}, b::Tuple{T,T}, c::Tuple{T,T}) where {T<:AbstractFloat}
    m = mul223(a, b)
    hi, lo = add322(m, c)
    return hi, lo
end
