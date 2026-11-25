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

"""
    _Basic building blocks for a triple-double intermediate format_

Christoph Quirin Lauter, 2005
Thème NUM — Systèmes numériques, Projet Arénaire
Rapport de recherche n 5702 — Septembre 2005 — 67 pages
""" TripleDouble_BuildingBlocks

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
    t21, t22 = two_hilo_sum(t2, t3, t4, t5)
    md,  lo  = two_hilo_sum(t21, t22, t19, t20)

    return hi, md, lo
end


mul333(a::Tuple{Float64, Float64, Float64}, b::Tuple{Float32, Float32, Float32}) =
    mul333(a, (Float64(b[1]), Float64(b[2]), Float64(b[3])) )
mul333(a::Tuple{Float32, Float32, Float32}, b::Tuple{Float64, Float64, Float64}) =
    mul333((Float64(a[1]), Float64(a[2]), Float64(a[3])), b)
