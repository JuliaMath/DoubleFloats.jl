using DoubleFloats, AccurateArithmetic
using Test

if VERSION >= v"0.7.0-"
  using Random
  phi = Base.MathConstants.golden
else
  phi = golden 
end



for (U,F) in ((:UInt64, :Float64), (:UInt32, :Float32), (:UInt16, :Float16))
  @eval begin
   @inline function ufp(x::$F)
       u = reinterpret($U, x)
       u = (u >> (precision($F)-1)) << (precision($F)-1)
       return reinterpret($F, u)
   end
  end
end

const Float64ulp = inv(ldexp(1.0, precision(Float64)))
const Float32ulp = inv(ldexp(1.0, precision(Float32)))
const Float16ulp = inv(ldexp(1.0, precision(Float16)))

@inline ulp(x::Float64) = ufp(x) * Float64ulp
@inline ulp(x::Float32) = ufp(x) * Float32ulp
@inline ulp(x::Float16) = ufp(x) * Float16ulp

ulp(x::Double{T,E}) where {T,E} = ulp(LO(x))
ulp(x::Tuple{T,T}) where {T} = ulp(x[2])


function relative_ulp(given, found)
  given_ulp = ulp(given)
  relulp = HI(abs(given - found)) / given_ulp
  iszero(relulp) && return 0.0
  return relulp
end

setprecision(BigFloat, 768)
srand(1602)
const nrands = 1_000
rand_accu = rand(Double, nrands)
rand_perf = FastDouble.(rand_accu)

function testfunc(fun::Function, val::Double{T,E}) where {T<:AbstractFloat,E<:Emphasis}
     bf = BigFloat(HI(val)) + BigFloat(LO(val))
     fnbf = fun(bf)
     fnbfhi = T(fnbf)
     fnbflo = T(fnbf - fnbfhi)
     fbf = Double(E, fnbfhi, fnbflo)
     tst = fun(val)
     abs_err = abs(fbf - tst)
     rel_err = abs_err / fbf
     rel_ulp = relative_ulp(fbf, tst)
     return abs_err, relulp
end

sin_accu = sin.(rand_accu)
sin_perf = sin.(rand_perf)
relative_ulp.(sin_accu, sin_perf)


include("bigfloats.jl")
include("randfloats.jl")

include("concrete_accuracy.jl")

# test sin, cos, tan
