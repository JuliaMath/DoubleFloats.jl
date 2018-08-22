using DoubleFloats, AccurateArithmetic
using Test

using Random
phi = Base.MathConstants.golden

include("basic.jl")
include("concrete_accuracy.jl")
include("function_accuracy.jl")
include("arithmetic.jl")
