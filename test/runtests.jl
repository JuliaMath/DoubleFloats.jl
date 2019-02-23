using DoubleFloats, GenericLinearAlgebra, LinearAlgebra
using Test

using Random
phi = Base.MathConstants.golden

include("specialvalues.jl")
include("construct.jl")
include("compare.jl")
include("promote.jl")

include("arithmetic.jl")
include("functions.jl")
include("matmul.jl")
include("complex.jl")

include("concrete_accuracy.jl")
include("function_accuracy.jl")

include("coverage.jl")

include("string.jl")
include("parse.jl")
