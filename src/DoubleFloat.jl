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


const EMPHASIS     = Accuracy      # this is the default Emphasis
const ALT_EMPHASIS = Performance   # this is the other Emphasis 

const EMPHASIS_STR     = ""        # these are used in string()
const ALT_EMPHASIS_STR = "Fast"    # and prepend "Double"

abstract type MultipartFloat{T}    <: AbstractFloat end
abstract type AbstractDouble{T}    <: MultipartFloat{T} end

struct Double{T<:AbstractFloat, E<:Emphasis} <: AbstractDouble{T}
    hi::T
    lo::T
end

@inline hi(x::Double{T,E}) where {T,E<:Emphasis} = x.hi
@inline lo(x::Double{T,E}) where {T,E<:Emphasis} = x.lo

@inline hi(x::T) where {T<:AbstractFloat} = x
@inline lo(x::T) where {T<:AbstractFloat} = zero(T)

function Base.string(x::Double{T,EMPHASIS}) where {T}
    return string(EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
function Base.string(x::Double{T,ALT_EMPHASIS}) where {T}
    return string(ALT_EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
function Base.show(io::IO, x::Double{T,E}) where  {T, E<:Emphasis}
    print(io, string(x))
end

