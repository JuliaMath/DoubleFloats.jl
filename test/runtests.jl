using DoubleFloats, GenericLinearAlgebra, LinearAlgebra
using Test

using Random

const phi = Base.MathConstants.golden
const gamma = Base.MathConstants.eulergamma

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

include("string.jl")
include("parse.jl")
