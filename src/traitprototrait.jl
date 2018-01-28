#=
    `Emphasis` is a proto-trait of algorithmic preference.

        MultipartFloat types implement mathematical operations.
        Some of these functions have two implementations:
           one designed for accuracy
           one designed for performance
        
        `Accuracy` or `Performance`
           the emphasis is given as type parameter
=#

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


const EMPHASIS     = Accuracy      # this is the default Emphasis
const ALT_EMPHASIS = Performance   # this is the other Emphasis 

const EMPHASIS_STR     = ""        # these are used in string()
const ALT_EMPHASIS_STR = "Fast"    # and prepend "Double"
