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

@inline add333(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return add333(a[1], a[2], a[3], b[1], b[2], b[3])
end

# Algorithm 5.2 (Add233)
# (ahi,alo) + (bhi,bmd,blo) :: (zhi,zmd,zlo)

function add233(ahi::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = add_2(ahi, bhi)
    t2, t3  = add_2(alo, bmd)
    t4, t5  = add_2(t1, t2)
    t6 = t3 + blo
    t7 = t6 + t5
    zmd, zlo = add_2(t4, t7)
    return zhi, zmd, zlo
end

@inline add233(a::Tuple{T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return add223(a[1], a[2], b[1], b[2], b[3])
end

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

@inline mul223(a::Tuple{T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
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


# directed rounding of (ahi,amd,alo) to (zhi,zlo)

#=
    •    RoundNearest (default)
      
    •    RoundNearestTiesAway
      
    •    RoundNearestTiesUp
      
    •    RoundToZero
      
    •    RoundFromZero (BigFloat only)
      
    •    RoundUp
      
    •    RoundDown
=#

@inline function rounded(fn::Function, a::T, 
                         mode::RoundingMode) where {T<:AbstractFloat}
     setrounding(T, mode) do
         fn(a)
     end
end

@inline function rounded(fn::Function, a::T, b::T, 
                         mode::RoundingMode) where {T<:AbstractFloat}
     setrounding(T, mode) do
         fn(a, b)
     end
end

@inline function rounded(fn::Function, a::T, b::T, c::T, 
                         mode::RoundingMode) where {T<:AbstractFloat}
     setrounding(T, mode) do
         fn(a, b, c)
     end
end

@inline function rounded(fn::Function, a::T, b::T, c::T, d::T,
                         mode::RoundingMode) where {T<:AbstractFloat}
     setrounding(T, mode) do
         fn(a, b, c, d)
     end
end


@inline round_nearest(fn::Function, a::T) where {T<:AbstractFloat} =
    rounded(fn, a, RoundNearest)
@inline round_nearest(fn::Function, a::T, b::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, RoundNearest)
@inline round_nearest(fn::Function, a::T, b::T, c::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, RoundNearest)
@inline round_nearest(fn::Function, a::T, b::T, c::T, d::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, d, RoundNearest)

@inline round_nearest_tiesaway(fn::Function, a::T) where {T<:AbstractFloat} =
    rounded(fn, a, RoundNearestTiesAway)
@inline round_nearest_tiesaway(fn::Function, a::T, b::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, RoundNearestTiesAway)
@inline round_nearest_tiesaway(fn::Function, a::T, b::T, c::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, RoundNearestTiesAway)
@inline round_nearest_tiesaway(fn::Function, a::T, b::T, c::T, d::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, d, RoundNearestTiesAway)

@inline round_nearest_tiesup(fn::Function, a::T) where {T<:AbstractFloat} =
    rounded(fn, a, RoundNearestTiesUp)
@inline round_nearest_tiesup(fn::Function, a::T, b::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, RoundNearestTiesUp)
@inline round_nearest_tiesup(fn::Function, a::T, b::T, c::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, RoundNearestTiesUp)
@inline round_nearest_tiesup(fn::Function, a::T, b::T, c::T, d::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, d, RoundNearestTiesUp)

@inline round_up(fn::Function, a::T) where {T<:AbstractFloat} =
    rounded(fn, a, RoundUp)
@inline round_up(fn::Function, a::T, b::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, RoundUp)
@inline round_up(fn::Function, a::T, b::T, c::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, RoundUp)
@inline round_up(fn::Function, a::T, b::T, c::T, d::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, d, RoundUp)

@inline round_down(fn::Function, a::T) where {T<:AbstractFloat} =
    rounded(fn, a, RoundDown)
@inline round_down(fn::Function, a::T, b::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, RoundDown)
@inline round_down(fn::Function, a::T, b::T, c::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, RoundDown)
@inline round_down(fn::Function, a::T, b::T, c::T, d::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, d, RoundDown)

@inline round_tozero(fn::Function, a::T) where {T<:AbstractFloat} =
    rounded(fn, a, RoundToZero)
@inline round_tozero(fn::Function, a::T, b::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, RoundToZero)
@inline round_tozero(fn::Function, a::T, b::T, c::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, RoundToZero)
@inline round_tozero(fn::Function, a::T, b::T, c::T, d::T) where {T<:AbstractFloat} =
    rounded(fn, a, b, c, d, RoundToZero)

@inline round_fromzero(fn::Function, a::T) where {T<:BigFloat} =
    rounded(fn, a, RoundFromZero)
@inline round_fromzero(fn::Function, a::T, b::T) where {T<:BigFloat} =
    rounded(fn, a, b, RoundFromZero)
@inline round_fromzero(fn::Function, a::T, b::T, c::T) where {T<:BigFloat} =
    rounded(fn, a, b, c, RoundFromZero)
@inline round_fromzero(fn::Function, a::T, b::T, c::T, d::T) where {T<:BigFloat} =
    rounded(fn, a, b, c, d, RoundFromZero)

# other Floats

@inline round_fromzero(fn::Function, a::T) where {T<:AbstractFloat} =
    -rounded(fn, -a, RoundToZero)
@inline round_fromzero(fn::Function, a::T, b::T) where {T<:AbstractFloat} =
    -rounded(fn, -a, -b, RoundToZero)
@inline round_fromzero(fn::Function, a::T, b::T, c::T) where {T<:AbstractFloat} =
    -rounded(fn, -a, -b, -c, RoundToZero)
@inline round_fromzero(fn::Function, a::T, b::T, c::T, d::T) where {T<:AbstractFloat} =
    -rounded(fn, -a, -b, -c, -d, RoundToZero)
