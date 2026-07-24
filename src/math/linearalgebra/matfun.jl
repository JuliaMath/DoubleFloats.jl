# Dense matrix functions for DoubleFloat matrices, without diagonalization
# ------------------------------------------------------------------------
# The eigen-diagonalization approach in matrixfunction() fails outright for
# defective matrices and loses accuracy in proportion to cond(V) for nearly
# defective ones.  The functions here use the standard dense algorithms
# instead, which are correct for every square matrix:
#   * exp: scaling-and-squaring with a double-double-accuracy Taylor
#     approximant evaluated by Paterson-Stockmeyer (real input stays in
#     real arithmetic, so real matrices get real results)
#   * sqrt: complex Schur factorization + the Bjorck-Hammarling recurrence
#     on the triangular factor (hermitian PSD input takes the eigen
#     shortcut and stays real)
#   * log: complex Schur + inverse scaling-and-squaring (repeated
#     triangular square roots, then the atanh series)
#   * trig and hyperbolic functions: from exp, via exp(±im*A) and exp(±A)
# A real input whose result is mathematically real is returned as a real
# matrix (imaginary roundoff dust is stripped), matching the LAPACK-backed
# behavior for Float64.

const _DFR{T}  = DoubleFloat{T}
const _DFC{T}  = Complex{DoubleFloat{T}}
const _DFRC{T} = Union{DoubleFloat{T}, Complex{DoubleFloat{T}}}

# 1/33!, 1/34! -- continuing inv_fact (sequences.jl), which stops at 1/32!
const _invfact_33_34 = (
  Double64(1.151633562077195e-37,-6.09957445788454e-54),
  Double64(3.387157535521162e-39,5.09056148151085e-56),
)

@inline _invfact(k::Int) = k <= 32 ? inv_fact[k] : _invfact_33_34[k - 32]

# strip imaginary roundoff dust from a mathematically real result
function _strip_imag_dust(M::Matrix{_DFC{T}}) where {T<:IEEEFloat}
    reM = real.(M)
    tol = sqrt(eps(DoubleFloat{T})) * size(M, 1) * (one(DoubleFloat{T}) + maximum(abs, reM))
    return maximum(abs, imag.(M)) <= tol ? reM : M
end
_strip_imag_dust(M::Matrix{_DFR{T}}) where {T<:IEEEFloat} = M

# Paterson-Stockmeyer evaluation of sum(c[k+1] * X^k for k in 0:K)
# with real double-double coefficients; O(2*sqrt(K)) matrix products.
function _ps_polyval(c::NTuple{N,Double64}, X::AbstractMatrix{E}) where {N, E<:Number}
    n = LinearAlgebra.checksquare(X)
    K = N - 1
    q = max(1, round(Int, sqrt(K)))
    RT = real(E)
    P = Vector{typeof(X)}(undef, q)          # X^1 .. X^q
    P[1] = X
    for i in 2:q
        P[i] = P[i-1] * X
    end
    J = K ÷ q
    blockpoly(j) = begin
        M = Matrix{E}(RT(c[j*q + 1]) * I, n, n)
        for r in 1:q-1
            j*q + r <= K || break
            M += RT(c[j*q + r + 1]) * P[r]
        end
        M
    end
    S = blockpoly(J)
    for j in J-1:-1:1
        S = S * P[q] + blockpoly(j)
    end
    # final block j = 0 covers degrees 1:q-1 plus the constant term
    S = S * P[q] + blockpoly(0)
    return S
end

const _matexp_coeffs = (Double64(1.0, 0.0), ntuple(k -> _invfact(k), 34)...)

# exp of any square DoubleFloat matrix: scale so opnorm(B,1) <= 1, apply the
# 34-term Taylor approximant (truncation < 1/35! ~ 1e-40), square back up
function _matexp(A::Matrix{E}) where {E<:Number}
    n = LinearAlgebra.checksquare(A)
    n == 0 && return copy(A)
    eta = opnorm(A, 1)
    isfinite(eta) || return fill(E(NaN), n, n)
    s = eta > 1 ? exponent(Float64(eta)) + 1 : 0
    B = s > 0 ? A .* real(E)(2.0)^(-s) : A
    X = _ps_polyval(_matexp_coeffs, B)
    for _ in 1:s
        X = X * X
    end
    return X
end

# hermitian input: one symmetric/hermitian eigen-decomposition (orthonormal
# vectors, so the transform is perfectly conditioned) beats the dense
# algorithms by a wide margin and is exactly as accurate
function _herm_apply(fn::F, m::Matrix{E}) where {F<:Function, E<:Number}
    Fh = eigen(Hermitian(m))
    V = Fh.vectors
    return V * Diagonal(fn.(Fh.values)) * V'
end

function exp(m::Matrix{_DFR{T}}) where {T<:IEEEFloat}
    ishermitian(m) && return _herm_apply(exp, m)
    return _matexp(m)
end
function exp(m::Matrix{_DFC{T}}) where {T<:IEEEFloat}
    ishermitian(m) && return _herm_apply(exp, m)
    return _matexp(m)
end

# --- sin/cos and sinh/cosh pairs by scaling + double-angle -----------------
#
# Both pairs satisfy the same recurrences,
#     sin(2X)  = 2 sin(X) cos(X)      cos(2X)  = 2 cos(X)^2 - I
#     sinh(2X) = 2 sinh(X) cosh(X)    cosh(2X) = 2 cosh(X)^2 - I
# so one driver serves both; only the series coefficient signs differ.
# Everything stays in the input's arithmetic (real input => real work and
# real results), replacing the 4x-cost complex exp(im*A) route and the
# two-exponential hyperbolic route.

const _msc_sin  = ntuple(j -> j == 1 ? Double64(1.0, 0.0) :
                          (isodd(j) ? inv_fact[2j-1] : -inv_fact[2j-1]), 14)
const _msc_cos  = ntuple(j -> j == 1 ? Double64(1.0, 0.0) :
                          (isodd(j) ? inv_fact[2j-2] : -inv_fact[2j-2]), 14)
const _msc_sinh = ntuple(j -> j == 1 ? Double64(1.0, 0.0) : inv_fact[2j-1], 14)
const _msc_cosh = ntuple(j -> j == 1 ? Double64(1.0, 0.0) : inv_fact[2j-2], 14)

# sum(c[j+1] * Y^j for j in 0:13) sharing the power stack Y..Y^4
function _pair_poly(c::NTuple{14,Double64}, Y::Matrix{E}, P2, P3, P4, n) where {E<:Number}
    RT = real(E)
    blk(j) = begin
        M = Matrix{E}(RT(c[4j + 1]) * I, n, n)
        4j + 2 <= 14 && (M += RT(c[4j + 2]) * Y)
        4j + 3 <= 14 && (M += RT(c[4j + 3]) * P2)
        4j + 4 <= 14 && (M += RT(c[4j + 4]) * P3)
        M
    end
    X = blk(3)
    X = X * P4 + blk(2)
    X = X * P4 + blk(1)
    return X * P4 + blk(0)
end

# with ||B||_1 <= 0.5, ||Y|| <= 0.25 and the 14-term series truncates
# below 2^-114; the double-angle phase then mirrors exp's squaring phase
function _mat_pair(A::Matrix{E}, codd::NTuple{14,Double64},
                   ceven::NTuple{14,Double64}) where {E<:Number}
    n = LinearAlgebra.checksquare(A)
    RT = real(E)
    eta = opnorm(A, 1)
    isfinite(eta) || return fill(E(NaN), n, n), fill(E(NaN), n, n)
    s = eta > 0.5 ? exponent(Float64(eta)) + 2 : 0
    B = s > 0 ? A .* RT(2.0)^(-s) : A
    Y = B * B
    P2 = Y * Y; P3 = P2 * Y; P4 = P3 * Y
    sn = B * _pair_poly(codd, Y, P2, P3, P4, n)
    cs = _pair_poly(ceven, Y, P2, P3, P4, n)
    for _ in 1:s
        sn2 = sn * cs
        cs2 = cs * cs
        sn = sn2 .+ sn2
        cs = (cs2 .+ cs2) - I
    end
    return sn, cs
end

_diag_allnonneg(m) = all(i -> !signbit(HI(m[i,i])), 1:size(m,1))
_diag_allpos(m)    = all(i -> HI(m[i,i]) > 0.0, 1:size(m,1))

# square root of an upper triangular matrix (Bjorck-Hammarling recurrence)
function _sqrt_uppertri(Tm::Matrix{E}) where {E<:Number}
    n = size(Tm, 1)
    U = zeros(E, n, n)
    @inbounds for j in 1:n
        U[j,j] = sqrt(Tm[j,j])
        for i in j-1:-1:1
            s = Tm[i,j]
            for k in i+1:j-1
                s -= U[i,k] * U[k,j]
            end
            U[i,j] = s / (U[i,i] + U[j,j])
        end
    end
    return U
end

function _matsqrt_schur(m::Matrix{E}) where {E<:Number}
    CT = complex(real(E))
    S = schur(Matrix{CT}(m))
    U = _sqrt_uppertri(S.T)
    return S.Z * U * S.Z'
end

# Double16's word precision is too coarse for reliable QR iteration in
# GenericSchur; matrix functions that need a Schur form compute in Double64
# and round back
_demote16mat(R::Matrix{Double64}) = Double16.(R)
_demote16mat(R::Matrix{Complex{Double64}}) = Complex{Double16}.(R)

function sqrt(m::Matrix{_DFR{T}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    T === Float16 && return _demote16mat(sqrt(Matrix{Double64}(m)))
    if ishermitian(m)
        F = eigen(Hermitian(m))
        if all(>=(zero(DoubleFloat{T})), F.values)
            return F.vectors * Diagonal(sqrt.(F.values)) * F.vectors'
        end
    end
    # already triangular: the recurrence applies directly, no Schur needed
    # (sqrt commutes with transpose, which maps tril to triu); with a
    # nonnegative diagonal the whole computation stays in real arithmetic
    if istriu(m)
        _diag_allnonneg(m) && return _sqrt_uppertri(m)
        return _strip_imag_dust(_sqrt_uppertri(Matrix{_DFC{T}}(m)))
    elseif istril(m)
        mt = Matrix(transpose(m))
        _diag_allnonneg(m) && return Matrix(transpose(_sqrt_uppertri(mt)))
        U = _sqrt_uppertri(Matrix{_DFC{T}}(mt))
        return _strip_imag_dust(Matrix(transpose(U)))
    end
    return _strip_imag_dust(_matsqrt_schur(m))
end

function sqrt(m::Matrix{_DFC{T}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    T === Float16 && return _demote16mat(sqrt(Matrix{Complex{Double64}}(m)))
    istriu(m) && return _sqrt_uppertri(m)
    istril(m) && return Matrix(transpose(_sqrt_uppertri(Matrix(transpose(m)))))
    return _matsqrt_schur(m)
end

# log of an upper triangular matrix by inverse scaling-and-squaring:
# repeated triangular square roots bring T near I, then
# log(T) = 2*atanh(G) = 2*G*sum(G^2k/(2k+1)),  G = (T-I)/(T+I)
const _matlog_coeffs = (Double64(1.0, 0.0), ntuple(k -> inv_oddint[k], 18)...)

function _log_uppertri(T0::Matrix{E}) where {E<:Number}
    n = size(T0, 1)
    Tk = T0
    s = 0
    while opnorm(Tk - I, 1) > 0.25 && s < 100
        Tk = _sqrt_uppertri(Tk)
        s += 1
    end
    # everything here is upper triangular: use the triangular solve and
    # keep the wrapper on the series powers so multiplications skip the
    # zero halves
    Gu = UpperTriangular(Tk - I) / UpperTriangular(Tk + I)
    S = _ps_polyval(_matlog_coeffs, Gu * Gu)
    L = Gu * S
    L = L .+ L                                  # the series is 2*G*S
    return L .* real(E)(2.0)^s
end

function _matlog_schur(m::Matrix{E}) where {E<:Number}
    CT = complex(real(E))
    S = schur(Matrix{CT}(m))
    for i in 1:size(m, 1)
        iszero(S.T[i,i]) && throw(SingularException(i))
    end
    return S.Z * _log_uppertri(S.T) * S.Z'
end

function _log_uppertri_checked(Tm::Matrix{E}) where {E<:Number}
    for i in 1:size(Tm, 1)
        iszero(Tm[i,i]) && throw(SingularException(i))
    end
    return _log_uppertri(Tm)
end

function log(m::Matrix{_DFR{T}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    T === Float16 && return _demote16mat(log(Matrix{Double64}(m)))
    if ishermitian(m)
        F = eigen(Hermitian(m))
        if all(>(zero(DoubleFloat{T})), F.values)
            return F.vectors * Diagonal(log.(F.values)) * F.vectors'
        end
    end
    if istriu(m)
        _diag_allpos(m) && return _log_uppertri_checked(m)
        return _strip_imag_dust(_log_uppertri_checked(Matrix{_DFC{T}}(m)))
    elseif istril(m)
        mt = Matrix(transpose(m))
        _diag_allpos(m) && return Matrix(transpose(_log_uppertri_checked(mt)))
        U = _log_uppertri_checked(Matrix{_DFC{T}}(mt))
        return _strip_imag_dust(Matrix(transpose(U)))
    end
    return _strip_imag_dust(_matlog_schur(m))
end

function log(m::Matrix{_DFC{T}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    T === Float16 && return _demote16mat(log(Matrix{Complex{Double64}}(m)))
    istriu(m) && return _log_uppertri_checked(m)
    istril(m) && return Matrix(transpose(_log_uppertri_checked(Matrix(transpose(m)))))
    return _matlog_schur(m)
end

# trigonometric and hyperbolic families, from exp -- correct for every
# square matrix (including defective ones)

function sincos(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat}
    if ishermitian(m)
        F = eigen(Hermitian(m))
        V = F.vectors
        return V * Diagonal(sin.(F.values)) * V', V * Diagonal(cos.(F.values)) * V'
    end
    return _mat_pair(m, _msc_sin, _msc_cos)
end

sin(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = sincos(m)[1]
cos(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = sincos(m)[2]

function tan(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat}
    ishermitian(m) && return _herm_apply(tan, m)
    s, c = _mat_pair(m, _msc_sin, _msc_cos)
    return s / c              # sin and cos of the same matrix commute
end

function sinh(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat}
    ishermitian(m) && return _herm_apply(sinh, m)
    return _mat_pair(m, _msc_sinh, _msc_cosh)[1]
end

function cosh(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat}
    ishermitian(m) && return _herm_apply(cosh, m)
    return _mat_pair(m, _msc_sinh, _msc_cosh)[2]
end

function tanh(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat}
    ishermitian(m) && return _herm_apply(tanh, m)
    s, c = _mat_pair(m, _msc_sinh, _msc_cosh)
    return s / c
end

csc(m::Matrix{<:_DFRC{T}})  where {T<:IEEEFloat} = inv(sin(m))
sec(m::Matrix{<:_DFRC{T}})  where {T<:IEEEFloat} = inv(cos(m))
cot(m::Matrix{<:_DFRC{T}})  where {T<:IEEEFloat} = inv(tan(m))
csch(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = inv(sinh(m))
sech(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = inv(cosh(m))
coth(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = inv(tanh(m))

expm1(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = exp(m) - I
log1p(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = log(m + I)
log2(m::Matrix{<:_DFRC{T}})  where {T<:IEEEFloat} = log(m) .* invlogtwo(DoubleFloat{T})
log10(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = log(m) .* invlogten(DoubleFloat{T})
