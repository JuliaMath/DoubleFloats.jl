function double(::Type{T}, x::BigFloat) where {T<:IEEEFloat}
    prec = precision(BigFloat)
    setprecision(BigFloat, max(prec, 768))
    hi = T(x)
    lo = T(x - hi)
    setprecision(BigFloat, prec)
    return hi, lo
end

function double(::Type{T}, x::String) where {T<:IEEEFloat}
    prec = precision(BigFloat)
    setprecision(BigFloat, 768)
    z = parse(BigFloat, x)
    hi = T(z)
    lo = T(z - hi)
    setprecision(BigFloat, prec)
    return hi, lo
end

double64(x::BigFloat) = double(Float64, x)
double32(x::BigFloat) = double(Float32, x)
double16(x::BigFloat) = double(Float16, x)

double64(x::String) = double(Float64, x)
double32(x::String) = double(Float32, x)
double16(x::String) = double(Float16, x)

function double_inv(::Type{T}, x::BigFloat) where {T<:IEEEFloat}
    prec = precision(BigFloat)
    setprecision(BigFloat, max(prec, 768))
    x = inv(x)
    hi = T(x)
    lo = T(x - hi)
    setprecision(BigFloat, prec)
    return hi, lo
end

double64inv(x::BigFloat) = double_inv(Float64, x)
double32inv(x::BigFloat) = double_inv(Float32, x)
double16inv(x::BigFloat) = double_inv(Float16, x)

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

function TwoDiff(a::T, b::T) where {T<:AbstractFloat}
    s  = a - b
    a1 = s + b
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

@inline function DWMinusFP(xₕᵢ::T, xₗₒ::T, y::T) where {T<:AbstractFloat}
    sₕᵢ, sₗₒ = TwoDiff(xₕᵢ, y)
    v = xₗₒ + sₗₒ
    zₕᵢ, zₗₒ = TwoSum(sₕᵢ, v)
    return zₕᵢ, zₗₒ
end

# Algorithm 6 in ref: relerr  3u² + 13u³  [reltime 35]

function AccurateDWPlusDW(xₕᵢ::T, xₗₒ::T, yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   sₕᵢ, sₗₒ = TwoSum(xₕᵢ, yₕᵢ)
   tₕᵢ, tₗₒ = TwoSum(xₗₒ, yₗₒ)
   c = sₗₒ + tₕᵢ
   vₕᵢ, vₗₒ = Fast2Sum(sₕᵢ, c)
   w = tₗₒ + vₗₒ
   zₕᵢ, zₗₒ = Fast2Sum(vₕᵢ, w)
   return zₕᵢ, zₗₒ
end

function AccurateDWMinusDW(xₕᵢ::T, xₗₒ::T, yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   sₕᵢ, sₗₒ = TwoDiff(xₕᵢ, yₕᵢ)
   tₕᵢ, tₗₒ = TwoDiff(xₗₒ, yₗₒ)
   c = sₗₒ + tₕᵢ
   vₕᵢ, vₗₒ = Fast2Sum(sₕᵢ, c)
   w = tₗₒ + vₗₒ
   zₕᵢ, zₗₒ = Fast2Sum(vₕᵢ, w)
   return zₕᵢ, zₗₒ
end


# Algorithm 7 in ref: relerr (³/₂)u² + 4u³  [reltime 18]

@inline function DWTimesFP1(xₕᵢ::T, xₗₒ::T, y::T) where {T<:AbstractFloat}
    cₕᵢ, c1 = Fast2Mult(xₕᵢ, y)
    c2 = xₗₒ * y
    tₕᵢ, t1 = Fast2Sum(cₕᵢ, c2)
    t2 = t1 + c1
    zₕᵢ, zₗₒ = Fast2Sum(tₕᵢ, t2)
    return zₕᵢ, zₗₒ
end

# Algorithm 9 in ref: relerr 2u²  [reltime 15]

@inline function DWTimesFP3(xₕᵢ::T, xₗₒ::T, y::T) where {T<:AbstractFloat}
    cₕᵢ, cₗₒ = Fast2Mult(xₕᵢ, y)
    c = fma(xₗₒ, y, cₗₒ)
    zₕᵢ, zₗₒ = Fast2Sum(cₕᵢ, c)
    return zₕᵢ, zₗₒ
end

# Algorithm 11 in ref: relerr 6u²  [reltime 16]

function DWTimesDW2(xₕᵢ::T, xₗₒ::T, yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   cₕᵢ, c1 = Fast2Mult(xₕᵢ, yₕᵢ)
   t0 = xₗₒ * yₗₒ
   c2 = fma(xₗₒ, yₕᵢ, t0)
   c3 = c1 + c2
   zₕᵢ, zₗₒ = Fast2Sum(cₕᵢ, c3)
   return zₕᵢ, zₗₒ
end

# Algorithm 12 in ref: relerr 5u²  [reltime 17]

function DWTimesDW3(xₕᵢ::T, xₗₒ::T, yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   cₕᵢ, c1 = Fast2Mult(xₕᵢ, yₕᵢ)
   t0 = xₗₒ * yₗₒ
   t1 = fma(xₕᵢ, yₗₒ, t0)
   c2 = fma(xₗₒ, yₕᵢ, t1)
   c3 = c1 + c2
   zₕᵢ, zₗₒ = Fast2Sum(cₕᵢ, c3)
   return zₕᵢ, zₗₒ
end

# Algorithm 15 in ref: relerr 3u²  [reltime 27]

function DWDivFP3(xₕᵢ::T, xₗₒ::T, y::T) where {T<:AbstractFloat}
   tₕᵢ = xₕᵢ / y
   pₕᵢ, pₗₒ = Fast2Mult(tₕᵢ, y)
   dₕᵢ = xₕᵢ - pₕᵢ
   dₗₒ = dₕᵢ - pₗₒ
   d = dₗₒ + xₗₒ
   tₗₒ = d / y
   zₕᵢ, zₗₒ = Fast2Sum(tₕᵢ, tₗₒ)
   return zₕᵢ, zₗₒ
end

# Algorithm 17 in ref: relerr 15u² + 56u³ [reltime 50]

function DWDivDW2(xₕᵢ::T, xₗₒ::T, yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   tₕᵢ = xₕᵢ / yₕᵢ
   rₕᵢ, rₗₒ = DWTimesFP1(yₕᵢ, yₗₒ, tₕᵢ)
   dₕᵢ = xₕᵢ - rₕᵢ
   dₗₒ = xₗₒ - rₗₒ
   d = dₕᵢ + dₗₒ
   tₗₒ = d / yₕᵢ
   zₕᵢ, zₗₒ = Fast2Sum(tₕᵢ, tₗₒ)
   return zₕᵢ, zₗₒ
end

# Algorithm 18 in ref: relerr < 10u² (6u² seen) [reltime 107]
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

# inv(...) using Algorithms 17 and 18

# Algorithm 17 in ref: relerr 15u² + 56u³  [reltime 48]

function DWInvDW2(yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   tₕᵢ = one(T) / yₕᵢ
   rₕᵢ, rₗₒ = DWTimesFP1(yₕᵢ, yₗₒ, tₕᵢ)
   dₕᵢ = one(T) - rₕᵢ
   dₗₒ = -rₗₒ
   d = dₕᵢ + dₗₒ
   tₗₒ = d / yₕᵢ
   zₕᵢ, zₗₒ = Fast2Sum(tₕᵢ, tₗₒ)
   return zₕᵢ, zₗₒ
end

# Algorithm 18 in ref: relerr < 10u² (6u² seen)  [reltime 72]
# (note DWTimesDW3 replaces DWTimesDW2 per ref)

function DWInvDW3(yₕᵢ::T, yₗₒ::T) where {T<:AbstractFloat}
   tₕᵢ = inv(yₕᵢ)
   rₕᵢ = fma(yₕᵢ, -tₕᵢ, one(T))
   rₗₒ = -(yₗₒ * tₕᵢ)
   eₕᵢ, eₗₒ = Fast2Sum(rₕᵢ, rₗₒ)
   dₕᵢ, dₗₒ = DWTimesFP3(eₕᵢ, eₗₒ, tₕᵢ)
   zₕᵢ, zₗₒ = DWPlusFP(dₕᵢ, dₗₒ, tₕᵢ)
   return zₕᵢ, zₗₒ
end
