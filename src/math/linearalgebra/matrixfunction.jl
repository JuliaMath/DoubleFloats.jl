include("eigen.jl")
include("ddmatmul.jl")
include("matfun.jl")
include("sylvester.jl")

function matrixfunction(fn::Function, m::Matrix{DoubleFloat{T}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    F = eigen(m)
    evecs = F.vectors
    rank(evecs) == size(m)[1] || throw(ErrorException("matrix is not diagonalizable"))
    # a real spectrum may still need the complex plane (e.g. log of a
    # negative eigenvalue); retry there rather than escaping a DomainError
    fnevals = try
        fn.(F.values)
    catch e
        e isa DomainError || rethrow()
        fn.(Complex{DoubleFloat{T}}.(F.values))
    end
    result = (evecs * Diagonal(fnevals)) / evecs
    return result isa Matrix{Complex{DoubleFloat{T}}} ? _strip_imag_dust(result) : result
end

function matrixfunction(fn::Function, m::Matrix{Complex{DoubleFloat{T}}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    F = eigen(m)
    evecs = F.vectors
    rank(evecs) == size(m)[1] || throw(ErrorException("matrix is not diagonalizable"))
    fnevals = fn.(F.values)
    return (evecs * Diagonal(fnevals)) / evecs
end

# exp, log, sqrt, and the trig/hyperbolic families have dedicated
# defective-safe implementations in matfun.jl; the functions below still
# use eigen-diagonalization and require a diagonalizable argument
for F in (:cbrt,
          :sinpi, :cospi,
          :asin, :acos, :atan, :acsc, :asec, :acot,
          :asinh, :acosh, :atanh, :acsch, :asech, :acoth)
  @eval begin
    function $F(m::Matrix{DoubleFloat{T}}) where {T<:IEEEFloat}
        return matrixfunction($F, m)
    end
    function $F(m::Matrix{Complex{DoubleFloat{T}}}) where {T<:IEEEFloat}
        return matrixfunction($F, m)
    end
  end
end

# sincos is implemented in matfun.jl (one matrix exponential for both)

function Base.:(^)(m::Matrix{DoubleFloat{T}}, p::Union{IEEEFloat, DoubleFloat{T}}) where {T<:IEEEFloat}
    pw = DoubleFloat{T}(p)
    res = pw * log(m)
    result = exp(res)
    return result isa Matrix{Complex{DoubleFloat{T}}} ? _strip_imag_dust(result) : result
end
function Base.:(^)(m::Matrix{Complex{DoubleFloat{T}}}, p::Union{IEEEFloat, DoubleFloat{T}}) where {T<:IEEEFloat}
    pw = DoubleFloat{T}(p)
    res = pw * log(m)
    result = exp(res)
    return result
end

function Base.:(^)(m::Matrix{DoubleFloat{T}}, p::Union{Complex{T}, Complex{DoubleFloat{T}}}) where {T<:IEEEFloat}
    pw = Complex{DoubleFloat{T}}(p)
    res = pw * log(m)
    result = exp(res)
    return result
end
function Base.:(^)(m::Matrix{Complex{DoubleFloat{T}}}, p::Union{Complex{T}, Complex{DoubleFloat{T}}}) where {T<:IEEEFloat}
    pw = Complex{DoubleFloat{T}}(p)
    res = pw * log(m)
    result = exp(res)
    return result
end

# sort to match usual output for `eigvals`

@inline lt_for_sort(a::DoubleFloat{T}, b::DoubleFloat{T}) where {T<:IEEEFloat} = a < b
@inline lt_for_sort(a::Complex{DoubleFloat{T}},b::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} =
    (real(a) < real(b)) || (real(a)==real(b) && imag(a)<imag(b))

function eigenvals(m::Array{DoubleFloat{T},2}) where {T<:IEEEFloat}
    evals = eigvals(m)
    return sort(evals, lt=lt_for_sort)
end

function eigenvals(m::Array{Complex{DoubleFloat{T}},2}) where {T<:IEEEFloat}
    evals = eigvals(m)
    return sort(evals, lt=lt_for_sort)
end
