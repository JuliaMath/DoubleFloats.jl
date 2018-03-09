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
   z = fracpart(y)
   return z
end

function modpi(x::Double{T,Accuracy}) where {T<:AbstractFloat}
   y = mul322(triple_inv_1pi, HILO(x))
   z = fracpart(y)
   return z
end

function modhalfpi(x::Double{T,Accuracy}) where {T<:AbstractFloat}
   y = mul322(triple_inv_halfpi, HILO(x))
   z = fracpart(y)
   return z
end

function modqrtrpi(x::Double{T,Accuracy}) where {T<:AbstractFloat}
   y = mul322(triple_invqrtrpi, HILO(x))
   z = fracpart(y)
   return z
end


function mod2pi(x::Double{T,Performance}) where {T<:AbstractFloat}
   y = mul_dddd_dd(double_inv_2pi, HILO(x))
   z = fracpart(y)
   return z
end

function modpi(x::Double{T,Performance}) where {T<:AbstractFloat}
   y = mul_dddd_dd(double_inv_1pi, HILO(x))
   z = fracpart(y)
   return z
end

function modhalfpi(x::Double{T,Performance}) where {T<:AbstractFloat}
   y = mul_dddd_dd(double_inv_halfpi, HILO(x))
   z = fracpart(y)
   return z
end

function modqrtrpi(x::Double{T,Performance}) where {T<:AbstractFloat}
   y = mul_dddd_dd(double_invqrtrpi, HILO(x))
   z = fracpart(y)
   return z
end 
