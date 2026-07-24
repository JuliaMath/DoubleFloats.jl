# SIMD-friendly matrix multiplication for Double64 matrices
# ---------------------------------------------------------
# Double-double arithmetic is a branch-free chain of fma/add operations,
# which LLVM vectorizes well -- provided the data layout cooperates.
# Matrix{Double64} stores hi/lo interleaved (array-of-structs); splitting
# once into separate hi and lo Float64 planes (struct-of-arrays) lets the
# inner accumulation loop run down contiguous columns under @simd.
# The O(n^2) split cost is amortized against O(n^3) work.
#
# Complex matrices multiply through four real plane-gemms
# (real*real - imag*imag, real*imag + imag*real), avoiding the 4x-cost
# elementwise Complex{Double64} arithmetic.
#
# Accuracy: each accumulation step is an exact two_prod with cross terms
# plus a branch-free two_sum accumulate -- the same error profile
# (~2^-105 per operation) as the generic scalar path.

# one fused step: (ch,cl) += (ah,al) * (bh,bl), all branch-free
@inline function _dd_fma_acc(ah::Float64, al::Float64, bh::Float64, bl::Float64,
                             ch::Float64, cl::Float64)
    p = ah * bh
    e = fma(ah, bh, -p)
    e = fma(ah, bl, fma(al, bh, e))
    s = p + e                       # renormalize the product
    e -= (s - p)
    s1 = ch + s                     # two_sum accumulate
    v = s1 - ch
    err = (ch - (s1 - v)) + (s - v)
    lo = err + (cl + e)
    hi = s1 + lo
    lo -= (hi - s1)
    return hi, lo
end

function _planes(A::AbstractMatrix{Double64})
    H = Matrix{Float64}(undef, size(A))
    L = Matrix{Float64}(undef, size(A))
    @inbounds for idx in eachindex(A, H, L)
        H[idx] = HI(A[idx])
        L[idx] = LO(A[idx])
    end
    return H, L
end

# C-planes += A-planes * B-planes
function _dd_gemm_acc!(Ch, Cl, Ah, Al, Bh, Bl)
    m, K = size(Ah)
    n = size(Bh, 2)
    @inbounds for j in 1:n, k in 1:K
        bh = Bh[k, j]; bl = Bl[k, j]
        @simd for i in 1:m
            h, l = _dd_fma_acc(Ah[i, k], Al[i, k], bh, bl, Ch[i, j], Cl[i, j])
            Ch[i, j] = h
            Cl[i, j] = l
        end
    end
    return nothing
end

@inline function _combine!(C::Matrix{TT}, Ch, Cl, α, β) where {TT}
    if α === true && (β === false || iszero(β))
        @inbounds for idx in eachindex(C)
            C[idx] = TT(Double64(Ch[idx], Cl[idx]))
        end
    else
        @inbounds for idx in eachindex(C)
            C[idx] = α * TT(Double64(Ch[idx], Cl[idx])) + β * C[idx]
        end
    end
    return C
end

# scalar fallback for small problems, where the plane split does not pay
function _dd_matmul_small!(C, A, B, α, β)
    m, K = size(A)
    n = size(B, 2)
    @inbounds for j in 1:n, i in 1:m
        acc = A[i, 1] * B[1, j]
        for k in 2:K
            acc += A[i, k] * B[k, j]
        end
        C[i, j] = (α === true && (β === false || iszero(β))) ? acc :
                  α * acc + β * C[i, j]
    end
    return C
end

function LinearAlgebra.mul!(C::Matrix{Double64}, A::Matrix{Double64},
                            B::Matrix{Double64}, α::Number, β::Number)
    m, K = size(A)
    K2, n = size(B)
    (K == K2 && size(C) == (m, n)) ||
        throw(DimensionMismatch("mul!: sizes $(size(C)) = $(size(A)) * $(size(B))"))
    (m == 0 || n == 0) && return C
    K == 0 && return fill!(C, zero(Double64))
    m * n * K < 4096 && return _dd_matmul_small!(C, A, B, α, β)
    Ah, Al = _planes(A)
    Bh, Bl = _planes(B)
    Ch = zeros(Float64, m, n); Cl = zeros(Float64, m, n)
    _dd_gemm_acc!(Ch, Cl, Ah, Al, Bh, Bl)
    return _combine!(C, Ch, Cl, α, β)
end

function LinearAlgebra.mul!(C::Matrix{Complex{Double64}}, A::Matrix{Complex{Double64}},
                            B::Matrix{Complex{Double64}}, α::Number, β::Number)
    m, K = size(A)
    K2, n = size(B)
    (K == K2 && size(C) == (m, n)) ||
        throw(DimensionMismatch("mul!: sizes $(size(C)) = $(size(A)) * $(size(B))"))
    (m == 0 || n == 0) && return C
    K == 0 && return fill!(C, zero(Complex{Double64}))
    m * n * K < 1024 && return _dd_matmul_small!(C, A, B, α, β)
    Arh, Arl = _planes(real.(A));  Aih, Ail = _planes(imag.(A))
    Brh, Brl = _planes(real.(B));  Bih, Bil = _planes(imag.(B))
    nBih = .-Bih; nBil = .-Bil
    Crh = zeros(Float64, m, n); Crl = zeros(Float64, m, n)
    Cih = zeros(Float64, m, n); Cil = zeros(Float64, m, n)
    _dd_gemm_acc!(Crh, Crl, Arh, Arl, Brh, Brl)     # + Ar*Br
    _dd_gemm_acc!(Crh, Crl, Aih, Ail, nBih, nBil)   # - Ai*Bi
    _dd_gemm_acc!(Cih, Cil, Arh, Arl, Bih, Bil)     # + Ar*Bi
    _dd_gemm_acc!(Cih, Cil, Aih, Ail, Brh, Brl)     # + Ai*Br
    if α === true && (β === false || iszero(β))
        @inbounds for idx in eachindex(C)
            C[idx] = Complex{Double64}(Double64(Crh[idx], Crl[idx]),
                                       Double64(Cih[idx], Cil[idx]))
        end
    else
        @inbounds for idx in eachindex(C)
            C[idx] = α * Complex{Double64}(Double64(Crh[idx], Crl[idx]),
                                           Double64(Cih[idx], Cil[idx])) + β * C[idx]
        end
    end
    return C
end
