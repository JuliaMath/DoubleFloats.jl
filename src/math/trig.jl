for (F,P) in ((:sin, :sin2pi), (:cos, :cos2pi), (:tan, :tan2pi), 
              (:csc, :csc2pi), (:sec, :sec2pi), (:cot, :cot2pi))
  @eval $F(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} = $P(mod2pi(x))
end

const quadrant_sin = [x ->  sin_quadrant(x), x ->  cos_quadrant(x),
                      x -> -sin_quadrant(x), x -> -cos_quadrant(x)]

function sin2pi(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    n = x / double_halfpi
    n += 0.5
    n = floor(n)
    quadrant = Int64(n) + 1 
    x = x - (n * double_halfpi)
    z = quadrant_sin[quadrant](x)
    return z
end

const quadrant_cos = [x ->  cos_quadrant(x), x -> -sin_quadrant(x),
                      x -> -cos_quadrant(x), x ->  sin_quadrant(x)]

function cos2pi(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    n = x / double_halfpi
    n += 0.5
    n = floor(n)
    quadrant = Int64(n) + 1 
    x = x - (n * double_halfpi)
    z = quadrant_cos[quadrant](x)
    return z
end

# sin(x in 0.0..pi/2)
function quadrant_sin(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
   bf = BigFloat(x.hi) + BigFloat(x.lo)
   bf = sin(bf)
   hi = T(bf)
   lo = T(bf - hi)
   return Double(E, hi, lo)
end

# cos(x in 0.0..pi/2)
function quadrant_cos(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
   bf = BigFloat(x.hi) + BigFloat(x.lo)
   bf = cos(bf)
   hi = T(bf)
   lo = T(bf - hi)
   return Double(E, hi, lo)    
end

#=
function sin2pi(x)
    if x < double_1pi
       sin1(x)
    else
       x = x - double_1pi
       -sin1(x)
    end
end

@inline function sin1(x)
    if x < double_halfpi
        sin2(x)
    else
        x = x - double_halfpi
        cos2(x)
    end
end

@inline function sin2(x)
    if x < double_qrtrpi
        sin_qrtrpi(x)
    else
        x = double_halfpi - x
        cos_qrtrpi(x)
    end
end

@inline function cos2(x)
    if x < double_qrtrpi
        cos_qrtrpi(x)
    else
        x = double_halfpi - x
        sin_qrtrpi(x)
    end
end

=#
