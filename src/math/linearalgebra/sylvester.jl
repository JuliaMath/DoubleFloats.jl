# sylvester, lyap, and lq for DoubleFloat matrices
# ------------------------------------------------
# LinearAlgebra's implementations of these are LAPACK-only; its generic
# fallbacks recurse into themselves (StackOverflowError) or hit missing
# LAPACK kernels (lq).  The methods here provide the standard dense
# algorithms:
#   * sylvester / lyap: complex Schur factorizations of both operands,
#     back-substitution on the triangular equation, transform back.
#     Cost O(m^3 + n^3 + mn(m+n)); real inputs return real solutions.
#   * lq: through the generic (pure-Julia) Householder QR of the adjoint --
#     lq(A).Q is exactly qr(A').Q', which also supplies the missing
#     LQPackedQ kernels (materialization and multiplication).

const _DFmat{T} = StridedMatrix{<:Union{DoubleFloat{T}, Complex{DoubleFloat{T}}}}

# solve TA*Y + Y*TB = F in place of F, with TA (m x m) and TB (n x n)
# upper triangular; column-by-column back-substitution
function _sylvester_uppertri!(TA::Matrix{E}, TB::Matrix{E}, F::Matrix{E}) where {E<:Number}
    m, n = size(F)
    @inbounds for j in 1:n
        for i in 1:j-1                       # couple in already-solved columns
            c = TB[i,j]
            if !iszero(c)
                for r in 1:m
                    F[r,j] -= F[r,i] * c
                end
            end
        end
        lam = TB[j,j]                        # (TA + lam*I) y = F[:,j]
        for i in m:-1:1
            s = F[i,j]
            for k in i+1:m
                s -= TA[i,k] * F[k,j]
            end
            den = TA[i,i] + lam
            iszero(den) && throw(SingularException(i))
            F[i,j] = s / den
        end
    end
    return F
end

_up64mat(M) = eltype(M) <: Real ? Matrix{Double64}(M) : Matrix{Complex{Double64}}(M)

function LinearAlgebra.sylvester(A::_DFmat{T}, B::_DFmat{T}, C::_DFmat{T}) where {T<:IEEEFloat}
    if T === Float16
        # Schur at Double16 precision is unreliable; solve in Double64
        X = sylvester(_up64mat(A), _up64mat(B), _up64mat(C))
        return eltype(X) <: Real ? Double16.(X) : Complex{Double16}.(X)
    end
    m = LinearAlgebra.checksquare(A)
    n = LinearAlgebra.checksquare(B)
    size(C) == (m, n) ||
        throw(DimensionMismatch("C has size $(size(C)), expected ($m, $n)"))
    CT = Complex{DoubleFloat{T}}
    SA = schur(Matrix{CT}(A))
    SB = schur(Matrix{CT}(B))
    F = -(SA.Z' * Matrix{CT}(C) * SB.Z)
    _sylvester_uppertri!(SA.T, SB.T, F)
    X = SA.Z * F * SB.Z'
    allreal = eltype(A) <: Real && eltype(B) <: Real && eltype(C) <: Real
    return allreal ? real.(X) : X            # real data has a real solution
end

function LinearAlgebra.lyap(A::_DFmat{T}, C::_DFmat{T}) where {T<:IEEEFloat}
    return sylvester(A, Matrix(A'), C)
end

# --- lq -------------------------------------------------------------------

# the LQ of A and the QR of A' are two views of one factorization:
#   A' = Q_qr * R   ==>   A = R' * Q_qr' = L * Q_lq
# lq() stores factors = (qr(A').factors)' and tau = conj(qr(A').tau), so
# this helper reconstructs the underlying QRPackedQ exactly
_lq_qrQ(factors::AbstractMatrix, tau::AbstractVector) =
    LinearAlgebra.QRPackedQ(Matrix(adjoint(factors)), conj.(tau))
_lq_qrQ(Q::LinearAlgebra.LQPackedQ) = _lq_qrQ(Q.factors, Q.τ)

function LinearAlgebra.lq(A::_DFmat{T}) where {T<:IEEEFloat}
    F = qr(Matrix(adjoint(A)))               # generic pure-Julia Householder QR
    return LinearAlgebra.LQ(Matrix(adjoint(F.factors)), conj.(F.τ))
end

# materialization (the BlasFloat path uses LAPACK.orglq!): the thin
# min(m,n) x n row-block of Q, matching the LAPACK-backed convention
function Base.Matrix{MT}(Q::LinearAlgebra.LQPackedQ{E}) where {MT, E<:Union{DoubleFloat{<:IEEEFloat}, Complex{<:DoubleFloat{<:IEEEFloat}}}}
    m, n = size(Q.factors)
    Qfull = lmul!(_lq_qrQ(Q), Matrix{E}(I, n, n))
    return convert(Matrix{MT}, Matrix(adjoint(view(Qfull, :, 1:min(m, n)))))
end

# multiplication kernels (Q_lq == Q_qr'), delegated to the generic
# QRPackedQ machinery
function LinearAlgebra.lmul!(Q::LinearAlgebra.LQPackedQ{E}, B::AbstractVecOrMat) where {E<:Union{DoubleFloat{<:IEEEFloat}, Complex{<:DoubleFloat{<:IEEEFloat}}}}
    return lmul!(adjoint(_lq_qrQ(Q)), B)
end

function LinearAlgebra.lmul!(aQ::LinearAlgebra.AdjointQ{<:Any, <:LinearAlgebra.LQPackedQ{E}}, B::AbstractVecOrMat) where {E<:Union{DoubleFloat{<:IEEEFloat}, Complex{<:DoubleFloat{<:IEEEFloat}}}}
    return lmul!(_lq_qrQ(parent(aQ)), B)
end

function LinearAlgebra.rmul!(A::AbstractMatrix, Q::LinearAlgebra.LQPackedQ{E}) where {E<:Union{DoubleFloat{<:IEEEFloat}, Complex{<:DoubleFloat{<:IEEEFloat}}}}
    return rmul!(A, adjoint(_lq_qrQ(Q)))
end

function LinearAlgebra.rmul!(A::AbstractMatrix, aQ::LinearAlgebra.AdjointQ{<:Any, <:LinearAlgebra.LQPackedQ{E}}) where {E<:Union{DoubleFloat{<:IEEEFloat}, Complex{<:DoubleFloat{<:IEEEFloat}}}}
    return rmul!(A, _lq_qrQ(parent(aQ)))
end
