# Arithmetic and admission tests used inside batch kernels.

# A normalized input in the bounded interval. Check the low limb against
# half a binade ulp without exponent extraction that assumes normal inputs.
# The callers choose normal head bounds and leave slack at branch boundaries.
@inline function _batch_bounded(x::Double64, lower, upper)
    h, l = HILO(x)
    binade = reinterpret(Float64, reinterpret(UInt64, h) & 0x7ff0000000000000)
    return (lower <= h <= upper) & (abs(l) <= 0x1p-53 * binade)
end

@inline _batch_abs_bounded(x::Double64, lower, upper) =
    _batch_bounded(unsafe_double(Float64, abs(HI(x)), LO(x)), lower, upper)

# These compositions use the same transforms as the scalar arithmetic
# wrappers. Their callers bound all operands and keep divisors away from zero.
@inline _batch_add(x, y) = unsafe_double(Float64, add_dddd_dd_(HILO(x), HILO(y))...)
@inline _batch_sub(x, y) = unsafe_double(Float64, sub_dddd_dd_(HILO(x), HILO(y))...)
@inline _batch_mul(x, y) = unsafe_double(Float64, mul_dddd_dd_(HILO(x), HILO(y))...)
@inline _batch_div(x, y) = unsafe_double(Float64, dvi_dddd_dd_(HILO(x), HILO(y))...)
@inline _batch_inv(x) = unsafe_double(Float64, unsafe_inv_dd_dd_(HILO(x)...)...)
@inline _batch_square(x) = unsafe_double(Float64, square_dd_dd_(HILO(x))...)
@inline _batch_sqrt(x) = unsafe_double(Float64, _sqrt_positive(HILO(x), Core.Intrinsics.sqrt_llvm)...)
@inline _batch_neg(x) = unsafe_double(Float64, -HI(x), ifelse(iszero(LO(x)), LO(x), -LO(x)))
@inline _batch_abs(x) = ifelse(signbit(x), _batch_neg(x), x)
# For finite nonnegative heads, numeric equality also agrees with the
# bitwise head equality used by DoubleFloat's scalar ordering.
@inline function _batch_positive_less(x, y)
    return (HI(x) < HI(y)) | ((HI(x) == HI(y)) & (LO(x) < LO(y)))
end
@inline _batch_add(x::Float64, y::Double64) = unsafe_double(Float64, two_sum3_(x, HI(y), LO(y))...)
@inline _batch_sub(x::Double64, y::Float64) = unsafe_double(Float64, two_sum3_(HI(x), LO(x), -y)...)

@inline function _batch_sub(x::Float64, y::Double64)
    s, t = two_diff_(-HI(y), LO(y))
    h, l = two_sum_(x, s)
    return unsafe_double(Float64, two_sum_(h, l + t)...)
end
