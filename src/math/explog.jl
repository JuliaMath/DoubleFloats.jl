function mul_by_half(r::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    frhi, xphi = frexp(HI(r))
    frlo, xplo = frexp(LO(r))
    xphi -= 1
    xplo -= 1
    hi = ldexp(frhi, xphi)
    lo = ldexp(frlo, xplo)
    return Double(E, hi, lo)
end

function mul_by_two(r::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    frhi, xphi = frexp(HI(r))
    frlo, xplo = frexp(LO(r))
    xphi += 1
    xplo += 1
    hi = ldexp(frhi, xphi)
    lo = ldexp(frlo, xplo)
    return Double(E, hi, lo)
end

function mul_pow2(r::Double{T,E}, n::Int) where {T<:AbstractFloat, E<:Emphasis}
    frhi, xphi = frexp(HI(r))
    frlo, xplo = frexp(LO(r))
    xphi += n
    xplo += n
    hi = ldexp(frhi, xphi)
    lo = ldexp(frlo, xplo)
    return Double(E, hi, lo)
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

n_inv_fact = 15;
inv_fact = [
  Double{Float64,Accuracy}( 1.66666666666666657e-01,  9.25185853854297066e-18),
  Double{Float64,Accuracy}( 4.16666666666666644e-02,  2.31296463463574266e-18),
  Double{Float64,Accuracy}( 8.33333333333333322e-03,  1.15648231731787138e-19),
  Double{Float64,Accuracy}( 1.38888888888888894e-03, -5.30054395437357706e-20),
  Double{Float64,Accuracy}( 1.98412698412698413e-04,  1.72095582934207053e-22),
  Double{Float64,Accuracy}( 2.48015873015873016e-05,  2.15119478667758816e-23),
  Double{Float64,Accuracy}( 2.75573192239858925e-06, -1.85839327404647208e-22),
  Double{Float64,Accuracy}( 2.75573192239858883e-07,  2.37677146222502973e-23),
  Double{Float64,Accuracy}( 2.50521083854417202e-08, -1.44881407093591197e-24),
  Double{Float64,Accuracy}( 2.08767569878681002e-09, -1.20734505911325997e-25),
  Double{Float64,Accuracy}( 1.60590438368216133e-10,  1.25852945887520981e-26),
  Double{Float64,Accuracy}( 1.14707455977297245e-11,  2.06555127528307454e-28),
  Double{Float64,Accuracy}( 7.64716373181981641e-13,  7.03872877733453001e-30),
  Double{Float64,Accuracy}( 4.77947733238738525e-14,  4.39920548583408126e-31),
  Double{Float64,Accuracy}( 2.81145725434552060e-15,  1.65088427308614326e-31)
]

const k512 = 512.0
const kinv_512 = 0.001953125
const keps_inv_512 = eps(kinv_512)
const klog2 = Double{Float64,Accuracy}(0.6931471805599453, 2.3190468138462996e-17)

function Base.Math.exp(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
  if iszero(a)
    return one(Double{T,E})
  elseif isone(a)
    return Double(E, 2.718281828459045, 1.4456468917292502e-16)
  elseif isone(-a)
    return Double(E, 0.36787944117144233, -1.2428753672788363e-17)
  elseif (HI(a) <= -709.0)
    return zero(Double{T,E})
  elseif (HI(a) >=  709.0)
    return inf(Double{T,E})
  end
  
  m = floor(HI(a) / HI(klog2) + 0.5)
  t = klog2 * m
  t = a - t
  r = t * k_inv512 # mul_pow2(t, -9)
  
  p = square(r)
  s = r + mul_by_half(p)
  p = p * r
  t = p * inv_fact[1]
  i = 0
  while t > keps_inv_512 && i < 5 
    s = s + t
    p = p * r
    i = i + 1
    t = p * inv_fact[i]
  end
  
  s = s + t
  s = mul_by_two(s); s = s + square(s)
  s = mul_by_two(s); s = s + square(s)
  s = mul_by_two(s); s = s + square(s)
  s = mul_by_two(s); s = s + square(s)
  s = mul_by_two(s); s = s + square(s)
  s = mul_by_two(s); s = s + square(s)
  s = mul_by_two(s); s = s + square(s)
  s = mul_by_two(s); s = s + square(s)
  s = mul_by_two(s); s = s + square(s)
  s = s + 1.0

  s = mul_pow2(s, Int(m))
  return s # ldexp(s, static_cast<int>(m));
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
