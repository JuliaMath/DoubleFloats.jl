const single_halfpi = 1.5707963267948966
const single_1pi = 3.141592653589793
const single_3halvespi = 4.71238898038469

const triple_4pi = (12.566370614359172, 4.898587196589413e-16, -1.1979079238873359e-32)
const double_4pi = (12.566370614359172, 4.898587196589413e-16)
const triple_2pi = (6.283185307179586, 2.4492935982947064e-16, -5.989539619436679e-33)
const double_2pi = (6.283185307179586, 2.4492935982947064e-16)
const triple_1pi = (3.141592653589793, 1.2246467991473532e-16, -2.9947698097183397e-33)
const double_1pi = (3.141592653589793, 1.2246467991473532e-16)
const triple_halfpi = (1.5707963267948966, 6.123233995736766e-17, -1.4973849048591698e-33)
const double_halfpi = (1.5707963267948966, 6.123233995736766e-17)
const triple_qrtrpi = (0.7853981633974483, 3.061616997868383e-17, -7.486924524295849e-34)
const double_qrtrpi = (0.7853981633974483, 3.061616997868383e-17)
const triple_sixthpi = (0.5235987755982989, -5.360408832255455e-17, -4.991283016197232e-34)
const double_sixthpi = (0.5235987755982989, -5.360408832255455e-17)

const triple_inv_4pi = (0.07957747154594767, -4.9196691687956215e-18, -2.680359070723251e-34)
const double_inv_4pi = (0.07957747154594767, -4.9196691687956215e-18)
const triple_inv_2pi = (0.15915494309189535, -9.839338337591243e-18, -5.360718141446502e-34)
const double_inv_2pi = (0.15915494309189535, -9.839338337591243e-18)
const triple_inv_1pi = (0.3183098861837907, -1.9678676675182486e-17, -1.0721436282893004e-33)
const double_inv_1pi = (0.3183098861837907, -1.9678676675182486e-17)
const triple_inv_halfpi = (0.6366197723675814, -3.935735335036497e-17, -2.1442872565786008e-33)
const double_inv_halfpi = (0.6366197723675814, -3.935735335036497e-17)
const triple_inv_qrtrpi = (1.2732395447351628, -7.871470670072994e-17, -4.2885745131572016e-33)
const double_inv_qrtrpi = (1.2732395447351628, -7.871470670072994e-17)
const triple_inv_sixthpi = (1.909859317102744, -7.049757588579267e-18, -2.698859476966472e-34)
const double_inv_sixthpi = (1.909859317102744, -7.049757588579267e-18)


function mod2pi(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    y = mul322(triple_inv_2pi, HILO(x))
    y = fracpart(y)
    z = mul322(triple_2pi, y)
    return z
end

function modpi(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    y = mul322(triple_inv_1pi, HILO(x))
    y = fracpart(y)
    z = mul322(triple_1pi, y)
    return z
end

function modhalfpi(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    y = mul322(triple_inv_halfpi, HILO(x))
    y = fracpart(y)
    z = mul322(triple_halfpi, y)
    return z
end

function modqrtrpi(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    y = mul322(triple_inv_qrtrpi, HILO(x))
    y = fracpart(y)
    z = mul322(triple_qrtrpi, y)
    return z
end


function mod2pi(x::Double{T,Performance}) where {T<:AbstractFloat}
    y = mul_dddd_dd(double_inv_2pi, HILO(x))
    y = fracpart(y)
    z = mul_dddd_dd(double_2pi, y)
    return z
end

function modpi(x::Double{T,Performance}) where {T<:AbstractFloat}
    y = mul_dddd_dd(double_inv_1pi, HILO(x))
    y = fracpart(y)
    z = mul_dddd_dd(double_1pi, y)
    return z
end

function modhalfpi(x::Double{T,Performance}) where {T<:AbstractFloat}
    y = mul_dddd_dd(double_inv_halfpi, HILO(x))
    y = fracpart(y)
    z = mul_dddd_dd(double_halfpi, y)
    return z
end

function modqrtrpi(x::Double{T,Performance}) where {T<:AbstractFloat}
    y = mul_dddd_dd(double_inv_qrtrpi, HILO(x))
    y = fracpart(y)
    z = mul_dddd_dd(double_qrtrpi, y)
    return z
end

function quadrant_angle(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    y = mod2pi(x)
    q = 1
    if signbit(LO(y))
        q += HI(y) > single_halfpi  
        q += HI(y) > single_1pi
        q += HI(y) > single_3halvespi
    else   
        q += HI(y) >= single_halfpi  
        q += HI(y) >= single_1pi
        q += HI(y) >= single_3halvespi
    end
    y = Double(E, modhalfpi(x))
    return q, y
end

const sinfuncs = [ x->sinq1(x), x->cosq1(x), x->-sinq1(x), x->-cosq1(x)]

function sin(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    quadrant, radians = quadrant_angle(x)
    return sinfuncs[quadrant](radians)
end

@inline function cos(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    return sin(x + double_halfpi)
end

function tan(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    return sin(x) / cos(x)
end

@inline sinq1(radians::Double{T,Performance}) where {T<:AbstractFloat} =
    sinq1(Double(Accuracy,HI(radians),LO(radians))
    
function sinq1(radians::Double{T,Accuracy}) where {T<:AbstractFloat}
    radians < 9/64 && return sin_taylor(radians)
    
    rad13th = radians / 13.0
    sin13th = sin_taylor(rad13th)
    sinx = sin13x(sin13th)
    return sinx
end


# http://mathworld.wolfram.com/Multiple-AngleFormulas.html find Bromwich
# sin(13*x) = (sin13x_numer ./ oddfact7) .* xs7(x)
#sinnumer7(n)=[n, -n*(n^2-1^2), n*(n^2-1^2)*(n^2-3^2), -n*(n^2-1^2)*(n^2-3^2)*(n^2-5^2), n*(n^2-1^2)*(n^2-3^2)*(n^2-5^2)*(n^2-7^2),-n*(n^2-1^2)*(n^2-3^2)*(n^2-5^2)*(n^2-7^2)*(n^2-9^2),n*(n^2-1^2)*(n^2-3^2)*(n^2-5^2)*(n^2-7^2)*(n^2-9^2)*(n^2-11^2), -n*(n^2-1^2)*(n^2-3^2)*(n^2-5^2)*(n^2-7^2)*(n^2-9^2)*(n^2-11^2)*(n^2-13^2)];
#sin13x_numer = [13, -2184, 349440, -50319360, 6038323200, -531372441600, 25505877196800]
#sin13x_denom = [1, 6, 120, 5040, 362880, 39916800, 6227020800]
#sin13x_coeff = [13, -364, 2912, -9984, 16640, -13312, 4096]
#    
#[factorial(i) for i in 1:2:13];
#zs7(x)=[x,x^3,x^5,x^7,x^9,x^11,x^13];
#xs7(x)=zs7(sin(x));

sin13x_coeff = (13.0, -364.0, 2912.0, -9984.0, 16640.0, -13312.0, 4096.0)

function xs7(s)
    s2 = s*s
    s3 = s2*s
    s4 = s2*s2
    s5 = s3*s2
    s6 = s3*s3
    s7 = s4*s3
    s9 = s5*s4
    s11 = s6*s5
    s13 = s7*s6
    return (s,s3,s5,s7,s9,s11,s13)
end

# x in 0.0 .. 9/64
function sin13x(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    s = sin_taylor(x)
    xs = xs7(s)
    result = zero(typeof(x))
    for i in 1:7
        result += sin13x_coeff[i] * xs[i]
    end
    return result
end

# a <= 9/64
function sin_taylor(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
  x = a
  x2 = x*x
  x3 = x*x2
  x4 = x2*x2
  x5 = x2*x3
  x6 = x3*x3
  x7 = x3*x4
  x8 = x4*x4
  x9 = x4*x5
  x17 = x8*x9
  x25 = x17*x8

  z = x + x*(-inv_fact[3]*x2 + inv_fact[5]*x4 - inv_fact[7]*x6)
  z2 = x9 * (inv_fact[9] - x2*inv_fact[11] + x4*inv_fact[13] - x6*inv_fact[15])
  z3 = x17 * (inv_fact[17] - x2*inv_fact[19] + x4*inv_fact[21] - x6*inv_fact[23])
  z4 = x25 * (inv_fact[25] - x2*inv_fact[27] + x4*inv_fact[29] - x6*inv_fact[31])

  z4 = z4+z3
  z4 = z4+z2
  z  = z + z4
  return z # (z + ((z4+z3)+z2))
end

# a <= 9/64
function cos_taylor(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
  x = a
  x2 = x*x
  x4 = x2*x2
  x6 = x2*x4
  x8 = x4*x4
  x16 = x8*x8
  x24 = x8*x16

  z = (-inv_fact[2]*x2 + inv_fact[4]*x4 - inv_fact[6]*x6)
  z2 = x8 * (inv_fact[8] - x2*inv_fact[10] + x4*inv_fact[12] - x6*inv_fact[14])
  z3 = x16 * (inv_fact[16] - x2*inv_fact[18] + x4*inv_fact[20] - x6*inv_fact[22])
  z4 = x24 * (inv_fact[24] - x2*inv_fact[26] + x4*inv_fact[28] - x6*inv_fact[30])

  #((z4+z3)+z2)+z + 1.0
  z4 = z4 + z3
  z4 = z4 + z2
  z  = z  + z4
  z  = z  + one(Double{T,E})
  return z
end

# for a < 9/64 0.140625
function tan_taylor(a::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
  x = a
  x2 = x*x
  x3 = x*x2
  x4 = x2*x2
  x5 = x2*x3
  x6 = x3*x3
  x7 = x3*x4
  x8 = x4*x4
  x9 = x4*x5
  x17 = x8*x9
  x25 = x17*x8

  z = x + x*(tan_coeff[2]*x2 + tan_coeff[3]*x4 + tan_coeff[4]*x6)
  z2 = x9 * (tan_coeff[5] + x2*tan_coeff[6] + x4*tan_coeff[7] + x6*tan_coeff[8])
  z3 = x17 * (tan_coeff[9] + x2*tan_coeff[10] + x4*tan_coeff[11] + x6*tan_coeff[12])
  z4 = x25 * (tan_coeff[13] + x2*tan_coeff[14] + x4*tan_coeff[15] + x6*tan_coeff[16])

  # (z + ((z4+z3)+z2))
  z4 = z4 + z3
  z4 = z4 + z2
  z  = z  + z4
  return z
end
