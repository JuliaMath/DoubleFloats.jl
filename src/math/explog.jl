# [exp(i) for i in 1:64]
const exp_int = [
 Double(2.718281828459045, 1.4456468917292502e-16),
 Double(7.38905609893065, -1.7971139497839148e-16),
 Double(20.085536923187668, -1.8275625525512858e-16),
 Double(54.598150033144236, 2.8741578015844115e-15),
 Double(148.4131591025766, 3.4863514900464198e-15),
 Double(403.4287934927351, 1.2359628024450387e-14),
 Double(1096.6331584284585, 9.869752640434095e-14),
 Double(2980.9579870417283, -2.7103295816873633e-14),
 Double(8103.083927575384, -2.1530877621067177e-13),
 Double(22026.465794806718, -1.3780134700517372e-12),
 Double(59874.14171519782, 1.7895764888916994e-12), 
 Double(162754.79141900392, 5.30065881322063e-12),
 Double(442413.3920089205, 1.2118711752313224e-11),
 Double(1.2026042841647768e6, -1.5000525764327354e-11),
 Double(3.2690173724721107e6, -3.075806431120808e-11),
 Double(8.886110520507872e6, 5.321182483501564e-10),
 Double(2.41549527535753e7, -7.203995068362157e-10),
 Double(6.565996913733051e7, 1.4165536846555444e-9),
 Double(1.7848230096318725e8, 1.333018530234341e-8),
 Double(4.851651954097903e8, 4.880277289790406e-10),
 Double(1.3188157344832146e9, 8.043448618843281e-8),
 Double(3.584912846131592e9, -2.3519384005402157e-7),
 Double(9.744803446248903e9, -6.74501500127677e-7),
 Double(2.648912212984347e10, 7.670395527778119e-7),
 Double(7.200489933738588e10, -6.992440211033874e-6),
 Double(1.9572960942883878e11, -1.1364989227123904e-5),
 Double(5.3204824060179865e11, -2.8335783945658822e-5),
 Double(1.446257064291475e12, 7.602079742299693e-5),
 Double(3.931334297144042e12, 8.220112058084352e-5),
 Double(1.0686474581524463e13, -0.0007436345313492586),
 Double(2.9048849665247426e13, -0.0005501643178883202),
 Double(7.896296018268069e13, 0.007660978022635108),
 Double(2.1464357978591606e14, 0.002124297761531261),
 Double(5.834617425274549e14, 0.006402902734610391),
 Double(1.5860134523134308e15, -0.02187035537422534),
 Double(4.311231547115195e15, 0.22711342229285691),
 Double(1.1719142372802612e16, -0.6912270602088098),
 Double(3.1855931757113756e16, 0.22032867170129863),
 Double(8.659340042399374e16, 2.953606932719265),
 Double(2.3538526683702e17, -14.592100089250966),
 Double(6.398434935300549e17, 37.22266340351557),
 Double(1.739274941520501e18, 55.394681303611236),
 Double(4.727839468229346e18, 257.4744575627443),
 Double(1.2851600114359308e19, -12.1907003678569),
 Double(3.4934271057485095e19, 436.0347972334061),
 Double(9.496119420602448e19, 5929.133649117119),
 Double(2.5813128861900675e20, -15192.714199784727),
 Double(7.016735912097631e20, 30185.471599886117),
 Double(1.9073465724950998e21, -98786.90015904616),
 Double(5.184705528587072e21, 419031.45332293346),
 Double(1.4093490824269389e22, -614323.8566876298),
 Double(3.831008000716577e22, -661524.304512138),
 Double(1.0413759433029089e23, -7.520901270665062e6), 
 Double(2.830753303274694e23, -4.711377645198593e6),
 Double(7.694785265142018e23, -3.868399744098706e7),
 Double(2.091659496012996e24, 5.079641515721467e7),
 Double(5.685719999335932e24, 2.0801558082063326e8),
 Double(1.545538935590104e25, 1.2092033491117463e8),
 Double(4.2012104037905144e25, -1.7624059056928084e9),
 Double(1.1420073898156842e26, 4.912247462314477e9),
 Double(3.10429793570192e26, 3.39761293411071e9),
 Double(8.438356668741454e26, 6.5719328084037315e10),
 Double(2.29378315946961e27, -7.566162968773138e10),
 Double(6.235149080811617e27, 1.3899738872492847e11),
];

const n_inv_fact = 32
const inv_fact = Double{Float64,Accuracy}[
  Double(1.0,0.0),
  Double(0.5,0.0),
  Double(0.16666666666666666,9.25185853854297e-18),
  Double(0.041666666666666664,2.3129646346357427e-18),
  Double(0.008333333333333333,1.1564823173178714e-19),
  Double(0.001388888888888889,-5.300543954373577e-20),
  Double(0.0001984126984126984,1.7209558293420705e-22),
  Double(2.48015873015873e-5,2.1511947866775882e-23),
  Double(2.7557319223985893e-6,-1.858393274046472e-22),
  Double(2.755731922398589e-7,2.3767714622250297e-23),
  Double(2.505210838544172e-8,-1.448814070935912e-24),
  Double(2.08767569878681e-9,-1.20734505911326e-25),
  Double(1.6059043836821613e-10,1.2585294588752098e-26),
  Double(1.1470745597729725e-11,2.0655512752830745e-28),
  Double(7.647163731819816e-13,7.03872877733453e-30),
  Double(4.779477332387385e-14,4.399205485834081e-31),
  Double(2.8114572543455206e-15,1.6508842730861433e-31),
  Double(1.5619206968586225e-16,1.1910679660273754e-32),
  Double(8.22063524662433e-18,2.2141894119604265e-34),
  Double(4.110317623312165e-19,1.4412973378659527e-36),
  Double(1.9572941063391263e-20,-1.3643503830087908e-36),
  Double(8.896791392450574e-22,-7.911402614872376e-38),
  Double(3.868170170630684e-23,-8.843177655482344e-40),
  Double(1.6117375710961184e-24,-3.6846573564509766e-41),
  Double(6.446950284384474e-26,-1.9330404233703465e-42),
  Double(2.4795962632247976e-27,-1.2953730964765229e-43),
  Double(9.183689863795546e-29,1.4303150396787322e-45),
  Double(3.279889237069838e-30,1.5117542744029879e-46),
  Double(1.1309962886447716e-31,1.0498015412959506e-47),
  Double(3.7699876288159054e-33,2.5870347832750324e-49),
  Double(1.216125041553518e-34,5.586290567888806e-51),
  Double(3.8003907548547434e-36,1.7457158024652518e-52)
];


function exp_taylor(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
  x = a
  x2 = x*x
  x3 = x*x2
  x4 = x2*x2
  x5 = x2*x3
  x10 = x5*x5
  x15 = x5*x10
  x20 = x10*x10
  x25 = x10*x15

  z = x + inv_fact[2]*x2 + inv_fact[3]*x3 + inv_fact[4]*x4
  z2 = x5 * (inv_fact[5] + x*inv_fact[6] + x2*inv_fact[7] + x3*inv_fact[8] + x4*inv_fact[9])
  z3 = x10 * (inv_fact[10] + x*inv_fact[11] + x2*inv_fact[12] + x3*inv_fact[13] + x4*inv_fact[14])
  z4 = x15 * (inv_fact[15] + x*inv_fact[16] + x2*inv_fact[17] + x3*inv_fact[18] + x4*inv_fact[19])
  z5 = x20 * (inv_fact[20] + x*inv_fact[21] + x2*inv_fact[22] + x3*inv_fact[23] + x4*inv_fact[24])
  z6 = x25 * (inv_fact[25] + x*inv_fact[26] + x2*inv_fact[27])

  ((((z6+z5)+z4)+z3)+z2)+z + one(Double{T,E})
end

@inline exp_zero_half(a::Double) = exp_taylor(a)

@inline function exp_half_one(a::Double)
    z = mul_by_half(a)
    z = exp_zero_half(z)
    z = square(z)
    return z
end


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

function mul_pwr2(r::Double{T,E}, n::Real) where {T<:AbstractFloat, E<:Emphasis}
    m = 2.0^n	
    return Double(E, HI(r)*m, LO(r)*m)
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
function calc_exp(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	
  is_neg = signbit(HI(a))
  xabs = is_neg ? -a : a  
  xint = Int64(HI(round(xabs, RoundDown)))
  xfrac = xabs - T(xint)
  
  if 0 < xint <= 64
     zint = exp_int[xint]
  elseif xint === zero(Int64)
     zint = zero(Double{T,E})
  else
     dv, rm = divrem(xint, 64)
     zint = exp_int[64]^dv
     if rm > 0
        	zint = zint * exp_int[rm]
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
