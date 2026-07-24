# The ordinary LinearAlgebra.eigen route for DoubleFloat matrices
# ---------------------------------------------------------------
# LinearAlgebra's dense eigen-solvers ship only for LAPACK element types
# (Float32/64, ComplexF32/64).  For DoubleFloat the numerical work is
# delegated to GenericSchur:
#   * general matrices: balancing + Hessenberg reduction + QR iteration,
#     eigenvectors by back-substitution in the triangular Schur factor
#   * Hermitian / real-symmetric matrices: Householder tridiagonalization +
#     symmetric QR (GenericSchur.geigen!), giving real eigenvalues and
#     orthonormal eigenvectors
#
# The methods below make DoubleFloats own this route explicitly, rather than
# depending on dispatch details of LinearAlgebra's generic fallbacks, and
# normalize the results to the conventions of the LAPACK route for Float64:
#   * hermitian input (detected, or passed as Symmetric/Hermitian) yields
#     real eigenvalues
#   * a real matrix whose spectrum is entirely real yields a real Eigen
#   * eigenvectors have unit Euclidean norm
#   * eigenvalues are sorted by (real, imag), i.e. LinearAlgebra.eigsortby
#
# Passing the algorithm explicitly on the Symmetric/Hermitian path also
# avoids the "GenericSchur does not currently provide alg=..." warning that
# LinearAlgebra's default algorithm choice triggers on recent Julia versions.

const DoubleFloatHermSym{T} = LinearAlgebra.RealHermSymComplexHerm{DoubleFloat{T}, <:AbstractMatrix}

# a matrix with an all-real spectrum has eigenvectors that GenericSchur
# phase-normalizes to be real up to roundoff; drop the imaginary dust so the
# result matches the real Eigen the LAPACK route returns.  the (loose)
# tolerance guards pathological cases, which are then returned as complex.
function _realeigen(E::LinearAlgebra.Eigen{Complex{DoubleFloat{T}}}) where {T<:IEEEFloat}
    all(v -> iszero(imag(v)), E.values) || return E
    tol = sqrt(eps(DoubleFloat{T})) * size(E.vectors, 1)
    maximum(abs, imag.(E.vectors); init=zero(DoubleFloat{T})) <= tol || return E
    return LinearAlgebra.Eigen(real.(E.values), real.(E.vectors))
end

function LinearAlgebra.eigen(A::StridedMatrix{DoubleFloat{T}};
                             permute::Bool=true, scale::Bool=true,
                             sortby=LinearAlgebra.eigsortby) where {T<:IEEEFloat}
    LinearAlgebra.checksquare(A)
    if ishermitian(A)
        return GenericSchur.geigen!(Hermitian(Matrix(A)),
                                    LinearAlgebra.QRIteration(); sortby=sortby)
    end
    E = LinearAlgebra.eigen!(Matrix(A); permute=permute, scale=scale, sortby=sortby)
    return _realeigen(E)
end

function LinearAlgebra.eigen(A::StridedMatrix{Complex{DoubleFloat{T}}};
                             permute::Bool=true, scale::Bool=true,
                             sortby=LinearAlgebra.eigsortby) where {T<:IEEEFloat}
    LinearAlgebra.checksquare(A)
    if ishermitian(A)
        return GenericSchur.geigen!(Hermitian(Matrix(A)),
                                    LinearAlgebra.QRIteration(); sortby=sortby)
    end
    return LinearAlgebra.eigen!(Matrix(A); permute=permute, scale=scale, sortby=sortby)
end

function LinearAlgebra.eigen(A::DoubleFloatHermSym{T};
                             alg::LinearAlgebra.Algorithm=LinearAlgebra.QRIteration(),
                             sortby=LinearAlgebra.eigsortby) where {T<:IEEEFloat}
    return GenericSchur.geigen!(copy(A), alg; sortby=sortby)
end

function LinearAlgebra.eigvals(A::StridedMatrix{DoubleFloat{T}};
                               permute::Bool=true, scale::Bool=true,
                               sortby=LinearAlgebra.eigsortby) where {T<:IEEEFloat}
    LinearAlgebra.checksquare(A)
    if ishermitian(A)
        return GenericSchur.geigvals!(Hermitian(Matrix(A)),
                                      LinearAlgebra.QRIteration(); sortby=sortby)
    end
    vals = LinearAlgebra.eigvals!(Matrix(A); permute=permute, scale=scale, sortby=sortby)
    return all(v -> iszero(imag(v)), vals) ? real.(vals) : vals
end

function LinearAlgebra.eigvals(A::StridedMatrix{Complex{DoubleFloat{T}}};
                               permute::Bool=true, scale::Bool=true,
                               sortby=LinearAlgebra.eigsortby) where {T<:IEEEFloat}
    LinearAlgebra.checksquare(A)
    if ishermitian(A)
        return GenericSchur.geigvals!(Hermitian(Matrix(A)),
                                      LinearAlgebra.QRIteration(); sortby=sortby)
    end
    return LinearAlgebra.eigvals!(Matrix(A); permute=permute, scale=scale, sortby=sortby)
end

# Double16's precision is too coarse for QR iteration to converge at its
# native eps; compute in Double64 and round the factorization back.
_demote16(v::AbstractVector) = eltype(v) <: Complex ? Complex{Double16}.(v) : Double16.(v)
_demote16(m::AbstractMatrix) = eltype(m) <: Complex ? Complex{Double16}.(m) : Double16.(m)

function LinearAlgebra.eigen(A::StridedMatrix{Double16}; kwargs...)
    F = eigen(Matrix{Double64}(A); kwargs...)
    return LinearAlgebra.Eigen(_demote16(F.values), _demote16(F.vectors))
end
function LinearAlgebra.eigen(A::StridedMatrix{Complex{Double16}}; kwargs...)
    F = eigen(Matrix{Complex{Double64}}(A); kwargs...)
    return LinearAlgebra.Eigen(_demote16(F.values), _demote16(F.vectors))
end
function LinearAlgebra.eigvals(A::StridedMatrix{Double16}; kwargs...)
    return _demote16(eigvals(Matrix{Double64}(A); kwargs...))
end
function LinearAlgebra.eigvals(A::StridedMatrix{Complex{Double16}}; kwargs...)
    return _demote16(eigvals(Matrix{Complex{Double64}}(A); kwargs...))
end

function LinearAlgebra.eigvals(A::DoubleFloatHermSym{T};
                               alg::LinearAlgebra.Algorithm=LinearAlgebra.QRIteration(),
                               sortby=LinearAlgebra.eigsortby) where {T<:IEEEFloat}
    return GenericSchur.geigvals!(copy(A), alg; sortby=sortby)
end

# symmetric QR at Double16 precision is also unreliable; the dense Matrix
# methods above already promote, so route the wrappers through them
function LinearAlgebra.eigen(A::DoubleFloatHermSym{Float16};
                             alg::LinearAlgebra.Algorithm=LinearAlgebra.QRIteration(),
                             sortby=LinearAlgebra.eigsortby)
    M = Matrix(A)   # exactly hermitian, so the promoted path takes the
    return eigen(M; sortby=sortby)      # hermitian shortcut in Double64
end
function LinearAlgebra.eigvals(A::DoubleFloatHermSym{Float16};
                               alg::LinearAlgebra.Algorithm=LinearAlgebra.QRIteration(),
                               sortby=LinearAlgebra.eigsortby)
    return eigvals(Matrix(A); sortby=sortby)
end
