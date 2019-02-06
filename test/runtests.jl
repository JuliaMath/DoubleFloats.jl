using DoubleFloats, GenericLinearAlgebra, LinearAlgebra
using Test

using Random
phi = Base.MathConstants.golden

include("specialvalues.jl")
include("arithmetic.jl")
include("functions.jl")

include("concrete_accuracy.jl")
include("function_accuracy.jl")

include("coverage.jl")
include("promotion.jl")

include("parse.jl")
