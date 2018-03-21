const double_eps = eps(eps(1.0))
const twopi_accuracy    = Double(Accuracy, 6.283185307179586, 2.4492935982947064e-16)
const twopi_performance = Double(Performance, 6.283185307179586, 2.4492935982947064e-16)
const halfpi_accuracy    = Double(Accuracy, 1.5707963267948966, 6.123233995736766e-17)
const halfpi_performance = Double(Performance, 1.5707963267948966, 6.123233995736766e-17)
const pio16_accuracy    = Double(Accuracy, 0.19634954084936207, 7.654042494670958e-18)
const pio16_performance = Double(Performance, 0.19634954084936207, 7.654042494670958e-18)
twopi(::Type{Accuracy}) = twopi_accuracy
twopi(::Type{Performance}) = twopi_performance
halfpi(::Type{Accuracy}) = halfpi_accuracy
halfpi(::Type{Performance}) = halfpi_performance
pio16(::Type{Accuracy}) = pio16_accuracy
pio16(::Type{Performance}) = pio16_performance

const sin_table = [Double(sin(k * big(π) * 0.0625)) for k = 1:4]
const cos_table = [Double(cos(k * big(π) * 0.0625)) for k = 1:4]

function sin(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
  #= 
     Strategy.  To compute sin(x), we choose integers a, b so that

       x = s + a * (pi/2) + b * (pi/16)

     and |s| <= pi/32.  Using the fact that

       sin(pi/16) = 0.5 * sqrt(2 - sqrt(2 + sqrt(2)))

     we can compute sin(x) from sin(s), cos(s).  This greatly
     increases the convergence of the sine Taylor series.
  =#

	if iszero(a)
		return zero(a)
	end

	# approximately reduce modulo 2*pi
	z = round(a / twopi(E))
	r = a - twopi(E) * z

		# approximately reduce modulo pi/2 and then modulo pi/16.

	q = floor(r.hi / halfpi(E).hi + 0.5)
	t = r - halfpi(E) * q
	j = convert(Int, q)
	q = floor(t.hi / pio16(E).hi + 0.5)
	t -= pio16(E) * q
	k = convert(Int, q)
	abs_k = abs(k)

	if j < -2 || j > 2
		# Cannot reduce modulo pi/2.
		return double_nan
	end

	if (abs_k > 4)
		# Cannot reduce modulo pi/16.
		return double_nan
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

function cos(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	if iszero(a)
		return one(a)
	end

	# approximately reduce modulo 2*pi
	z = round(a / twopi(E))
	r = a - twopi(E) * z

		# approximately reduce modulo pi/2 and then modulo pi/16.

	q = floor(r.hi / halfpi(E).hi + 0.5)
	t = r - halfpi(E) * q
	j = convert(Int, q)
	q = floor(t.hi / pio16(E).hi + 0.5)
	t -= pio16(E) * q
	k = convert(Int, q)
	abs_k = abs(k)

	if j < -2 || j > 2
		# Cannot reduce modulo pi/2.
		return double_nan
	end

	if (abs_k > 4)
		# Cannot reduce modulo pi/16.
		return double_nan
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


"""
	sin_taylor(a)

Computes sin(a) using Taylor series. Assumes |a| <= π/32.
"""
function sin_taylor(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	thresh = 0.5 * abs(convert(Float64, a)) * double_eps

	if iszero(a)
		return zero(a)
	end

	i = 1
	x = -square(a)
	s = a
	r = a
	while true
		r *= x
		t = r * inv_fact[i]
		s += t
		i += 2
		if i > ninv_fact || abs(convert(Float64, t)) < thresh
			break
		end
	end

	s
end

"""
	cos_taylor(a)

Computes cos(a) using Taylor series. Assumes |a| <= π/32.
"""
function cos_taylor(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	thresh = 0.5 * double_eps

	if iszero(a)
		return one(a)
	end

	x = -square(a)
	r = x
	s = 1.0 + mul_pwr2(r, 0.5)
	i = 2
	while true
		r *= x
		t = r * inv_fact[i]
		s += t
		i += 2
		if i > ninv_fact || abs(convert(Float64, t)) < thresh
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



function sincos(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
	if iszero(a)
		return zero(a), one(a)
	end

	# approximately reduce modulo 2*pi
	z = round(a / twopi(E))
	r = a - twopi(E) * z

	# approximately reduce modulo pi/2 and then modulo pi/16.
	q = floor(r.hi / pio2(E).hi + 0.5)
	t = r - pio2(E) * q
	j = convert(Int, q)
	abs_j = abs(j)
	q = floor(t.hi / pio16(E).hi + 0.5)
	t -= pio16(E) * q
	k = convert(Int, q)
	abs_k = abs(k)

	if abs_j > 2
		# Cannot reduce modulo pi/2.
		return double_nan, double_nan
	end

	if abs_k > 4
		# Cannot reduce modulo pi/16.
		return double_nan, double_nan
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
