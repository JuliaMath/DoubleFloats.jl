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

@inline function _fma_grow_expansion(e::NTuple{10, Float64}, n::Int, b::Float64)
    # Only the first n entries are live.  Keeping n separate avoids using a
    # sentinel value: zero is deliberately removed by the original expansion
    # algorithm and therefore cannot distinguish live from unused entries.
    h = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    hn = 0
    q = b
    @inbounds for i in 1:n
        a = e[i]
        qnext, err = two_sum(q, a)
        if err != 0.0
            hn += 1
            h = Base.setindex(h, err, hn)
        end
        q = qnext
    end
    if q != 0.0
        hn += 1
        h = Base.setindex(h, q, hn)
    end
    return h, hn
end

@inline function _fma_grow_product(e::NTuple{10, Float64}, n::Int,
                                   a::Float64, b::Float64)
    p, err = two_prod(a, b)
    e, n = _fma_grow_expansion(e, n, err)
    return _fma_grow_expansion(e, n, p)
end

function _fma_refined(x::Double64, y::Double64, z::Double64)
    # Each two_prod pair is exact.  Grow the expansion rather than summing
    # the terms into a Double64 so cancellation cannot discard their tails.
    # Four products contribute at most two terms each, and z contributes two
    # more, so ten slots suffice. We use a tuple rather than a vector to avoid allocations.
    e = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    n = 0
    e, n = _fma_grow_product(e, n, x.hi, y.hi)
    e, n = _fma_grow_product(e, n, x.hi, y.lo)
    e, n = _fma_grow_product(e, n, x.lo, y.hi)
    e, n = _fma_grow_product(e, n, x.lo, y.lo)
    e, n = _fma_grow_expansion(e, n, z.lo)
    e, n = _fma_grow_expansion(e, n, z.hi)

    # The expansion is ordered from low to high.  Double64 accumulation then
    # rounds the exact expansion only at the target precision.
    result = zero(Double64)
    @inbounds for i in 1:n
        result += Double64(e[i])
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
