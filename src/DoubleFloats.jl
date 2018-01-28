module DoubleFloats

export Double, FastDouble,
       MultipartFloat, AbstractDouble,
       Emphasis, Accuracy, Performance,
       spread, sld, tld

if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
     const IEEEFloat = Union{Float64, Float32, Float16}
end


using AccurateArithmetic

include("traits.jl")
include("type/DoubleFloat.jl")

include("ops/prelims.jl")
include("ops/intfloat.jl")
include("ops/float.jl")
include("ops/arith.jl")


end # module DoubleFloats
