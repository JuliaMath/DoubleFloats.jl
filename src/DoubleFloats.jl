module DoubleFloats

export Double, FastDouble,
       MultipartFloat, AbstractDouble,
       Emphasis, Accuracy, Performance

if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
     const IEEEFloat = Union{Float64, Float32, Float16}
end


include("AbstractTrait.jl")
include("DoubleFloat.jl")

using AccurateArithmetic


end # module DoubleFloats
