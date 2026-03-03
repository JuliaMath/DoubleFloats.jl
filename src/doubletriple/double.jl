#=
   algorithms from
   Mioara Joldes, Jean-Michel Muller, Valentina Popescu.
   Tight and rigourous error bounds for basic building blocks of double-word arithmetic.
   ACM Transactions on Mathematical Software, Association for Computing Machinery,
   2017, 44 (2), pp.1 - 27. <10.1145/3121432>. <hal-01351529v3>

   they recommend

   > For adding two double-word numbers, use Algorithm 6.
     Use Algorithm 5 only if both operands have the same sign.

  > For multiplying a double-word number by a floating-point number,
    where FMA is available, use Algorithm 9.

  > For multiplying two double-word numbers, if an FMA instruction
    is available, then Algorithm 12 is to be favored.

  > For dividing a double-word number by a floating-point number,
    use Algorithm 15.

  > For dividing two double-word numbers: Algorithm 17 is suggested.
    If an FMA instruction is available, and accuracy is important,
    prefer Algorithm 18 (it is slower).

=#


# Algorithm 1 in ref: error-free transformation

@inline function Fast2Sum(a::T, b::T) where {T<:AbstractFloat}
    s = a + b
    z = s - a
    t = b - z
    return s, t
end

# Algorithm 2 in ref: error-free transformation

function TwoSum(a::T, b::T) where {T<:AbstractFloat}
    s  = a + b
    a1 = s - b
    b1 = s - a1
    da = a - a1
    db = b - b1
    t  = da + db
    return s, t
end

# Algorithm 3 in ref: error-free transformation

@inline function Fast2Mult(a::T, b::T) where {T<:AbstractFloat}
    s = a * b
    t = fma(a, b, -s)
    return s, t
end

# Algorithm 4 in ref: relerr 2u²  [reltime 26]

@inline function DWPlusFP(xₕᵢ::T, xₗₒ::T, y::T) where {T<:AbstractFloat}
    sₕᵢ, sₗₒ = TwoSum(xₕᵢ, y)
    v = xₗₒ + sₗₒ
    zₕᵢ, zₗₒ = TwoSum(sₕᵢ, v)
    return zₕᵢ, zₗₒ
end

# Algorithm 9 in ref: relerr 2u²  [reltime 15]

@inline function DWTimesFP3(xₕᵢ::T, xₗₒ::T, y::T) where {T<:AbstractFloat}
    cₕᵢ, cₗₒ = Fast2Mult(xₕᵢ, y)
    c = fma(xₗₒ, y, cₗₒ)
    zₕᵢ, zₗₒ = Fast2Sum(cₕᵢ, c)
    return zₕᵢ, zₗₒ
end

# inv(...) using Algorithms 17 and 18

# Algorithm 18 in ref: relerr < 10u² (6u² seen)  [reltime 72]

function DWInvDW3(yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   tₕᵢ = inv(yₕᵢ)
   rₕᵢ = fma(yₕᵢ, -tₕᵢ, one(T))
   rₗₒ = -(yₗₒ * tₕᵢ)
   eₕᵢ, eₗₒ = Fast2Sum(rₕᵢ, rₗₒ)
   dₕᵢ, dₗₒ = DWTimesFP3(eₕᵢ, eₗₒ, tₕᵢ)
   zₕᵢ, zₗₒ = DWPlusFP(dₕᵢ, dₗₒ, tₕᵢ)
   return zₕᵢ, zₗₒ
end
