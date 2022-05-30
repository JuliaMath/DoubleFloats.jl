using DoubleFloats, LinearAlgebra
using Quadmath, Combinatorics
using Test

using  Base: IEEEFloat
import Base: isapprox

using Printf
using Random

const phi = Base.MathConstants.golden
const gamma = Base.MathConstants.eulergamma

const phi_df64   = Double64(phi)
const phi_df32   = Double32(phi)
const gamma_df64 = Double64(gamma)
const gamma_df32 = Double32(gamma)

const phi_df64hi = HI(phi_df64); const phi_df64lo = LO(phi_df64)
const phi_df32hi = HI(phi_df32); const phi_df32lo = LO(phi_df32)
const gamma_df64hi = HI(gamma_df64); const gamma_df64lo = LO(gamma_df64)
const gamma_df32hi = HI(gamma_df32); const gamma_df32lo = LO(gamma_df32)


function isapprox(a::T, b::T) where {T<:IEEEFloat}
   (iszero(a) && (0 < abs(b) < eps(T)^2) ||
    iszero(b) && (0 < abs(a) < eps(T)^2) ||
    isapprox(a, b, atol=eps(T)^2, rtol = eps(T)))
end



# isapprox(lo,eps(one(Float64)),atol=eps(one(Float64)))

# to cover functions that are not exported

macro df(func)
  :(DoubleFloats.$func)
end
macro df(func, arg)
  :(DoubleFloats.$func($arg))
end
macro df(func, arg1, arg2)
  :(DoubleFloats.$func($arg1, $arg2))
end
macro df(func, arg1, arg2, arg3)
  :(DoubleFloats.$func($arg1, $arg2, $arg3))
end
macro df(func, arg1, arg2, arg3, arg4)
  :(DoubleFloats.$func($arg1, $arg2, $arg3, $arg4))
end


include("specialvalues.jl")
include("construct.jl")
include("compare.jl")
include("promote.jl")

include("prearith.jl")
include("arithmetic.jl")
include("morearith.jl")
include("fma.jl")
include("modrem.jl")

include("functions.jl")
include("matmul.jl")
include("complex.jl")

include("linearalgebra.jl")
include("special_functions.jl")

include("concrete_accuracy.jl")
include("function_accuracy.jl")

include("coverage.jl")
include("op_.jl")

include("string.jl")
include("parse.jl")

include("notnan.jl")
include("corners.jl")

include("legacy.jl")

