function matrixfunction(fn::Function, m::Matrix{DoubleFloat{T}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    rank(m) == size(m)[1] || throw(ErrorException("matrix is not diagonizable"))
    evals = eigvals(m)
    fnevals = fn.(evals)
    evecs = eigvecs(m)
    invevecs = inv(evecs)
    diagevals = Diagonal(fnevals)
    result = evects * diagevals * invevects
    return result
end

for F in (:log, :exp, :sin, :cos, :tan, :csc, :sec, :cot, :asin, :acos, :atan, :acsc, :asec, :acot,
          :sinh, :cosh, :tanh, :csch, :sech, :coth, :asin, :acos, :atanh, :acsch, :asech, :acoth)
  @eval begin
    function $F(m::Matrix{DoubleFloat{T}}) where {T<:IEEEFloat}
        return matrixfunction($F, m)
    end
  end
end
