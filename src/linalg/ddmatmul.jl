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
@inline function _dd_fma_acc(ah::Float64, al::Float64, bh::Float64, bl::Float64, ch::Float64, cl::Float64)
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
function _dd_gemm_acc!(Ch, Cl, Ah, Al, Bh, Bl, negate = false)
    m, K = size(Ah)
    n = size(Bh, 2)
    @inbounds for j in 1:n, k in 1:K
        bh = Bh[k, j]
        bl = Bl[k, j]
        if negate
            bh, bl = -bh, -bl
        end
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
            C[idx] = TT(unsafe_double(Float64, Ch[idx], Cl[idx]))
        end
    else
        @inbounds for idx in eachindex(C)
            C[idx] = α * TT(unsafe_double(Float64, Ch[idx], Cl[idx])) + β * C[idx]
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
        C[i, j] = (α === true && (β === false || iszero(β))) ? acc : α * acc + β * C[i, j]
    end
    return C
end

function LinearAlgebra.mul!(C::Matrix{Double64}, A::Matrix{Double64}, B::Matrix{Double64}, α::Number, β::Number)
    m, K = size(A)
    K2, n = size(B)
    (K == K2 && size(C) == (m, n)) || throw(DimensionMismatch("mul!: sizes $(size(C)) = $(size(A)) * $(size(B))"))
    (m == 0 || n == 0) && return C
    K == 0 && return fill!(C, zero(Double64))
    m * n * K < 4096 && return _dd_matmul_small!(C, A, B, α, β)
    Ah, Al = _planes(A)
    Bh, Bl = _planes(B)
    Ch = zeros(Float64, m, n)
    Cl = zeros(Float64, m, n)
    _dd_gemm_acc!(Ch, Cl, Ah, Al, Bh, Bl)
    return _combine!(C, Ch, Cl, α, β)
end

function LinearAlgebra.mul!(
    C::Matrix{Complex{Double64}},
    A::Matrix{Complex{Double64}},
    B::Matrix{Complex{Double64}},
    α::Number,
    β::Number,
)
    m, K = size(A)
    K2, n = size(B)
    (K == K2 && size(C) == (m, n)) || throw(DimensionMismatch("mul!: sizes $(size(C)) = $(size(A)) * $(size(B))"))
    (m == 0 || n == 0) && return C
    K == 0 && return fill!(C, zero(Complex{Double64}))
    m * n * K < 1024 && return _dd_matmul_small!(C, A, B, α, β)
    Arh, Arl = _planes(real.(A))
    Aih, Ail = _planes(imag.(A))
    Brh, Brl = _planes(real.(B))
    Bih, Bil = _planes(imag.(B))
    nBih = .-Bih
    nBil = .-Bil
    Crh = zeros(Float64, m, n)
    Crl = zeros(Float64, m, n)
    Cih = zeros(Float64, m, n)
    Cil = zeros(Float64, m, n)
    _dd_gemm_acc!(Crh, Crl, Arh, Arl, Brh, Brl)     # + Ar*Br
    _dd_gemm_acc!(Crh, Crl, Aih, Ail, nBih, nBil)   # - Ai*Bi
    _dd_gemm_acc!(Cih, Cil, Arh, Arl, Bih, Bil)     # + Ar*Bi
    _dd_gemm_acc!(Cih, Cil, Aih, Ail, Brh, Brl)     # + Ai*Br
    if α === true && (β === false || iszero(β))
        @inbounds for idx in eachindex(C)
            C[idx] = Complex{Double64}(
                unsafe_double(Float64, Crh[idx], Crl[idx]),
                unsafe_double(Float64, Cih[idx], Cil[idx]),
            )
        end
    else
        @inbounds for idx in eachindex(C)
            C[idx] =
                α * Complex{Double64}(
                    unsafe_double(Float64, Crh[idx], Crl[idx]),
                    unsafe_double(Float64, Cih[idx], Cil[idx]),
                ) + β * C[idx]
        end
    end
    return C
end

# A conservative envelope for the unchecked packed products. Even with
# typemax(Int) summands, products and partial sums have exponent headroom.
@inline function _mat_packable(x::Double64)
    h, l = HILO(x)
    return (abs(h) <= 0x1p200) & (abs(l) <= 0x1p200)
end
@inline _mat_packable(x::ComplexDF64) = _mat_packable(real(x)) & _mat_packable(imag(x))

# Both operands are known to be upper triangular by the matrix-function
# driver. Retain the dense accumulator's ascending k order.
function _dd_tri_acc!(Ch, Cl, Ah, Al, Bh, Bl, negate = false)
    n = size(Ah, 1)
    @inbounds for j in 1:n, k in 1:j
        bh, bl = Bh[k, j], Bl[k, j]
        if negate
            bh, bl = -bh, -bl
        end
        @simd for i in 1:k
            Ch[i, j], Cl[i, j] = _dd_fma_acc(Ah[i, k], Al[i, k], bh, bl, Ch[i, j], Cl[i, j])
        end
    end
    return nothing
end

function _mat_tri_mul(A::Matrix{Double64}, B::Matrix{Double64})
    all(_mat_packable, A) && all(_mat_packable, B) || return A * B
    Ah, Al = _planes(A)
    Bh, Bl = _planes(B)
    Ch = zeros(Float64, size(A))
    Cl = zeros(Float64, size(A))
    _dd_tri_acc!(Ch, Cl, Ah, Al, Bh, Bl)
    return _combine!(similar(A), Ch, Cl, true, false)
end

function _mat_tri_mul(A::Matrix{ComplexDF64}, B::Matrix{ComplexDF64})
    all(_mat_packable, A) && all(_mat_packable, B) || return A * B
    left = _packed_planes(ComplexDF64, size(A))
    right = _packed_planes(ComplexDF64, size(B))
    _pack_planes!(left, A)
    _pack_planes!(right, B)
    Arh, Arl, Aih, Ail = left
    Brh, Brl, Bih, Bil = right
    Crh = zeros(Float64, size(A))
    Crl = zeros(Float64, size(A))
    Cih = zeros(Float64, size(A))
    Cil = zeros(Float64, size(A))
    _dd_tri_acc!(Crh, Crl, Arh, Arl, Brh, Brl)
    _dd_tri_acc!(Crh, Crl, Aih, Ail, Bih, Bil, true)
    _dd_tri_acc!(Cih, Cil, Arh, Arl, Bih, Bil)
    _dd_tri_acc!(Cih, Cil, Aih, Ail, Brh, Brl)
    C = similar(A)
    @inbounds for i in eachindex(C)
        C[i] = ComplexDF64(unsafe_double(Float64, Crh[i], Crl[i]), unsafe_double(Float64, Cih[i], Cil[i]))
    end
    return C
end

# A blocked root reuses one set of packed buffers. Views cover only the
# active rectangle, including the short block at the end of the matrix.
_packed_planes(::Type{Double64}, dims) = ntuple(_ -> Matrix{Float64}(undef, dims), Val(2))
_packed_planes(::Type{ComplexDF64}, dims) = ntuple(_ -> Matrix{Float64}(undef, dims), Val(4))

function _root_product_workspace(::Type{E}, width, n) where {E}
    return (_packed_planes(E, (width, n)), _packed_planes(E, (n, width)), _packed_planes(E, (width, width)))
end

@inline _root_panel(planes, m, n) = map(p -> view(p, 1:m, 1:n), planes)

function _pack_planes!(planes, A::AbstractMatrix{Double64})
    H, L = planes
    @inbounds for j in axes(A, 2), i in axes(A, 1)
        H[i, j], L[i, j] = HILO(A[i, j])
    end
    return nothing
end

function _pack_planes!(planes, A::AbstractMatrix{ComplexDF64})
    Rh, Rl, Ih, Il = planes
    @inbounds for j in axes(A, 2), i in axes(A, 1)
        r, z = reim(A[i, j])
        Rh[i, j], Rl[i, j] = HILO(r)
        Ih[i, j], Il[i, j] = HILO(z)
    end
    return nothing
end

function _root_subproduct!(F, A, B, workspace)
    m, n = size(F)
    k = size(A, 2)
    threshold = eltype(F) === Double64 ? 4096 : 1024
    if m * n * k < threshold
        F .-= Matrix(A) * Matrix(B)
        return F
    end
    left = _root_panel(workspace[1], m, k)
    right = _root_panel(workspace[2], k, n)
    product = _root_panel(workspace[3], m, n)
    _pack_planes!(left, A)
    _pack_planes!(right, B)
    foreach(p -> fill!(p, 0.0), product)
    return _root_subproduct!(F, left, right, product, eltype(F))
end

function _root_subproduct!(F, A, B, C, ::Type{Double64})
    Ch, Cl = C
    _dd_gemm_acc!(Ch, Cl, A..., B...)
    @inbounds for j in axes(F, 2), i in axes(F, 1)
        F[i, j] -= unsafe_double(Float64, Ch[i, j], Cl[i, j])
    end
    return F
end

function _root_subproduct!(F, A, B, C, ::Type{ComplexDF64})
    Arh, Arl, Aih, Ail = A
    Brh, Brl, Bih, Bil = B
    Crh, Crl, Cih, Cil = C
    _dd_gemm_acc!(Crh, Crl, Arh, Arl, Brh, Brl)
    _dd_gemm_acc!(Crh, Crl, Aih, Ail, Bih, Bil, true)
    _dd_gemm_acc!(Cih, Cil, Arh, Arl, Bih, Bil)
    _dd_gemm_acc!(Cih, Cil, Aih, Ail, Brh, Brl)
    @inbounds for j in axes(F, 2), i in axes(F, 1)
        F[i, j] -=
            ComplexDF64(unsafe_double(Float64, Crh[i, j], Crl[i, j]), unsafe_double(Float64, Cih[i, j], Cil[i, j]))
    end
    return F
end
