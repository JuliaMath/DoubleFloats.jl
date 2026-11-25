# Batch kernels for Double32.

# These bounded kernels keep both Float32 words throughout the arithmetic.
# Calling through an explicitly inlined evaluator lets LLVM see the
# arithmetic inside the shared vector loop.
struct _Double32Batch{F}
    op::F
end

@inline (k::_Double32Batch)(x) = @inline _double32_batch(k.op, x)

const _Double32BatchOps = Union{typeof(tan),typeof(tanh),typeof(sinh),typeof(atan),typeof(log2),typeof(log1p)}

@inline _batch_kernel(f::_Double32BatchOps, ::Type{Double32}, ::Type{Double32}) =
    _BatchKernel(x -> _double32_bounded(f, HILO(x)...), _Double32Batch(f))

const _SINH32_COEFFS, _ATAN32_ANCHORS, _ATAN32_COEFFS, _LOG1P32_COEFFS, _TAN32_CORRECTION, _TAN32_DENOMINATOR =
    setprecision(BigFloat, 256) do
        pack(v) = HILO(Double32(v))
        sinh_coeffs = ntuple(i -> pack(inv(BigFloat(factorial(big(2i + 1))))), 9)
        anchors = ntuple(i -> pack(atan(BigFloat(i - 1) / 16)), 17)
        atan_coeffs = ntuple(i -> pack((-1)^i / BigFloat(2i + 1)), 5)
        log_coeffs = ntuple(i -> pack(BigFloat(2) / (2i - 1)), 5)
        numerator, denominator, scale = _tan_fraction(8)
        tan_coeffs(xs) = Tuple(pack(BigFloat(n) / scale) for n in xs)
        sinh_coeffs, anchors, atan_coeffs, log_coeffs, tan_coeffs(numerator), tan_coeffs(denominator)
    end

@inline function _double32_batch(::typeof(sinh), x)
    p = HILO(x)
    z = square_dd_dd_(p)
    correction = mul_dddd_dd_(mul_dddd_dd_(p, z), _tapered_poly(z, _SINH32_COEFFS, Val(5)))
    return unsafe_double(Float32, add_dddd_dd_(p, correction)...)
end

@inline function _double32_batch(f::Union{typeof(tan),typeof(tanh)}, x)
    return unsafe_double(Float32, _tan_local_words(HILO(x), Val(f === tan), _TAN32_CORRECTION, _TAN32_DENOMINATOR)...)
end

@inline function _double32_batch(::typeof(atan), x)
    h, l = HILO(x)
    neg = signbit(h)
    a, b = _atan_unit_words(abs(h), ifelse(neg, -l, l), _ATAN32_ANCHORS, _ATAN32_COEFFS, Val(3))
    return unsafe_double(Float32, ifelse(neg, -a, a), ifelse(neg, -b, b))
end

@inline function _double32_batch(::typeof(log2), x)
    h, l = HILO(x)
    a, b = _log2_table((h, l), 0)
    # Retain the exact integer at powers of two, even when the table
    # residual rounds differently from its anchor.
    exact = iszero(reinterpret(UInt32, h) & 0x007fffff) & iszero(l)
    return unsafe_double(Float32, ifelse(exact, Float32(_raw_exponent(h)), a), ifelse(exact, 0.0f0, b))
end

@inline function _double32_batch(::typeof(log1p), x)
    h, l = HILO(x)
    dh, dl = two_sum_(h, 2.0f0)
    # |x/(2+x)| < 0.033. Five terms suffice and the last three
    # coefficients have negligible Float32 rounding at that scale.
    return unsafe_double(Float32, _log_near_regular(h, l, dh, dl, l, _LOG1P32_COEFFS, Val(2))...)
end
