module DoubleFloats

export Double, FastDouble

import Base.IEEEFloat # Union{Float64, Float32, Float16}

using AccurateArithmetic


# Emphasis expresses algorithmic preference
# Accuracy and Performants are Traits of Emphasis

"""
    Emphasis

An abstract type for algorithmic preferences:

- [`Accuracy`](@ref) emphasizes accuracy.
- [`Performance`](@ref) emphasizes performance.
"""
abstract type Emphasis end

"""
    Accuracy

Use this as the Emphasis for the most accurate calcuations.
"""
struct Accuracy    <: Emphasis end

"""
    Performance

Use this as the Emphasis for the most performant calcuations.
"""
struct Performance <: Emphasis end

end # module DoubleFloats
