@inline function fma(xhi::T, xlo::T, yhi::T, ylo::T, zhi::T, zlo::T) where {T<:IEEEFloat}
   chi, c1 = two_prod(xhi, yhi)
   t0 = xlo * ylo
   t1 = fma(xhi, ylo, t0)
   c2 = fma(xlo, yhi, t1)
   c3 = c1 + c2
   dhi, dlo = two_hilo_sum(chi, c3)

   shi, slo = two_sum(zhi, dhi)
   thi, tlo = two_sum(zlo, dlo)
   c = slo + thi
   vhi, vlo = two_hilo_sum(shi, c)
   w = tlo + vlo
   hi, lo = two_hilo_sum(vhi, w)
   return DoubleFloat{T}(hi, lo)
end

@inline function fma(x::DoubleFloat{T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return fma(x.hi, x.lo, y.hi, y.lo, z.hi, z.lo)
end

# The fast double-double FMA loses relative accuracy only when the product
# and addend nearly cancel.  In that uncommon case, retain an exact expansion
# of the four component products and the addend before rounding back to a
# Double64.  The expansion path is deliberately Float64-specific: it uses
# Float64 error-free transforms and leaves the Float32/Float16 hot paths
# unchanged.
@inline function _fma_cancellation_ratio(xhi::Float64, xlo::Float64,
                                         yhi::Float64, ylo::Float64,
                                         zhi::Float64, zlo::Float64,
                                         rhi::Float64)
    p0 = abs(xhi * yhi)
    p1 = abs(xhi * ylo)
    p2 = abs(xlo * yhi)
    p3 = abs(xlo * ylo)
    bound = p0 + p1 + p2 + p3 + abs(zhi) + abs(zlo)
    return isfinite(bound) && bound != 0.0 ? abs(rhi) / bound : Inf
end

function _fma_grow_expansion!(h::Vector{Float64}, e::Vector{Float64}, b::Float64)
    empty!(h)
    q = b
    for a in e
        qnext, err = two_sum(q, a)
        err != 0.0 && push!(h, err)
        q = qnext
    end
    q != 0.0 && push!(h, q)
    return h
end

function _fma_refined(x::Double64, y::Double64, z::Double64)
    # Each two_prod pair is exact.  Grow the expansion rather than summing
    # the terms into a Double64 so cancellation cannot discard their tails.
    e = Float64[]
    scratch = Float64[]
    sizehint!(e, 10)
    sizehint!(scratch, 10)
    for (a, b) in ((x.hi, y.hi), (x.hi, y.lo),
                   (x.lo, y.hi), (x.lo, y.lo))
        p, err = two_prod(a, b)
        e, scratch = _fma_grow_expansion!(scratch, e, err), e
        e, scratch = _fma_grow_expansion!(scratch, e, p), e
    end
    e, scratch = _fma_grow_expansion!(scratch, e, z.lo), e
    e, scratch = _fma_grow_expansion!(scratch, e, z.hi), e

    # The expansion is ordered from low to high.  Double64 accumulation then
    # rounds the exact expansion only at the target precision.
    result = zero(Double64)
    for term in e
        result += Double64(term)
    end
    return result
end

@inline function fma(x::Double64, y::Double64, z::Double64)
    result = fma(x.hi, x.lo, y.hi, y.lo, z.hi, z.lo)
    (!isfinite(result) ||
     _fma_cancellation_ratio(x.hi, x.lo, y.hi, y.lo,
                             z.hi, z.lo, result.hi) >= 0x1.0p-6) && return result
    return _fma_refined(x, y, z)
end

@inline function fma(x::T, y::T, zhi::T, zlo::T) where {T<:IEEEFloat}
   chi, c1 = two_prod(x, y)
   shi, slo = two_sum(zhi, chi)
   thi, tlo = two_sum(zlo, c1)
   c = slo + thi
   vhi, vlo = two_hilo_sum(shi, c)
   w = tlo + vlo
   hi, lo = two_hilo_sum(vhi, w)
   return DoubleFloat{T}(hi, lo)
end

@inline function fma(x::T, y::T, z::DoubleFloat{T}) where {T<:IEEEFloat}
   return fma(x, y, z.hi, z.lo)
end

@inline function fma(xhi::T, xlo::T, yhi::T, ylo::T, z::T) where {T<:IEEEFloat}
   chi, c1 = two_prod(xhi, yhi)
   t0 = xlo * ylo
   t1 = fma(xhi, ylo, t0)
   c2 = fma(xlo, yhi, t1)
   c3 = c1 + c2
   dhi, dlo = two_hilo_sum(chi, c3)
   shi, slo = two_sum(z, dhi)
   c = slo + dlo
   hi, lo = two_hilo_sum(shi, c)
   return DoubleFloat{T}(hi, lo)
end

@inline function fma(x::DoubleFloat{T}, y::DoubleFloat{T}, z::T) where {T<:IEEEFloat}
   return fma(x.hi, x.lo, y.hi, y.lo, z)
end

@inline function muladd(x::DoubleFloat{T}, y::DoubleFloat{T}, z::DoubleFloat{T}) where {T<:IEEEFloat}
    return fma(x, y, z)
end
@inline function muladd(x::DoubleFloat{T}, y::DoubleFloat{T}, z::T) where {T<:IEEEFloat}
    return fma(x, y, z)
end
@inline function muladd(x::T, y::T, z::DoubleFloat{T}) where {T<:IEEEFloat}
    return fma(x, y, z)
end
