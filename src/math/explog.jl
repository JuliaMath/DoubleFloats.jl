function exp_taylor(a::Double{T,Accuracy}) where {T<:AbstractFloat}
  x = a
  x2 = x*x
  x3 = x*x2
  x4 = x2*x2
  x5 = x2*x3
  x10 = x5*x5
  x15 = x5*x10
  x20 = x10*x10
  x25 = x10*x15

  z = x + inv_fact_accu[2]*x2 + inv_fact_accu[3]*x3 + inv_fact_accu[4]*x4
  z2 = x5 * (inv_fact_accu[5] + x*inv_fact_accu[6] + x2*inv_fact_accu[7] +
       x3*inv_fact_accu[8] + x4*inv_fact_accu[9])
  z3 = x10 * (inv_fact_accu[10] + x*inv_fact_accu[11] + x2*inv_fact_accu[12] +
       x3*inv_fact_accu[13] + x4*inv_fact_accu[14])
  z4 = x15 * (inv_fact_accu[15] + x*inv_fact_accu[16] + x2*inv_fact_accu[17] +
       x3*inv_fact_accu[18] + x4*inv_fact_accu[19])
  z5 = x20 * (inv_fact_accu[20] + x*inv_fact_accu[21] + x2*inv_fact_accu[22] +
       x3*inv_fact_accu[23] + x4*inv_fact_accu[24])
  z6 = x25 * (inv_fact_accu[25] + x*inv_fact_accu[26] + x2*inv_fact_accu[27])

  ((((z6+z5)+z4)+z3)+z2)+z + one(Double{T,Accuracy})
end

function exp_taylor(a::Double{T,Performance}) where {T<:AbstractFloat}
  x = a
  x2 = x*x
  x3 = x*x2
  x4 = x2*x2
  x5 = x2*x3
  x10 = x5*x5
  x15 = x5*x10
  x20 = x10*x10
  x25 = x10*x15
  
  z = x + inv_fact_perf[2]*x2 + inv_fact_perf[3]*x3 + inv_fact_perf[4]*x4
  z2 = x5 * (inv_fact_perf[5] + x*inv_fact_perf[6] + x2*inv_fact_perf[7] +
       x3*inv_fact_perf[8] + x4*inv_fact_perf[9])
  z3 = x10 * (inv_fact_perf[10] + x*inv_fact_perf[11] + x2*inv_fact_perf[12] +
       x3*inv_fact_perf[13] + x4*inv_fact_perf[14])
  z4 = x15 * (inv_fact_perf[15] + x*inv_fact_perf[16] + x2*inv_fact_perf[17] +
       x3*inv_fact_perf[18] + x4*inv_fact_perf[19])
  z5 = x20 * (inv_fact_perf[20] + x*inv_fact_perf[21] + x2*inv_fact_perf[22] +
       x3*inv_fact_perf[23] + x4*inv_fact_perf[24])
  z6 = x25 * (inv_fact_perf[25] + x*inv_fact_perf[26] + x2*inv_fact_perf[27])

  ((((z6+z5)+z4)+z3)+z2)+z + one(Double{T,Performance})
end

@inline exp_zero_half(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    exp_taylor(a)

@inline function exp_half_one(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    z = mul_by_half(a)
    z = exp_zero_half(z)
    z = square(z)
    return z
end


function Base.:(^)(r::Double{T,E}, n::Int) where {T<:AbstractFloat, E<:Emphasis}
    if (n == 0)
        iszero(a) && throw(DomainError("0^0"))
        return one(Double{T,E})
    end

    s = one(Double{T,E})
    nabs = abs(n)

    if (nabs > 1)
        while nabs > 0
           if nabs % 2 == 1
              s = s*r
           end
           nabs = div(nabs, 2)
           if nabs > 0
               r = square(r)
           end
        end
    else
        s = r
    end

    if (n < 0)
        s = inv(s)
    end
    return s
end

function Base.:(^)(r::Double{T,E}, n::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
   if isinteger(n)
      return r^Int(n)
   else
      return exp(n * log(r))
   end
end

function Base.:(^)(r::Int, n::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
   if isinteger(n)
      return r^Int(n)
   else
      return exp(n * log(r))
   end
end

function Base.Math.exp(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
  if iszero(HI(a))
    return one(Double{T,E})
  elseif isone(abs(HI(a))) && iszero(LO(a))
    if HI(a) >= zero(T)
        return Double(E, 2.718281828459045, 1.4456468917292502e-16)
    else # isone(-HI(a)) && iszero(LO(a))
        return Double(E, 0.36787944117144233, -1.2428753672788363e-17)
    end
  elseif abs(HI(a)) >= 709.0
      if (HI(a) <= -709.0)
         return zero(Double{T,E})
      else (HI(a) >=  709.0)
         return inf(Double{T,E})
      end
  end

  return calc_exp(a)
end

function calc_exp(a::Double{T,Accuracy}) where {T<:AbstractFloat}

  is_neg = signbit(HI(a))
  xabs = is_neg ? -a : a
  xintpart = modf(xabs)[2]
  xintpart = xintpart.hi + xintpart.lo
  xint = Int64(xintpart)
  xfrac = xabs - T(xint)

  if 0 < xint <= 64
     zint = exp_int_accu[xint]
  elseif xint === zero(Int64)
     zint = zero(Double{T,Accuracy})
  else
     dv, rm = divrem(xint, 64)
     zint = exp_int_accu[64]^dv
     if rm > 0
        	zint = zint * exp_int_accu[rm]
     end
  end

  # exp(xfrac)
  if HI(xfrac) < 0.5
      zfrac = exp_zero_half(xfrac)
  elseif HI(xfrac) > 0.5
      zfrac = exp_half_one(xfrac)
  else
      if LO(xfrac) == 0.0
          zfrac = Double(1.6487212707001282, -4.731568479435833e-17)
      elseif signbit(LO(xfrac))
          zfrac = exp_zero_half(xfrac)
      else
          zfrac = exp_half_one(xfrac)
      end
  end

  z = HI(zint) == zero(T) ? zfrac : zint * zfrac
  if is_neg
      z = inv(z)
  end

  return z
end

function calc_exp(a::Double{T,Performance}) where {T<:AbstractFloat}

  is_neg = signbit(HI(a))
  xabs = is_neg ? -a : a
  xintpart = modf(xabs)[2]
  xintpart = xintpart.hi + xintpart.lo
  xint = Int64(xintpart)
  xfrac = xabs - T(xint)

  if 0 < xint <= 64
     zint = exp_int_perf[xint]
  elseif xint === zero(Int64)
     zint = zero(Double{T,Performance})
  else
     dv, rm = divrem(xint, 64)
     zint = exp_int_perf[64]^dv
     if rm > 0
        	zint = zint * exp_int_perf[rm]
     end
  end

  # exp(xfrac)
  if HI(xfrac) < 0.5
      zfrac = exp_zero_half(xfrac)
  elseif HI(xfrac) > 0.5
      zfrac = exp_half_one(xfrac)
  else
      if LO(xfrac) == 0.0
          zfrac = FastDouble(1.6487212707001282, -4.731568479435833e-17)
      elseif signbit(LO(xfrac))
          zfrac = exp_zero_half(xfrac)
      else
          zfrac = exp_half_one(xfrac)
      end
  end

  z = HI(zint) == zero(T) ? zfrac : zint * zfrac
  if is_neg
      z = inv(z)
  end

  return z
end

#=
# ratio of polys from
# https://github.com/sukop/doubledouble/blob/master/doubledouble.py
function calc_exp_frac(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
  u = (((((((((((x +
                   156.0)*x + 12012.0)*x +
                   600600.0)*x + 21621600.0)*x +
                   588107520.0)*x + 12350257920.0)*x +
                   201132771840.0)*x + 2514159648000.0)*x +
                   23465490048000.0)*x + 154872234316800.0)*x +
                   647647525324800.0)*x + 1295295050649600.0

   v = (((((((((((x -
                   156.0)*x + 12012.0)*x -
                   600600.0)*x + 21621600.0)*x -
                   588107520.0)*x + 12350257920.0)*x -
                   201132771840.0)*x + 2514159648000.0)*x -
                   23465490048000.0)*x + 154872234316800.0)*x -
                   647647525324800.0)*x + 1295295050649600.0

  u = u/v
  return u
end
=#



function Base.Math.expm1(a::Double)
   u = exp(a)
   if (u == one(Double))
       x
   elseif (u-1.0 == -one(Double))
       -one(Double)
   else
       a*(u-1.0) / log(u)
   end
end

function Base.Math.log(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    iszero(x) && return Double(E, T(-Inf), zero(T))
    y = Double(E, log(HI(x)), zero(T))
    z = exp(y)
    adj = (z - x) / (z + x)
    adj = mul_by_two(adj)
    y = y - adj
    return y
end


function Base.Math.log1p(x::Double)
    u = 1.0 + x
    if u == one(Double)
        x
    else
        log(u)*x/(u-1.0)
    end
end

function Base.Math.log2(x::Double)
    log(x) / log2
end

function Base.Math.log10(x::Double)
    log(x) / log10
end

#=
/* Logarithm.  Computes log(x) in double-double precision.
   This is a natural logarithm (i.e., base e).            */
dd_real log(const dd_real &a) {
  /* Strategy.  The Taylor series for log converges much more
     slowly than that of exp, due to the lack of the factorial
     term in the denominator.  Hence this routine instead tries
     to determine the root of the function

         f(x) = exp(x) - a

     using Newton iteration.  The iteration is given by

         x' = x - f(x)/f'(x)
            = x - (1 - a * exp(-x))
            = x + a * exp(-x) - 1.

     Only one iteration is needed, since Newton's iteration
     approximately doubles the number of digits per iteration. */

  if (a.is_one()) {
    return 0.0;
  }

  if (a.x[0] <= 0.0) {
    dd_real::error("(dd_real::log): Non-positive argument.");
    return dd_real::_nan;
  }

  dd_real x = std::log(a.x[0]);   /* Initial approximation */

  x = x + a * exp(-x) - 1.0;
  return x;
}

dd_real log10(const dd_real &a) {
  return log(a) / dd_real::_log10;
}
=#
