#=
   algorithms from
   Mioara Joldes, Jean-Michel Muller, Valentina Popescu.
   Tight and rigourous error bounds for basic building blocks of double-word arithmetic.
   ACM Transactions on Mathematical Software, Association for Computing Machinery,
   2017, 44 (2), pp.1 - 27. <10.1145/3121432>. <hal-01351529v3>
=#


# Algorithm 1 in ref
@inline function Fast2Sum(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    z = s - a
    t = b - z
    return s, t
end

# Algorithm 2 in ref
function TwoSum(a::T, b::T) where {T<:AbstractFloat}
    s  = a + b
    a1 = s - b
    b1 = s - a1
    da = a - a1
    db = b - b1
    t  = da + db
    return s, t
end

# Algorithm 3 in ref
@inline function Fast2Mult(a::T, b::T) where {T<:AbstractFloat}
    s = a * b
    t = fma(a, b, -s)
    return s, t
end

# Algorithm 4 in ref
@inline function DWPlusFP(xₕᵢ::T, xₗₒ::T, y::T) where {T<:AbstractFloat}
    sₕᵢ, sₗₒ = TwoSum(xₕᵢ, y)
    v = xₗₒ + sₗₒ
    zₕᵢ, zₗₒ = TwoSum(sₕᵢ, v)
    return zₕᵢ, zₗₒ
end

# Algorithm 9 in ref
@inline function DWTimesFP3(xₕᵢ::T, xₗₒ::T, y::T) where {T<:AbstractFloat}
    cₕᵢ, cₗₒ = Fast2Mult(xₕᵢ, y)
    c = fma(xₗₒ, y, cₗₒ)
    zₕᵢ, zₗₒ = Fast2Sum(cₕᵢ, c)
    return zₕᵢ, zₗₒ
end

# Algorithm 11 in ref
function DWTimesDW2(xₕᵢ::T, xₗₒ::T, yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   cₕᵢ, c1 = Fast2Mult(xₕᵢ, yₕᵢ)
   t0 = xₗₒ * yₗₒ
   c2 = fma(xₗₒ, yₕᵢ, t0)
   c3 = c1 + c2
   zₕᵢ, zₗₒ = Fast2Sum(cₕᵢ, c3)
   return zₕᵢ, zₗₒ
end

# Algorithm 12 in ref
function DWTimesDW3(xₕᵢ::T, xₗₒ::T, yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   cₕᵢ, c1 = Fast2Mult(xₕᵢ, yₕᵢ)
   t0 = xₗₒ * yₗₒ
   t1 = fma(xₕᵢ, yₗₒ, t0)
   c2 = fma(xₗₒ, yₕᵢ, t1)
   c3 = c1 + c2
   zₕᵢ, zₗₒ = Fast2Sum(cₕᵢ, c3)
   return zₕᵢ, zₗₒ
end

# Algorithm 18 in ref 
# (note DWTimesDW3 replaces DWTimesDW2 per ref) 
function DWDivDW3(xₕᵢ::T, xₗₒ::T, yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   tₕᵢ = inv(yₕᵢ)
   rₕᵢ = fma(yₕᵢ, -tₕᵢ, one(T))
   rₗₒ = -(yₗₒ * tₕᵢ)
   eₕᵢ, eₗₒ = Fast2Sum(rₕᵢ, rₗₒ)
   dₕᵢ, dₗₒ = DWTimesFP3(eₕᵢ, eₗₒ, tₕᵢ)
   mₕᵢ, mₗₒ = DWPlusFP(dₕᵢ, dₗₒ, tₕᵢ)
   zₕᵢ, zₗₒ = DWTimesDW3(xₕᵢ, xₗₒ, mₕᵢ, mₗₒ)
   return zₕᵢ, zₗₒ
end

   
 
   
