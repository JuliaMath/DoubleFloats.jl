#=

Basic building blocks for a triple-double intermediate format
Christoph Quirin Lauter
Thème NUM — Systèmes numériques, Projet Arénaire
Rapport de recherche n 5702 — Septembre 2005 — 67 pages


=#

# Algorithm 3.3

function renorm3(hi::T, md::T, lo::T) where {T<:AbstractFloat}
    md, lo = add_2(md, lo)
    hi, m  = add_2(hi, md)
    md, lo = add_2(m,  md)
    return hi, md, lo
end

# Algorithm 4.1  (relerr 4.5 .. 16 u^2)

function add(ahilo, bhilo)
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

function mul(ahilo, bhilo)
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

function add(ahi::T, amd::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = add_2(ahi, bhi
    t2, t3 = add_2(amd, bmd)
    t7, t4 = add_2(t1, t2)
    t6 = alo + blo
    t5 = t3 + t4
    t8 = t5 + t6
    zmd, zlo = add_2(t7, t8)
    return zhi, zmd, zlo
end

@inline add(a::Tuple{T,T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return add(a[1], a[2], a[3], b[1], b[2], b[3])
end

# Algorithm 5.2 (Add233)
# (ahi,alo) + (bhi,bmd,blo) :: (zhi,zmd,zlo)

function add(ahi::T, alo::T, bhi::T, bmd::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = add_2(ahi, bhi)
    t2, t3  = add_2(alo, bmd)
    t4, t5  = add_2(t1, t2)
    t6 = t3 + blo
    t7 = t6 + t5
    zmd, zlo = add_2(t4, t7)
    return zhi, zmd, zlo
end

@inline add(a::Tuple{T,T}, b::Tuple{T,T,T}) where {T<:AbstractFloat}
    return add(a[1], a[2], b[1], b[2], b[3])
end

# Algorithm 6.1
# (ahi,alo) * (bhi,blo) :: (zhi,zmd,zlo)

function mul_3(ahi::T, alo::T, bhi::T, blo::T) where {T<:AbstractFloat}
    zhi, t1 = mul_2(ahi, bhi)
    t2, t3 = mul_2(ahi, blo)
    t4, t5 = mul_2(alo, bhi)
    t6 = alo * blo
    t7, t8 - add_2(t2, t3, t4, t5)
    t9, t10 = add_2(t1, t6)
    zmd, zlo = add_2(t7, t8, t9, t10)
    return zhi, zmd, zlo
end

@inline mul_3(a::Tuple{T,T}, b::Tuple{T,T}) where {T<:AbstractFloat}
    return mul_3(a[1], a[2], b[1], b[2])
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
