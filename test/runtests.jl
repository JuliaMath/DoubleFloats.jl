using DoubleFloats, AccurateArithmetic
using Test

if VERSION >= v"0.7.0-"
  using Random
  phi = Base.MathConstants.golden
else
  phi = golden 
end

include("concrete_accuracy.jl")
include("function_accuracy.jl")
