
#=
 Algorithms for triple-word arithmetic
 Nicolas Fabiano, Jean-Michel Muller, Joris Picot
=#

function vecsum(x0::T,x1::T,x2::T) where {T}
   x0 === 0.0 && return (two_sum(x1, x2)..., 0.0)
   s1, e2 = two_sum(x1, x2)
   e0, e1 = two_sum(x0, s1)
   return (e0, e1, e2)
end

function vseb(a0::T, a1::T, a2::T, a3::T, a4::T, a5::T) where {T}
    a2 === 0.0 && return (a0, a1, a2)
	r0, e1 = two_sum(a0, a1)
	if e1 != 0.0
	  y0 = r0
	else
	  e1 = r0
	end
	y1, y2  = two_sum(e1, a2)
	return (y0, y1, y2)
end

function vseb(a0::T, a1::T, a2::T) where {T}
    a2 === 0.0 && return (a0, a1, a2)
	r0, e1 = two_sum(a0, a1)
	if e1 != 0.0
	  y0 = r0
	else
	  e1 = r0
	end
	y1, y2  = two_sum(e1, a2)
	return (y0, y1, y2)
end

function vecseb(x0::T, x1::T, x2::T) where {T}
   a0, a1, a2 = vecsum(x0, x1, x2)
   return vseb(a0, a1, a2)
end

function tripleword(a::T, b::T, c::T) where {T}
    d0, d1 = two_sum(a,b)
    # e0, e1, e2 = vecsum(d0, d1, c)
    s1, e2 = two_sum(d1, c)
    e0, e1 = two_sum(d0, s1)
    # s0, s1, s2 = vseb(e0, e1, e2)
    r0, e1 = two_sum(e0, e1)
	if e1 != 0.0
	  s0 = r0
	else
	  e1 = r0
	end
	s1, s2  = two_sum(e1, e2)
	return (s0, s1, s2)
end

using SetRounding

function Float64(x0::Float64, x1::Float64, x2::Float64)
    s, e = two_hilo_sum(x0, x1+x1)
    if e !== 0.0
        y = x0 + x1
    elseif x2 > 0.0
        setrounding(Float64, RoundUp)
        y = x0 + x1
        setrounding(Float64, RoundNearest) 
    elseif x2 < 0.0
        setrounding(Float64, RoundDown)
        y = x0 + x1
        setrounding(Float64, RoundNearest) 
    else
        y = x0 + x1
    end
    return y
end
