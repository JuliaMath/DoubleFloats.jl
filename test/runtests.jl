using DoubleFloats, GenericLinearAlgebra, LinearAlgebra
using Test

using Random
phi = Base.MathConstants.golden

include("specialvalues.jl")
include("compare.jl")
include("promote.jl")

include("arithmetic.jl")
include("functions.jl")
include("matmul.jl")

include("concrete_accuracy.jl")
include("function_accuracy.jl")

include("coverage.jl")

include("parse.jl")
