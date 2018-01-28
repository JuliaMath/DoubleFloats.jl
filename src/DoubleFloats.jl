module DoubleFloats

export Double, FastDouble,
       MultipartFloat, AbstractDouble,
       Emphasis, Accuracy, Performance

import Base.IEEEFloat # Union{Float64, Float32, Float16}

using AccurateArithmetic

include("MultipartFloat.jl")
include("Emphasis.jl")
include("DoubleFloat.jl")

end # module DoubleFloats
