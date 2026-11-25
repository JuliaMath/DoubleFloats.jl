# Bound the head and its correction before narrowing the result. The
# exponential bounds also keep the result away from the Float32 limits.
@inline _double32_range(::typeof(exp), h) = -64.0f0 <= h <= 80.0f0
@inline _double32_range(::typeof(exp2), h) = -96.0f0 <= h <= 112.0f0
@inline _double32_range(::Union{typeof(log),typeof(log2)}, h) = (0.125f0 <= h <= 0.875f0) | (1.125f0 <= h <= 8.0f0)
@inline _double32_range(::Union{typeof(tan),typeof(expm1)}, h) = Float32(0x1p-40) <= abs(h) <= 0.5f0
@inline _double32_range(::typeof(log1p), h) = Float32(0x1p-40) <= abs(h) <= 0.0625f0
@inline _double32_range(::Union{typeof(atan),typeof(sinh),typeof(cosh),typeof(tanh)}, h) =
    Float32(0x1p-40) <= abs(h) <= 1.0f0

@inline function _double32_bounded(f, h, l)
    binade = reinterpret(Float32, reinterpret(UInt32, h) & 0x7f800000)
    return _double32_range(f, h) && abs(l) <= Float32(0x1p-24) * binade
end

@inline function _double32_exact(f, h, l)
    _double32_bounded(f, h, l) || return nothing
    a, b = Float64(h), Float64(l)
    x = a + b
    # With close heads, x - a is exact. A small low word can still
    # be lost even though Float64 has more significant bits.
    return x - a == b ? x : nothing
end

@inline function _double32_split(x::Float64)
    h = Float32(x)
    return Double32(h, Float32(x - Float64(h)))
end

for name in _DOUBLE32_WIDENED
    @eval @inline function $name(x::Double32)
        h, l = HILO(x)
        y = _double32_exact($name, h, l)
        y === nothing || return _double32_split($name(y))
        # Narrowing through Double64 can lose the sign of an exact zero.
        if $(name in (:expm1, :log1p, :atan, :tan, :sinh, :tanh)) && (iszero(h) & iszero(l))
            return x
        end
        return Double32($name(Double64(x)))
    end
end
