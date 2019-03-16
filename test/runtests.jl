using DoubleFloats, GenericLinearAlgebra, LinearAlgebra
using Test

using Random

const phi = Base.MathConstants.golden
const gamma = Base.MathConstants.eulergamma

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
include("fma.jl")
include("functions.jl")
include("matmul.jl")
include("complex.jl")

include("linearalgebra.jl")

include("concrete_accuracy.jl")
include("function_accuracy.jl")

include("coverage.jl")
include("op_.jl")

include("string.jl")
include("parse.jl")
