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

#=
#   roundnearest2(ahi,amd,alo)::(zhi,zmd)
#   roundnearest1(amd,alo)::(carry_borrow_able,zmd)
#   roundnearest2(ahi,amd,alo)
#      zhi = ahi + carry_borrow_able
#      zmd = roundnearest(alo)
#      zhi, zmd
=#

function roundnearest(hi::T, md::T, lo::T) where {T<:AbstractFloat}

end

largest_significand(::Type{Float64}) = prevfloat(one(Float64))
second_significand(::Type{Float64})  = nextfloat(one(Float64)/2)
largest_significand(::Type{Float32}) = prevfloat(one(Float32))
second_significand(::Type{Float32})  = nextfloat(one(Float32)/2)
largest_significand(::Type{Float16}) = prevfloat(one(Float16))
second_significand(::Type{Float16})  = nextfloat(one(Float16)/2)

