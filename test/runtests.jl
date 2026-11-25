using DoubleFloats, LinearAlgebra
using Quadmath
using Test

using Base: IEEEFloat

using Printf
using Random

include("support/constants.jl")
include("support/reference.jl")
include("support/splitmix.jl")
include("support/selftest.jl")

include("golden.jl")
include("layering.jl")

include("unit/specialvalues.jl")
include("unit/construct.jl")
include("unit/compare.jl")
include("unit/promote.jl")

include("unit/prearith.jl")
include("unit/arithmetic.jl")
include("unit/fma.jl")
include("unit/modrem.jl")
include("unit/functions.jl")
include("unit/explog_boundaries.jl")
include("unit/elementary_fast_paths.jl")
include("unit/double32_fast_paths.jl")
include("unit/simd_elementary.jl")
include("unit/matmul.jl")
include("unit/complex.jl")

include("unit/linearalgebra.jl")
include("unit/eigen.jl")
include("unit/matrixfunctions.jl")
include("unit/special_functions.jl")

include("unit/concrete_accuracy.jl")
include("unit/function_accuracy.jl")

include("unit/coverage.jl")
include("unit/op_.jl")

include("unit/string.jl")
include("unit/parse.jl")

include("unit/legacy.jl")
