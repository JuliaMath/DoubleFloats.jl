function matrixfunction(fn::Function, m::Matrix{DoubleFloat{T}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    evecs = eigvecs(m)
    rank(evecs) == size(m)[1] || throw(ErrorException("matrix is not diagonalizable"))
    evals = eigenvals(m)
    fnevals = fn.(evals)
    invevecs = inv(evecs)
    diagevals = Diagonal(fnevals)
    result = evecs * diagevals * invevecs
    return result
end

function matrixfunction(fn::Function, m::Matrix{Complex{DoubleFloat{T}}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    evecs = eigvecs(m)
    rank(evecs) == size(m)[1] || throw(ErrorException("matrix is not diagonalizable"))
    evals = eigenvals(m)
    fnevals = fn.(evals)
    invevecs = inv(evecs)
    diagevals = Diagonal(fnevals)
    result = evecs * diagevals * invevecs
    return result
end

for F in (:sqrt, :cbrt, :log, :exp,
          :sin, :cos, :tan, :csc, :sec, :cot,
          :asin, :acos, :atan, :acsc, :asec, :acot,
          :sinh, :cosh, :tanh, :csch, :sech, :coth,
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


function Base.:(^)(m::Matrix{DoubleFloat{T}}, p::Union{IEEEFloat, DoubleFloat{T}}) where {T<:IEEEFloat}
    pw = DoubleFloat{T}(p)
    res = pw * log(m)
    result = exp(res)
    return result
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
