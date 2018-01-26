module DoubleFloats

export Double, FastDouble

import Base.IEEEFloat # Union{Float64, Float32, Float16}

using AccurateArithmetic

include("DoubleFloat.jl")

end # module DoubleFloats
