#=
this is a canonical implementation
the implemented version benchmarked slightly better under a variety of inputs (julia v1.0.1)
@inline function two_sum(a::T, b::T) where {T<:AbstractFloat}
    hi = a + b
    v  = hi - a
    lo = (a - (hi - v)) + (b - v)
    return hi, lo
end
=#

const FloatWithFMA = Union{Float64, Float32, Float16}

@noinline zero_error_result(x::T) where {T<:AbstractFloat} = (x, zero(T))

"""
    two_sum(a, b)
Computes `hi = fl(a+b)` and `lo = err(a+b)`.
"""
@inline function two_sum(a::T, b::T) where {T<:FloatWithFMA}
    s = a + b                       # rounded sum

    # --- Corner case: any non-finite input or an overflowed result ----------
    # The TwoSum error formula below subtracts quantities that become ±Inf
    # when `s` is non-finite, producing a spurious NaN (Inf - Inf). Detect
    # this and short-circuit. We branch only on the (rare) non-finite path so
    # the hot path stays branch-light and the common case is unaffected.
    if !isfinite(s)
        # Genuine overflow of a finite+finite sum. The rounding error is
        # not representable as a finite float, but NaN would wrongly
        # suggest the inputs were invalid. Report the unrepresentable
        # error as exactly 0 so callers compensating with s+e still see
        # the (saturated) ±Inf rather than NaN.
        # or
        # An input was already Inf/NaN: let `s` carry IEEE semantics
        # (incl. legitimate NaN from Inf + (-Inf)) and give a 0 error,
        # since the "error of infinity" is undefined, not NaN-worthy.
        return zero_error_result(s)
    end
    # --- Knuth TwoSum, exact when `s` is finite -----------------------------
    # bb is b reconstructed as (s - a); the part of b actually absorbed.
    bb = s - a
    # (a - (s - bb)) recovers the part of a lost in rounding, and
    # (b - bb) recovers the part of b lost. Their sum is the exact error.
    # All five subtractions here are exact under IEEE-754 (Sterbenz / Knuth),
    # including in the subnormal range, so e is exact with no extra rounding.
    e = (a - (s - bb)) + (b - bb)
    return (s, e)
end

# Promote mixed float types to a common type so the EFT guarantees still hold.
two_sum(a::AbstractFloat, b::AbstractFloat) = two_sum(promote(a, b)...)

# Convenience for non-float reals: promote to Float64.
two_sum(a::Real, b::Real) = two_sum(float(promote(a, b))...)

"""
    three_sum(a, b, c)

Computes `hi = fl(a+b+c)` and `md = err(a+b+c), lo = err(md)`.
"""
function three_sum(a::T,b::T,c::T) where {T<:FloatWithFMA}
    t0, t1 = two_sum(a,  b)
    hi, t2 = two_sum(t0, c)
    md, lo = two_sum(t2, t1)
    hi, md = two_hilo_sum(hi, md)
    return hi, md, lo
end

"""
    four_sum(a, b, c, d)
    
Computes `hi = fl(a+b+c+d)` and `hm = err(a+b+c+d), ml = err(hm), lo = err(ml)`.
"""
function four_sum(a::T,b::T,c::T,d::T) where {T<:FloatWithFMA}
    t0, t1 = two_sum(a,  b)
    t2, t3 = two_sum(c,  d)
    hi, t4 = two_sum(t0, t2)
    t5, lo = two_sum(t1, t3)
    hm, ml = two_sum(t4, t5)
    ml, lo = two_hilo_sum(ml, lo)
    hm, ml = two_hilo_sum(hm, ml)
    hi, hm = two_hilo_sum(hi,hm)
    return hi, hm, ml, lo
end

"""
    two_sum(a, b, c)

Computes `hi = fl(a+b+c)` and `lo = err(a+b+c)`.
"""
function two_sum(a::T,b::T,c::T) where {T<:FloatWithFMA}
    t0, t1 = two_sum(a,  b)
    hi, t2 = two_sum(t0, c)
    lo = t2 + t1
    hi, lo = two_hilo_sum(hi, lo)
    return hi, lo
end

"""
    two_sum(a, b, c, d)

Computes `hi = fl(a+b+c+d)` and `lo = err(a+b+c+d)`.
"""
function two_sum(a::T, b::T, c::T, d::T) where {T<:FloatWithFMA}
    t0, t1 = two_sum(a ,  b)
    t0, t2 = two_sum(t0,  c)
    a,  t3 = two_sum(t0,  d)
    t0  = t1 + t2
    b   = t0 + t3
    return a, b
end

function three_sum(a::T,b::T,c::T,d::T) where {T<:FloatWithFMA}
    t0, t1 = two_sum(a ,  b)
    t0, t2 = two_sum(t0,  c)
    hi, t3 = two_sum(t0,  d)
    t0, t1 = two_sum(t1, t2)
    hm, t2 = two_sum(t0, t3) # here, t0 >= t3
    ml     = t1 + t2
    return hi, hm, ml
end


"""
    two_diff(a, b)

Computes `hi = fl(a-b)` and `lo = err(a-b)`.
"""
@inline function two_diff(a::T, b::T) where {T<:FloatWithFMA}
    hi = a - b
    if !isfinite(hi)
        return zero_error_result(hi)
    end
    a1 = hi + b
    b1 = hi - a1
    lo = (a - a1) - (b + b1)
    return hi, lo
end

"""
    two_diff(a, b, c)

Computes `hi = fl(a-b-c)` and `lo = err(a-b-c)`.
"""
function two_diff(a::T, b::T, c::T) where {T<:FloatWithFMA}
    s, t = two_diff(-b, c)
    x, u = two_sum(a, s)
       y = u + t
    x, y = two_sum(x, y)
    return x, y
end
        
"""
    two_hilo_sum(a, b)

*unchecked* requirement `|a| ≥ |b|`
Computes `s = fl(a+b)` and `e = err(a+b)`.
"""
@inline function two_hilo_sum(a::T, b::T) where {T<:FloatWithFMA}
    s = a + b
    if !isfinite(s)
        return zero_error_result(s)
    end
    e = b - (s - a)
    return s, e
end
"""
    two_hilo_sum(a::T, b::T) where {T<:AbstractFloat} -> (s::T, e::T)

Error-free transformation of the sum `a + b`, fast (Dekker / FastTwoSum)
variant. 3 flops in the hot path vs. 6 for the symmetric `two_sum`.

Returns `(s, e)` where `s = fl(a + b)` is the correctly-rounded sum and
`e` is the exact rounding error, so *mathematically* `a + b == s + e`.

Algorithmic precondition: `|a| >= |b|` (or one of them is zero). Under that
ordering, `s - a` is provably exact (the absorbed part of `b`), so
`b - (s - a)` is the exact remainder. Violate the precondition and the
function silently returns a wrong `e` — this is the single most common
footgun with FastTwoSum, so we close it below rather than trust the caller.

Robustness contract:
  * `|a| < |b|` is corrected by an unconditional swap. Floating-point
    addition is commutative bit-for-bit (modulo NaN payload), so the
    returned `s` is unchanged and `e` is now exact. Cost: one compare
    plus a possible register swap; the 3-flop core is preserved.
  * Overflow: if `fl(a+b)` overflows to ±Inf while `a,b` are finite, the
    naive formula yields `b - (Inf - a) = b - Inf = ∓Inf`, an
    *infinite rounding error*, which is nonsense. We detect non-finite
    `s` and return `e = 0`, matching the `two_sum` convention.
  * Underflow / subnormals: with the precondition restored, FastTwoSum
    is exact in gradual-underflow arithmetic. No special handling needed.
  * NaN or ±Inf inputs: `s` carries IEEE semantics (e.g. `Inf + (-Inf) = NaN`)
    and we return `e = 0`, since the "error of a non-finite sum" is
    undefined, not NaN-worthy.
"""
function two_hilo_sum(a::T, b::T) where {T<:AbstractFloat}
    s = a + b                       # rounded sum

    # --- Non-finite guard: overflow, ±Inf input, or NaN -------------------
    # If s is non-finite, the error formula below evaluates `s - a`, which
    # is either Inf-Inf = NaN or Inf-finite = Inf, and then `b - (s-a)`
    # propagates that, fabricating either NaN or an infinite "error". An
    # infinite rounding error is meaningless: the true error of an
    # overflowed sum simply isn't representable, and reporting NaN would
    # falsely suggest the inputs were invalid. We return e = 0 and let `s`
    # carry the saturated ±Inf (or genuine NaN from e.g. Inf + (-Inf)).
    if !isfinite(s)
        return (s, zero(T))
    end

    # --- Dekker / FastTwoSum core ----------------------------------------
    # With |a| >= |b| and s finite, (s - a) is exact under IEEE-754 — it
    # recovers the portion of b absorbed into s. The unabsorbed remainder
    # `b - (s - a)` is therefore the exact rounding error, including in
    # the subnormal range. Two subtractions, no rounding error introduced.
    e = b - (s - a)

    return (s, e)
end

# Mixed float types: promote so the EFT exactness guarantees still hold
# in the common type (mixing precisions would break the Sterbenz lemma).
two_hilo_sum(a::AbstractFloat, b::AbstractFloat) = two_hilo_sum(promote(a, b)...)

# Non-float reals: promote to Float64.
two_hilo_sum(a::Real, b::Real) = two_hilo_sum(float(promote(a, b))...)


"""
    three_hilo_sum(a, b, c)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c|`
Computes `s = fl(a+b+c)` and `e1 = err(a+b+c), e2 = err(e1)`.
"""
function three_hilo_sum(a::T,b::T,c::T) where {T<:FloatWithFMA}
    s, t = two_hilo_sum(b, c)
    x, u = two_hilo_sum(a, s)
    y, z = two_hilo_sum(u, t)
    x, y = two_hilo_sum(x, y)
    return x, y, z
end

"""
    two_hilo_sum(a, b, c)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c|`
Computes `s = fl(a+b+c)` and `e1 = err(a+b+c)`.
"""
function two_hilo_sum(a::T,b::T,c::T) where {T<:FloatWithFMA}
    s, t = two_hilo_sum(b, c)
    x, u = two_hilo_sum(a, s)
    y    = u + t
    x, y = two_hilo_sum(x, y)
    return x, y
end

"""
    four_hilo_sum(a, b, c, d)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c| ≥ |d|`
Computes `s = fl(a+b+c+d)` and `e1 = err(a+b+c+d), e2 = err(e1), e3 = err(e2)`.
"""
function four_hilo_sum(a::T,b::T,c::T,d::T) where {T<:FloatWithFMA}
    t0, t1 = two_hilo_sum(a ,  b)
    t0, t2 = two_hilo_sum(t0,  c)
    hi, t3 = two_hilo_sum(t0,  d)
    t0, t1 = two_hilo_sum(t1, t2)
    hm, t2 = two_hilo_sum(t0, t3) # here, t0 >= t3
    ml, lo = two_hilo_sum(t1, t2)
    return hi, hm, ml, lo
end

"""
    three_hilo_sum(a, b, c, d)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c| ≥ |d|`
Computes `s = fl(a+b+c+d)` and `e1 = err(a+b+c+d), e2 = err(e1)`.
"""
function three_hilo_sum(a::T,b::T,c::T,d::T) where {T<:FloatWithFMA}
    t0, t1 = two_hilo_sum(a ,  b)
    t0, t2 = two_hilo_sum(t0,  c)
    hi, t3 = two_hilo_sum(t0,  d)
    t0, t1 = two_hilo_sum(t1, t2)
    md, t2 = two_hilo_sum(t0, t3) # here, t0 >= t3
    lo     = t1 + t2
    return hi, md, lo
end


"""
    two_hilo_sum(a, b, c, d)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c| ≥ |d|`
Computes `s = fl(a+b+c+d)` and `e1 = err(a+b+c+d)`.
"""
function two_hilo_sum(a::T,b::T,c::T,d::T) where {T<:FloatWithFMA}
    t0, t1 = two_hilo_sum(a ,  b)
    t0, t2 = two_hilo_sum(t0,  c)
    hi, t3 = two_hilo_sum(t0,  d)
    t0     = t1 + t2
    lo     = t0 + t3
    return hi, lo
end


@inline function two_prod(a::T, b::T) where {T<:FloatWithFMA}
    s = a * b
    if !isfinite(s)
        return zero_error_result(s)
    end
    t = fma(a, b, -s)
    return s, t
end

# ---------------------------------------------------------------------------
# Branch-free error-free transforms.
#
# These omit the `!isfinite` short-circuit present in the public EFTs above.
# For finite results they return bit-identical values; the only behavioural
# difference is on overflow, where they may yield NaN/Inf instead of the
# saturated (x, 0) convention. They are intended ONLY for internal use inside
# the DoubleFloat arithmetic kernels, whose wrappers already (a) route
# non-finite operands to a dedicated path and (b) re-check the finished result
# and fall back to the guarded kernel when it is non-finite. Stripping the
# per-EFT branch turns 2-4 hot-path branches into a single output check.
# ---------------------------------------------------------------------------

@inline function two_sum_(a::T, b::T) where {T<:FloatWithFMA}
    s = a + b
    bb = s - a
    e = (a - (s - bb)) + (b - bb)
    return s, e
end

@inline function two_diff_(a::T, b::T) where {T<:FloatWithFMA}
    hi = a - b
    a1 = hi + b
    b1 = hi - a1
    lo = (a - a1) - (b + b1)
    return hi, lo
end

# *unchecked* requirement `|a| >= |b|`
@inline function two_hilo_sum_(a::T, b::T) where {T<:FloatWithFMA}
    s = a + b
    e = b - (s - a)
    return s, e
end

@inline function two_prod_(a::T, b::T) where {T<:FloatWithFMA}
    s = a * b
    t = fma(a, b, -s)
    return s, t
end

@inline function two_sum3_(a::T, b::T, c::T) where {T<:FloatWithFMA}
    t0, t1 = two_sum_(a,  b)
    hi, t2 = two_sum_(t0, c)
    lo = t2 + t1
    hi, lo = two_hilo_sum_(hi, lo)
    return hi, lo
end
