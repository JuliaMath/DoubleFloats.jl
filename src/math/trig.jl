# adopted wholesale from HigherPrecision
#
# ROUNDING
#
@inline function Base.round(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi = round(a.hi)
    lo = 0.0

    if hi == a.hi
        # High word is an integer already.  Round the low word.
        lo = round(a.lo)

        # Renormalize. This is needed if hi = some integer, lo = 1/2.
        hi, lo = add_hilo_2(hi, lo)
    else
        # High word is not an integer.
        if abs(hi-a.hi) == 0.5 && a.lo < 0.0
            # There is a tie in the high word, consult the low word to break the tie.
            hi -= 1.0
        end
    end

     Double(E, hi, lo)
end

# constants

const d_eps = Double(4.930380657631324e-32, 0.0)
const d_2pi = Double(6.283185307179586, 2.4492935982947064e-16)
const d_pi2 = Double(1.5707963267948966, 6.123233995736766e-17)
const d_pi16 = Double(0.19634954084936207, 7.654042494670958e-18)
const d_nan = Double(NaN, 0.0)

# Precomputed values

const inv_factorial = [Double(1.0 / BigFloat(factorial(k))) for k = 3:17]
const ninv_factorial = length(inv_factorial)

const sin_table = [Double(sin(k * big(π) * 0.0625)) for k = 1:4]
const cos_table = [Double(cos(k * big(π) * 0.0625)) for k = 1:4]


"""
	sin_taylor(a::Double{T,E})
Computes sin(a) using Taylor series. Assumes |a| <= π/32.
"""
function sin_taylor(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	thresh = 0.5 * abs(convert(Float64, a)) * d_eps


	if iszero(a)
		return zero(a)
	end

	i = 1
	x = -square(a)
	s = a
	r = a
	while true
		r *= x
		t = r * inv_factorial[i]
		s += t
		i += 2
		if i > ninv_factorial || abs(convert(Float64, t)) < thresh
			break
		end
	end

	s
end

"""
	cos_taylor(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
Computes cos(a) using Taylor series. Assumes |a| <= π/32.
"""
function cos_taylor(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	thresh = 0.5 * d_eps

	if iszero(a)
		return one(a)
	end

	x = -square(a)
	r = x
	s = 1.0 + mul_pwr2(r, 0.5)
	i = 2
	while true
		r *= x
		t = r * inv_factorial[i]
		s += t
		i += 2
		if i > ninv_factorial || abs(convert(Float64, t)) < thresh
			break
		end
	end

	s
end

function sincos_taylor(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	if iszero(a)
		zero(a), one(a)
	end

  	sin_a = sin_taylor(a)
  	cos_a = sqrt(1.0 - square(sin_a))

  	sin_a, cos_a
end

function Base.sin(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
  #= Strategy.  To compute sin(x), we choose integers a, b so that
       x = s + a * (pi/2) + b * (pi/16)
     and |s| <= pi/32.  Using the fact that
       sin(pi/16) = 0.5 * sqrt(2 - sqrt(2 + sqrt(2)))
     we can compute sin(x) from sin(s), cos(s).  This greatly
     increases the convergence of the sine Taylor series. =#

	if iszero(a)
		return zero(a)
	end

	# approximately reduce modulo 2*pi
	z = round(a / d_2pi)
	r = a - d_2pi * z

		# approximately reduce modulo pi/2 and then modulo pi/16.

	q = floor(r.hi / d_pi2.hi + 0.5)
	t = r - d_pi2 * q
	j = convert(Int, q)
	q = floor(t.hi / d_pi16.hi + 0.5)
	t -= d_pi16 * q
	k = convert(Int, q)
	abs_k = abs(k)

	if j < -2 || j > 2
		# Cannot reduce modulo pi/2.
		return d_nan
	end

	if (abs_k > 4)
		# Cannot reduce modulo pi/16.
		return d_nan
	end

	if k == 0
		if j == 0
			return sin_taylor(t)
		elseif j == 1
			return cos_taylor(t)
		elseif j == -1
			return -cos_taylor(t)
		else
			return -sin_taylor(t)
		end
	end

	u = cos_table[abs_k]
	v = sin_table[abs_k]
  	sin_t, cos_t = sincos_taylor(t)

	if j == 0
		r = k > 0 ? u * sin_t + v * cos_t : u * sin_t - v * cos_t
  	elseif j == 1
		r = k > 0 ? u * cos_t - v * sin_t : u * cos_t + v * sin_t
	elseif j == -1
		r = k > 0 ? v * sin_t - u * cos_t : -u * cos_t - v * sin_t
	else
		r = k > 0 ? -u * sin_t - v * cos_t : v * cos_t - u * sin_t
	end

	r
end

function Base.cos(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	if iszero(a)
		return one(a)
	end

	# approximately reduce modulo 2*pi
	z = round(a / d_2pi)
	r = a - d_2pi * z

		# approximately reduce modulo pi/2 and then modulo pi/16.

	q = floor(r.hi / d_pi2.hi + 0.5)
	t = r - d_pi2 * q
	j = convert(Int, q)
	q = floor(t.hi / d_pi16.hi + 0.5)
	t -= d_pi16 * q
	k = convert(Int, q)
	abs_k = abs(k)

	if j < -2 || j > 2
		# Cannot reduce modulo pi/2.
		return d_nan
	end

	if (abs_k > 4)
		# Cannot reduce modulo pi/16.
		return d_nan
	end

	if k == 0
		if j == 0
			return cos_taylor(t)
		elseif j == 1
			return -sin_taylor(t)
		elseif j == -1
			return sin_taylor(t)
		else
			return -cos_taylor(t)
		end
	end

	u = cos_table[abs_k]
	v = sin_table[abs_k]
  	sin_t, cos_t = sincos_taylor(t)

	if j == 0
		r = k > 0 ? u * cos_t - v * sin_t : u * cos_t + v * sin_t
  	elseif j == 1
		r = k > 0 ? -u * sin_t - v * cos_t : v * cos_t - u * sin_t
	elseif j == -1
		r = k > 0 ? u * sin_t + v * cos_t : u * sin_t - v * cos_t
	else
		r = k > 0 ? v * sin_t - u * cos_t : -u * cos_t - v * sin_t
	end

	r
end


function _sincos(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	if iszero(a)
		return zero(a), one(a)
	end

	# approximately reduce modulo 2*pi
	z = round(a / d_2pi)
	r = a - d_2pi * z

	# approximately reduce modulo pi/2 and then modulo pi/16.
	q = floor(r.hi / d_pi2.hi + 0.5)
	t = r - d_pi2 * q
	j = convert(Int, q)
	abs_j = abs(j)
	q = floor(t.hi / d_pi16.hi + 0.5)
	t -= d_pi16 * q
	k = convert(Int, q)
	abs_k = abs(k)

	if abs_j > 2
		# Cannot reduce modulo pi/2.
		return d_nan, d_nan
	end

	if abs_k > 4
		# Cannot reduce modulo pi/16.
		return d_nan, d_nan
	end

  	sin_t, cos_t = sincos_taylor(t)

	if abs_k == 0
		s = sin_t
		c = cos_t
	else
		u = cos_table[abs_k]
		v = sin_table[abs_k]

		s = k > 0 ? u * sin_t + v * cos_t : u * sin_t - v * cos_t
		c = k > 0 ? u * cos_t - v * sin_t : u * cos_t + v * sin_t
	end

	if j == 0
		s, c
  	elseif j == 1
		c, -s
	elseif j == -1
		-c, s
	else
		-s, -c
	end
end

# if VERSION > v"0.7.0-DEV.1319"
# 	@inline Base.sincos(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = _sincos(a)
# else
export sincos
"""
	sincos(x)
Compute `(sin(x), cos(x))`. This is faster than computing the values
separetly.
"""
@inline sincos(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = _sincos(a)
# end

Base.atan(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = atan2(a, one(a))

function Base.atan2(y::Double{T,E}, x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	#= Strategy: Instead of using Taylor series to compute
     arctan, we instead use Newton's iteration to solve
     the equation
        sin(z) = y/r    or    cos(z) = x/r
     where r = sqrt(x^2 + y^2).
     The iteration is given by
        z' = z + (y - sin(z)) / cos(z)          (for equation 1)
        z' = z - (x - cos(z)) / sin(z)          (for equation 2)
     Here, x and y are normalized so that x^2 + y^2 = 1.
     If |x| > |y|, then first iteration is used since the
     denominator is larger.  Otherwise, the second is used.
  	=#
	if iszero(x)
		if iszero(y)
			d_nan
		end

		return y.hi > 0.0 ? d_pi2 : -d_pi2
	elseif iszero(y)
		return x.hi > 0.0 ? zero(x) : d_pi
	end

	if x == y
		return y.hi > 0.0 ? d_pi4 : -d_3pi4
	end

	if x == -y
		return y.hi > 0.0 ? d_3pi4 : -d_pi4
	end

	r = sqrt(square(x) + square(y))
	xx = x / r
	yy = y / r

	# Compute double precision approximation to atan.
	z = Double{T,E}(atan2(convert(Float64, y), convert(Float64, x)))

	if abs(xx.hi) > abs(yy.hi)
		# Use Newton iteration 1.  z' = z + (y - sin(z)) / cos(z)
		sin_z, cos_z = _sincos(z)
		z += (yy - sin_z) / cos_z
	else
		# Use Newton iteration 2.  z' = z - (x - cos(z)) / sin(z)
		sin_z, cos_z = _sincos(z)
		z -= (xx - cos_z) / sin_z
	end

	z
end

function Base.tan(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	s, c = _sincos(a)
	s / c
end

function Base.asin(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	abs_a = abs(a)

	if abs_a > 1.0
		throw(DomainError())
	end

	if isone(abs_a)
		return a.hi > 0.0 ? d_pi2 : -d_pi2
	end

	atan2(a, sqrt(1.0 - square(a)))
end

function Base.acos(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	abs_a = abs(a)

	if abs_a > 1.0
		throw(DomainError())
	end

	if isone(abs_a)
		return a.hi > 0.0 ? zero(a) : -d_pi
	end

	atan2(sqrt(1.0 - square(a)), a)
end


function Base.sinh(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	if iszero(a)
		return zero(a)
	end
	if a > 0.05 || a < -0.05
		ea = exp(a)
		return mul_pwr2(ea - inv(ea), 0.5)
	end

	# The computation below didn't yield a satisfying accuracy
	# Thus we just fallback to the Float64 formula which yields at least
	# a
	return Double{T,E}(sinh(convert(Float64, a)))

	#
	#
	# #=  since a is small, using the above formula gives
    # a lot of cancellation.  So use Taylor series. =#
	# s = a
	# t = a
	# r = square(t)
	# m = 1.0
	# thresh = abs(convert(Float64, a)) * d_eps
	#
	# while true
	# 	m += 2.0
	# 	t *= r
	# 	t /= (m - 1) * m
	#
	# 	s += t
	#
	# 	if abs(t) < thresh
	# 		break
	# 	end
	# end
	#
	# s
end

function Base.cosh(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	if iszero(a)
		return one(a)
	end
	ea = exp(a)
	mul_pwr2(ea + inv(ea), 0.5)
end

"""
	sincosh(x)
Compute `(sinh(x), cosh(x))`. This is faster than computing the values
separetly.
"""
function sincosh(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	if abs(convert(Float64, a)) ≤ 0.05
		s = sinh(a)
		c = sqrt(1.0 + square(s))
	else
		ea = exp(a)
		inv_ea = inv(ea)
		s = mul_pwr2(ea - inv_ea, 0.5)
		c = mul_pwr2(ea + inv_ea, 0.5)
	end
	s, c
end

function Base.tanh(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	if iszero(a)
		return zero(a)
	end
	if abs(convert(Float64, a)) > 0.05
		ea = exp(a)
		inv_ea = inv(ea)
		return (ea - inv_ea) / (ea + inv_ea)
	else
		s = sinh(a)
		c = sqrt(1.0 + square(s))
		return s / c
	end
end
