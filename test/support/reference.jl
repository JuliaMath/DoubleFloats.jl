# The exact reference every suite measures against.

"""
    exactbig(x::DoubleFloat)

The exact value of `x` as a `BigFloat`. The precision is chosen from the
words, so the sum of the two is not rounded however far apart they lie.
"""
function exactbig(x::DoubleFloat{F}) where {F}
    hi, lo = HI(x), LO(x)
    (isfinite(hi) && !iszero(lo)) || return BigFloat(hi; precision = 2 * precision(F))
    span = exponent(hi) - exponent(lo) + 2 * precision(F) + 8
    return BigFloat(hi; precision = span) + BigFloat(lo; precision = span)
end

"""
    workingunit(T)

`ε_D = 4u²` for the type: `2^-104` for `Double64`.
"""
workingunit(::Type{DoubleFloat{F}}) where {F} = ldexp(1.0, 2 - 2 * precision(F))

"""
    relerr(computed::DoubleFloat, reference::BigFloat)

Relative error of `computed` against `reference`, in units of `ε_D`.
Zero when both are zero; infinite when only the reference is.
"""
function relerr(computed::T, reference::BigFloat) where {T<:DoubleFloat}
    c = exactbig(computed)
    iszero(reference) && return iszero(c) ? 0.0 : Inf
    return Float64(abs((c - reference) / reference) / workingunit(T))
end
