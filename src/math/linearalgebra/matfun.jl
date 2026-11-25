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
#   * trig and hyperbolic functions: shared-power series and double-angle steps
# A real input whose result is mathematically real is returned as a real
# matrix (imaginary roundoff dust is stripped), matching the LAPACK-backed
# behavior for Float64.

const _DFR{T} = DoubleFloat{T}
const _DFC{T} = Complex{DoubleFloat{T}}
const _DFRC{T} = Union{DoubleFloat{T},Complex{DoubleFloat{T}}}

# 1/33!, 1/34! -- continuing inv_fact (sequences.jl), which stops at 1/32!
const _invfact_33_34 =
    (Double64(1.151633562077195e-37, -6.09957445788454e-54), Double64(3.387157535521162e-39, 5.09056148151085e-56))

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
function _ps_polyval(c::NTuple{N,Double64}, X::AbstractMatrix{E}, mul::F = *) where {N,E<:Number,F}
    n = LinearAlgebra.checksquare(X)
    K = N - 1
    q = max(1, round(Int, sqrt(K)))
    RT = real(E)
    P = Vector{typeof(X)}(undef, q)          # X^1 .. X^q
    P[1] = X
    for i in 2:q
        P[i] = mul(P[i - 1], X)
    end
    J = K ÷ q
    blockpoly(j) = begin
        M = Matrix{E}(RT(c[j * q + 1]) * I, n, n)
        for r in 1:(q - 1)
            j*q + r <= K || break
            M += RT(c[j * q + r + 1]) * P[r]
        end
        M
    end
    S = blockpoly(J)
    for j in (J - 1):-1:1
        S = mul(S, P[q]) + blockpoly(j)
    end
    # final block j = 0 covers degrees 1:q-1 plus the constant term
    S = mul(S, P[q]) + blockpoly(0)
    return S
end

const _matexp_coeffs = (Double64(1.0, 0.0), ntuple(k -> _invfact(k), 34)...)

# Structural zeros must have both limbs zero. iszero(DoubleFloat)
# examines only the head.
_mat_zero(x::Double64) = iszero(HI(x)) & iszero(LO(x))
_mat_zero(x::ComplexDF64) = _mat_zero(real(x)) & _mat_zero(imag(x))

@inline function _mat_ordinary(x::Double64)
    h, l = HILO(x)
    # Allow the unrenormalized error word from the square-root correction.
    # A zero head can represent a zero entry only with a zero low word.
    return _mat_packable(x) && (iszero(h) ? iszero(l) : abs(l) <= 2eps(h))
end
@inline _mat_ordinary(x::ComplexDF64) = _mat_ordinary(real(x)) & _mat_ordinary(imag(x))

function _mat_triangle(A)
    upper = lower = true
    @inbounds for j in axes(A, 2), i in axes(A, 1)
        i == j && continue
        if (i > j ? upper : lower) && !_mat_zero(A[i, j])
            if i > j
                upper = false
            else
                lower = false
            end
            (upper | lower) || return :general
        end
    end
    return upper ? :upper : :lower
end

function _mat_diagonal(f::F, A, positive = false) where {F}
    A isa Matrix{Double64} || return nothing
    n = size(A, 1)
    n > 0 && size(A, 2) == n || return nothing
    @inbounds for j in 1:n, i in 1:n
        i == j || _mat_zero(A[i, j]) || return nothing
    end
    @inbounds for j in 1:n
        x = A[j, j]
        within = positive ? _batch_bounded(x, 0x1p-64, 8.0) : _batch_abs_bounded(x, 0x1p-64, 8.0)
        within || return nothing
    end
    return _mat_diagonal_result(f, A)
end

_mat_diagonal_result(f::F, A) where {F} = Matrix(Diagonal(f.(diag(A))))
function _mat_diagonal_result(::typeof(sincos), A)
    values = sincos.(diag(A))
    return Matrix(Diagonal(first.(values))), Matrix(Diagonal(last.(values)))
end

_mat_transpose(A::Matrix) = Matrix(transpose(A))
_mat_transpose(A::Tuple) = map(_mat_transpose, A)

function _mat_polynomial(f::F, A, eta, args...) where {F}
    # For this input norm the scaled powers, reconstruction, and
    # coefficient combinations stay within the packed product envelope.
    if A isa Matrix{<:Union{Double64,ComplexDF64}} && size(A, 1) >= 64 && eta <= 8
        side = _mat_triangle(A)
        if side !== :general && all(_mat_ordinary, A)
            side === :upper && return f(_mat_tri_mul, A, eta, args...)
            return _mat_transpose(f(_mat_tri_mul, _mat_transpose(A), eta, args...))
        end
    end
    return f(*, A, eta, args...)
end

function _matexp(A::Matrix{E}, eta = nothing) where {E<:Number}
    n = LinearAlgebra.checksquare(A)
    n == 0 && return copy(A)
    eta = eta === nothing ? opnorm(A, 1) : eta
    isfinite(eta) || return fill(E(NaN), n, n)
    return _mat_polynomial(_matexp_poly, A, eta)
end

function _matexp_poly(mul::F, A::Matrix{E}, eta) where {F,E}
    s = eta > 1 ? exponent(Float64(eta)) + 1 : 0
    B = s > 0 ? A .* real(E)(2.0)^(-s) : A
    # The degree-15 tail at this norm is below 2^-150.
    X = if E === Double64 && 0 < eta <= 0x1p-7 && all(_mat_ordinary, A)
        _ps_polyval(_matexp_coeffs[1:16], B, mul)
    else
        _ps_polyval(_matexp_coeffs, B, mul)
    end
    for _ in 1:s
        X = mul(X, X)
    end
    return X
end

function _herm_apply(fn::F, m::Matrix{E}) where {F<:Function,E<:Number}
    Fh = eigen(Hermitian(m))
    V = Fh.vectors
    return V * Diagonal(fn.(Fh.values)) * V'
end

_mat_hermitian_poly_norm(A) = nothing
function _mat_hermitian_poly_norm(A::Matrix{Double64})
    size(A, 1) >= 32 || return nothing
    eta = opnorm(A, 1)
    if eta <= 0.875 && _mat_triangle(A) === :general && all(_mat_ordinary, A)
        return eta
    end
    return nothing
end

function exp(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat}
    D = _mat_diagonal(exp, m)
    D === nothing || return D
    if ishermitian(m)
        eta = _mat_hermitian_poly_norm(m)
        eta === nothing || return _matexp(m, eta)
        return _herm_apply(exp, m)
    end
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

const _msc_sin = ntuple(j -> j == 1 ? Double64(1.0, 0.0) : (isodd(j) ? inv_fact[2j - 1] : -inv_fact[2j - 1]), 14)
const _msc_cos = ntuple(j -> j == 1 ? Double64(1.0, 0.0) : (isodd(j) ? inv_fact[2j - 2] : -inv_fact[2j - 2]), 14)
const _msc_sinh = ntuple(j -> j == 1 ? Double64(1.0, 0.0) : inv_fact[2j - 1], 14)
const _msc_cosh = ntuple(j -> j == 1 ? Double64(1.0, 0.0) : inv_fact[2j - 2], 14)

# sum(c[j+1] * Y^j for j in 0:13) sharing the power stack Y..Y^4
function _pair_poly(c::NTuple{14,Double64}, Y::Matrix{E}, P2, P3, P4, n, mul::F) where {E<:Number,F}
    RT = real(E)
    blk(j) = begin
        M = Matrix{E}(RT(c[4j + 1]) * I, n, n)
        4j + 2 <= 14 && (M += RT(c[4j + 2]) * Y)
        4j + 3 <= 14 && (M += RT(c[4j + 3]) * P2)
        4j + 4 <= 14 && (M += RT(c[4j + 4]) * P3)
        M
    end
    X = blk(3)
    X = mul(X, P4) + blk(2)
    X = mul(X, P4) + blk(1)
    return mul(X, P4) + blk(0)
end

# with ||B||_1 <= 0.5, ||Y|| <= 0.25 and the 14-term series truncates
# below 2^-114; the double-angle phase then mirrors exp's squaring phase
function _mat_pair(A::Matrix{E}, codd::NTuple{14,Double64}, ceven::NTuple{14,Double64}, eta = nothing) where {E<:Number}
    n = LinearAlgebra.checksquare(A)
    eta = eta === nothing ? opnorm(A, 1) : eta
    isfinite(eta) || return fill(E(NaN), n, n), fill(E(NaN), n, n)
    return _mat_polynomial(_mat_pair_poly, A, eta, codd, ceven)
end

function _mat_pair_poly(mul::F, A::Matrix{E}, eta, codd, ceven) where {F,E}
    s = eta > 0.5 ? exponent(Float64(eta)) + 2 : 0
    B = s > 0 ? A .* real(E)(2.0)^(-s) : A
    Y = mul(B, B)
    P2 = mul(Y, Y)
    P3 = mul(P2, Y)
    P4 = mul(P3, Y)
    n = size(A, 1)
    sn = mul(B, _pair_poly(codd, Y, P2, P3, P4, n, mul))
    cs = _pair_poly(ceven, Y, P2, P3, P4, n, mul)
    for _ in 1:s
        sn2 = mul(sn, cs)
        cs2 = mul(cs, cs)
        sn = sn2 .+ sn2
        cs = (cs2 .+ cs2) - I
    end
    return sn, cs
end

# The even member alone uses one square per doubling.
function _mat_even(A::Matrix{E}, ceven::NTuple{14,Double64}, eta = nothing) where {E<:Number}
    n = LinearAlgebra.checksquare(A)
    eta = eta === nothing ? opnorm(A, 1) : eta
    isfinite(eta) || return fill(E(NaN), n, n)
    return _mat_polynomial(_mat_even_poly, A, eta, ceven)
end

function _mat_even_poly(mul::F, A::Matrix{E}, eta, ceven) where {F,E}
    s = eta > 0.5 ? exponent(Float64(eta)) + 2 : 0
    B = s > 0 ? A .* real(E)(2.0)^(-s) : A
    Y = mul(B, B)
    P2 = mul(Y, Y)
    P3 = mul(P2, Y)
    P4 = mul(P3, Y)
    cs = _pair_poly(ceven, Y, P2, P3, P4, size(A, 1), mul)
    for _ in 1:s
        cs2 = mul(cs, cs)
        cs = (cs2 .+ cs2) - I
    end
    return cs
end

_diag_allnonneg(m) = all(i -> !signbit(HI(m[i, i])), 1:size(m, 1))
_diag_allpos(m) = all(i -> HI(m[i, i]) > 0.0, 1:size(m, 1))

# square root of an upper triangular matrix (Bjorck-Hammarling recurrence)
function _sqrt_uppertri_point(Tm::Matrix{E}) where {E<:Number}
    n = size(Tm, 1)
    U = zeros(E, n, n)
    @inbounds for j in 1:n
        U[j, j] = sqrt(Tm[j, j])
        for i in (j - 1):-1:1
            s = Tm[i, j]
            for k in (i + 1):(j - 1)
                s -= U[i, k] * U[k, j]
            end
            U[i, j] = s / (U[i, i] + U[j, j])
        end
    end
    return U
end

# Restrict blocked solves to an ordinary, near-identity triangle. In
# this envelope Re(sqrt(T[i,i])) is separated from zero.
function _sqrt_uppertri(Tm::Matrix{E}, eta = nothing) where {E<:Number}
    if E <: Union{Double64,ComplexDF64} &&
       size(Tm, 1) >= 96 &&
       all(_mat_ordinary, Tm) &&
       (eta === nothing ? opnorm(Tm - I, 1) : eta) <= 0.625 &&
       all(i -> real(Tm[i, i]) >= 0.375, axes(Tm, 1))
        R = _sqrt_uppertri_blocked(Tm, 12)
        R === nothing || return R
    end
    return _sqrt_uppertri_point(Tm)
end

function _sqrt_uppertri_blocked(Tm::Matrix{E}, width) where {E}
    n = size(Tm, 1)
    blocks = [i:min(i + width - 1, n) for i in 1:width:n]
    roots = [_sqrt_uppertri_point(Tm[J, J]) for J in blocks]
    for R in roots
        all(_mat_packable, R) && all(i -> real(R[i, i]) >= 0.5, axes(R, 1)) || return nothing
    end
    U = zeros(E, n, n)
    workspace = _root_product_workspace(E, width, n)
    for (j, J) in enumerate(blocks)
        U[J, J] = roots[j]
        for i in (j - 1):-1:1
            I = blocks[i]
            F = Tm[I, J]
            if i + 1 < j
                K = first(blocks[i + 1]):last(blocks[j - 1])
                @views _root_subproduct!(F, U[I, K], U[K, J], workspace)
            end
            all(_mat_packable, F) || return nothing
            _sylvester_uppertri!(roots[i], roots[j], F)
            all(_mat_packable, F) || return nothing
            U[I, J] = F
        end
    end
    return U
end

function _mat_schur_restore(Z, U)
    if Z isa Matrix{ComplexDF64} && size(Z, 1) >= 16 && all(_mat_packable, Z) && all(_mat_packable, U)
        return (Z * U) * Matrix(adjoint(Z))
    end
    return Z * U * Z'
end

function _matsqrt_schur(m::Matrix{E}) where {E<:Number}
    CT = complex(real(E))
    S = schur(Matrix{CT}(m))
    U = _sqrt_uppertri(S.T)
    return _mat_schur_restore(S.Z, U)
end

# Double16's word precision is too coarse for reliable QR iteration in
# GenericSchur; matrix functions that need a Schur form compute in Double64
# and round back
_demote16mat(R::Matrix{Double64}) = Double16.(R)
_demote16mat(R::Matrix{Complex{Double64}}) = Complex{Double16}.(R)

function sqrt(m::Matrix{_DFR{T}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    T === Float16 && return _demote16mat(sqrt(Matrix{Double64}(m)))
    D = _mat_diagonal(sqrt, m, true)
    D === nothing || return D
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
    shifted = Tk - I
    eta = opnorm(shifted, 1)
    while eta > 0.25 && s < 100
        Tk = _sqrt_uppertri(Tk, eta)
        shifted = Tk - I
        eta = opnorm(shifted, 1)
        s += 1
    end
    Gu = UpperTriangular(shifted) / UpperTriangular(Tk + I)
    L =
        if n >= 24 &&
           E <: Union{Double64,ComplexDF64} &&
           eta <= 0.25 &&
           all(_mat_ordinary, T0) &&
           all(_mat_packable, Gu)
            G = Matrix(Gu)
            mul = n >= 64 ? _mat_tri_mul : *
            mul(G, _ps_polyval(_matlog_coeffs, mul(G, G), mul))
        else
            Gu * _ps_polyval(_matlog_coeffs, Gu * Gu)
        end
    L = L .+ L                                  # the series is 2*G*S
    return L .* real(E)(2.0)^s
end

function _matlog_schur(m::Matrix{E}) where {E<:Number}
    CT = complex(real(E))
    S = schur(Matrix{CT}(m))
    for i in 1:size(m, 1)
        iszero(S.T[i, i]) && throw(SingularException(i))
    end
    return _mat_schur_restore(S.Z, _log_uppertri(S.T))
end

function _log_uppertri_checked(Tm::Matrix{E}) where {E<:Number}
    for i in 1:size(Tm, 1)
        iszero(Tm[i, i]) && throw(SingularException(i))
    end
    return _log_uppertri(Tm)
end

function log(m::Matrix{_DFR{T}}) where {T<:IEEEFloat}
    issquare(m) || throw(ErrorException("matrix must be square"))
    T === Float16 && return _demote16mat(log(Matrix{Double64}(m)))
    D = _mat_diagonal(log, m, true)
    D === nothing || return D
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

# Trigonometric and hyperbolic functions of dense matrices.
function sincos(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat}
    D = _mat_diagonal(sincos, m)
    D === nothing || return D
    if ishermitian(m)
        eta = _mat_hermitian_poly_norm(m)
        eta === nothing || return _mat_pair(m, _msc_sin, _msc_cos, eta)
        F = eigen(Hermitian(m))
        V = F.vectors
        return V * Diagonal(sin.(F.values)) * V', V * Diagonal(cos.(F.values)) * V'
    end
    return _mat_pair(m, _msc_sin, _msc_cos)
end

function sinh(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat}
    D = _mat_diagonal(sinh, m)
    D === nothing || return D
    if ishermitian(m)
        eta = _mat_hermitian_poly_norm(m)
        eta === nothing || return first(_mat_pair(m, _msc_sinh, _msc_cosh, eta))
        return _herm_apply(sinh, m)
    end
    return first(_mat_pair(m, _msc_sinh, _msc_cosh))
end

function _mat_even_public(f::F, m, even) where {F}
    D = _mat_diagonal(f, m)
    D === nothing || return D
    if ishermitian(m)
        eta = _mat_hermitian_poly_norm(m)
        eta === nothing || return _mat_even(m, even, eta)
        return _herm_apply(f, m)
    end
    return _mat_even(m, even)
end

sin(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = first(sincos(m))
cos(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = _mat_even_public(cos, m, _msc_cos)
cosh(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = _mat_even_public(cosh, m, _msc_cosh)

function _mat_tangent(s, c)
    if c isa Matrix{<:Union{Double64,ComplexDF64}} &&
       size(c, 1) >= 64 &&
       all(_mat_packable, c) &&
       all(_mat_packable, s) &&
       opnorm(c - I, 1) <= 0.5
        side = _mat_triangle(c)
        side === :upper && return s / UpperTriangular(c)
        side === :lower && return s / LowerTriangular(c)
    end
    return s / c
end

function tan(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat}
    ishermitian(m) && return _herm_apply(tan, m)
    return _mat_tangent(_mat_pair(m, _msc_sin, _msc_cos)...)
end

function tanh(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat}
    ishermitian(m) && return _herm_apply(tanh, m)
    return _mat_tangent(_mat_pair(m, _msc_sinh, _msc_cosh)...)
end

csc(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = inv(sin(m))
sec(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = inv(cos(m))
cot(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = inv(tan(m))
csch(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = inv(sinh(m))
sech(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = inv(cosh(m))
coth(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = inv(tanh(m))

expm1(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = exp(m) - I
log1p(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = log(m + I)
log2(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = log(m) .* invlogtwo(DoubleFloat{T})
log10(m::Matrix{<:_DFRC{T}}) where {T<:IEEEFloat} = log(m) .* invlogten(DoubleFloat{T})
