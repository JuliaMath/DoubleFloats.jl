module DoubleFloats

export Double, FastDouble,
       MultipartFloat, AbstractDouble,
       Emphasis, Accuracy, Performance

if VERSION >= v"0.7.0-"
    import Base.IEEEFloat
else
     const IEEEFloat = Union{Float64, Float32, Float16}
end


using AccurateArithmetic

include("traits.jl")
include("type/DoubleFloat.jl")
include("type/string_show.jl")



end # module DoubleFloats
