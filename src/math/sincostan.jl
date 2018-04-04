
const double_eps = eps(eps(1.0))
const twopi_accuracy     = Double(Accuracy, 6.283185307179586, 2.4492935982947064e-16)
const twopi_performance  = Double(Performance, 6.283185307179586, 2.4492935982947064e-16)
const halfpi_accuracy    = Double(Accuracy, 1.5707963267948966, 6.123233995736766e-17)
const halfpi_performance = Double(Performance, 1.5707963267948966, 6.123233995736766e-17)
const pio16_accuracy     = Double(Accuracy, 0.19634954084936207, 7.654042494670958e-18)
const pio16_performance  = Double(Performance, 0.19634954084936207, 7.654042494670958e-18)

const inv_factorial = [
    Double(1.66666666666666657e-01,  9.25185853854297066e-18),
    Double(4.16666666666666644e-02,  2.31296463463574266e-18),
    Double(8.33333333333333322e-03,  1.15648231731787138e-19),
    Double(1.38888888888888894e-03, -5.30054395437357706e-20),
    Double(1.98412698412698413e-04,  1.72095582934207053e-22),
    Double(2.48015873015873016e-05,  2.15119478667758816e-23),
    Double(2.75573192239858925e-06, -1.85839327404647208e-22),
    Double(2.75573192239858883e-07,  2.37677146222502973e-23),
    Double(2.50521083854417202e-08, -1.44881407093591197e-24),
    Double(2.08767569878681002e-09, -1.20734505911325997e-25),
    Double(1.60590438368216133e-10,  1.25852945887520981e-26),
    Double(1.14707455977297245e-11,  2.06555127528307454e-28),
    Double(7.64716373181981641e-13,  7.03872877733453001e-30),
    Double(4.77947733238738525e-14,  4.39920548583408126e-31),
    Double(2.81145725434552060e-15,  1.65088427308614326e-31),
    Double(1.56192069685862250e-16,  1.19106796602737540e-32),
    Double(8.22063524662433000e-18,  2.21418941196042650e-34),
    Double(4.11031762331216500e-19,  1.44129733786595270e-36),
    #Double(1.95729410633912630e-20, -1.36435038300879080e-36),
    #Double(8.89679139245057400e-22, -7.91140261487237600e-38),
    #Double(3.86817017063068400e-23, -8.84317765548234400e-40),
    #Double(1.61173757109611840e-24, -3.68465735645097660e-41)
]

const ninv_factorial = length(inv_factorial)
const ninv_factorial_performance = ninv_factorial - 4

#=
     sin(a) from the Taylor series.
     Assumes |a| <= pi/32.
=#
function sin_taylor(a::Double{Float64, Accuracy})
    iszero(a) && return(a)

    x = -square(a)
    r = a
    for i = 3:2:ninv_factorial
        r = r * x
        t = r * inv_fact[i]
        a = a + t
    end

    return a
end


#=
   1 - x^2/2! + x^4/4! - x^6/6! + x^8/8! ...
=#
function cos_taylor(a::Double{Float64, Accuracy})
    iszero(a) && return(one(Double{Float64, Accuracy}))

    x2 = square(a)
    r = one(a)
    a = one(a)
    for i = 2:4:(ninv_factorial-2)
        r = r * x2
        t = r * inv_fact[i]
        a = a - t
        r = r * x2
        t = r * inv_fact[i+2]
        a = a + t
    end

    return a
end

function sincos_taylor(a::Double{Float64, Accuracy})
    if iszero(a)
        return a, (one(Double{Float64, Accuracy}))
    end
    s = sin_taylor(a)
    c = cos_taylor(a)
    return s,c
end


function tan_taylor(a::Double{Float64, Accuracy})
    s, c = sincos_taylor(a)
    return s/c
end

function csc_taylor(a::Double{Float64, Accuracy})
    return inv(sin_taylor(a))
end

function sec_taylor(a::Double{Float64, Accuracy})
    return inv(cos_taylor(a))
end

function cot_taylor(a::Double{Float64, Accuracy})
    s, c = sincos_taylor(a)
    return c/s
end



function sin_taylor(a::Double{Float64, Performance})
    iszero(a) && return(a)

    x = -square(a)
    r = a
    for i = 3:2:ninv_factorial_performance
        r = r * x
        t = r * inv_fact[i]
        a = a + t
    end

    return a
end

#=
   1 - x^2/2! + x^4/4! - x^6/6! + x^8/8! ...
=#
function cos_taylor(a::Double{Float64, Performance})
    iszero(a) && return(one(Double{Float64, Performance}))

    x2 = square(a)
    r = one(a)
    a = one(a)
    for i = 2:4:(ninv_factorial_performance-2)
        r = r * x2
        t = r * inv_fact[i]
        a = a - t
        r = r * x2
        t = r * inv_fact[i+2]
        a = a + t
    end

    return a
end

function sincos_taylor(a::Double{Float64, Performance})
    if iszero(a)
        return a, (one(Double{Float64, Performance}))
    end

    s = sin_taylor(a)
    c = cos_taylor(a)
    return s,c
end


function tan_taylor(a::Double{Float64, Performance})
    s, c = sincos_taylor(a)
    return s/c
end

function csc_taylor(a::Double{Float64, Performance})
    return inv(sin_taylor(a))
end

function sec_taylor(a::Double{Float64, Performance})
    return inv(cos_taylor(a))
end

function cot_taylor(a::Double{Float64, Performance})
    s, c = sincos_taylor(a)
    return c/s
end

#=
function spi32()
    pis=[];sines=[];cosines=[]
    for i = 0:64
        n=Float64(i) * Double(pi)/Float64(32)
        push!(pis,n)
        bf = BigFloat(n.hi)+BigFloat(n.lo)
        s = sin(bf)
        c = cos(bf)
        shi = Float64(s); slo = Float64(s-shi)
        chi = Float64(c); clo = Float64(c-chi)
        push!(sines,Double(shi,slo))
        push!(cosines,Double(chi,clo))
    end
    return (pis),(sines), (cosines)
end
=#

npio32 = (
Double(0.0, 0.0),
Double(0.09817477042468103, 3.827021247335479e-18),
Double(0.19634954084936207, 7.654042494670958e-18),
Double(0.2945243112740431, 1.1481063742006436e-17),
Double(0.39269908169872414, 1.5308084989341915e-17),
Double(0.4908738521234052, 1.9135106236677395e-17),
Double(0.5890486225480862, 2.296212748401287e-17),
Double(0.6872233929727672, 2.678914873134835e-17),
Double(0.7853981633974483, 3.061616997868383e-17),
Double(0.8835729338221293, 3.444319122601931e-17),
Double(0.9817477042468103, 3.827021247335479e-17),
Double(1.0799224746714915, -6.89250687418254e-17),
Double(1.1780972450961724, 4.592425496802574e-17),
Double(1.2762720155208536, -6.127102624715443e-17),
Double(1.3744467859455345, 5.35782974626967e-17),
Double(1.4726215563702156, -5.3616983752483455e-17),
Double(1.5707963267948966, 6.123233995736766e-17),
Double(1.6689710972195777, -4.5962941257812514e-17),
Double(1.7671458676442586, 6.888638245203862e-17),
Double(1.8653206380689398, -3.830889876314156e-17),
Double(1.9634954084936207, 7.654042494670958e-17),
Double(2.061670178918302, -3.06548562684706e-17),
Double(2.159844949342983, -1.378501374836508e-16),
Double(2.2580197197676637, 1.9904379115123167e-16),
Double(2.356194490192345, 9.184850993605148e-17),
Double(2.454369260617026, -1.5346771279128684e-17),
Double(2.552544031041707, -1.2254205249430885e-16),
Double(2.650718801466388, 2.1435187614057358e-16),
Double(2.748893571891069, 1.071565949253934e-16),
Double(2.84706834231575, -3.868628978676964e-20),
Double(2.9452431127404313, -1.0723396750496691e-16),
Double(3.0434178831651124, -2.144292487201471e-16),
Double(3.141592653589793, 1.2246467991473532e-16),
Double(3.2397674240144743, 1.5269398699555146e-17),
Double(3.3379421944391554, -9.192588251562503e-17),
Double(3.4361169648638366, -1.991211637308052e-16),
Double(3.5342917352885173, 1.3777276490407724e-16),
Double(3.6324665057131984, 3.057748368889706e-17),
Double(3.7306412761378795, -7.661779752628312e-17),
Double(3.8288160465625607, -1.838130787414633e-16),
Double(3.9269908169872414, 1.5308084989341916e-16),
Double(4.025165587411923, -3.9820364117182366e-16),
Double(4.123340357836604, -6.13097125369412e-17),
Double(4.221515128261284, 2.755842160979412e-16),
Double(4.319689898685966, -2.757002749673016e-16),
Double(4.417864669110647, 6.11936536675809e-17),
Double(4.516039439535327, 3.9808758230246333e-16),
Double(4.614214209960009, -1.5319690876277947e-16),
Double(4.71238898038469, 1.8369701987210297e-16),
Double(4.810563750809371, -3.675874711931398e-16),
Double(4.908738521234052, -3.069354255825737e-17),
Double(5.006913291658733, 3.062003860766251e-16),
Double(5.105088062083414, -2.450841049886177e-16),
Double(5.203262832508095, 9.180982364626472e-17),
Double(5.301437602932776, 4.2870375228114717e-16),
Double(5.399612373357457, -1.2258073878409563e-16),
Double(5.497787143782138, 2.143131898507868e-16),
Double(5.5959619142068195, -3.36971301214456e-16),
Double(5.6941366846315, -7.737257957353928e-20),
Double(5.792311455056181, 3.368165560553089e-16),
Double(5.8904862254808625, -2.1446793500993382e-16),
Double(5.988660995905543, 1.2242599362494854e-16),
Double(6.086835766330225, -4.288584974402942e-16),
Double(6.1850105367549055, -9.19645688054118e-17),
#Double(6.283185307179586, 2.4492935982947064e-16)
)

sin_npio32 = (
Double(0.0, 0.0),
Double(0.0980171403295606, -1.634582362244256e-18),
Double(0.19509032201612828, -7.99107906846173e-18),
Double(0.2902846772544624, -1.892797870777425e-17),
Double(0.3826834323650898, -1.0050772696461588e-17),
Double(0.47139673682599764, 6.5166781360690145e-18),
Double(0.5555702330196022, 4.709410940561677e-17),
Double(0.6343932841636455, 1.0420901929280035e-17),
Double(0.7071067811865476, -4.833646656726457e-17),
Double(0.773010453362737, -3.256590703364977e-17),
Double(0.8314696123025452, 1.4073856984728037e-18),
Double(0.881921264348355, -1.9843248405890568e-17),
Double(0.9238795325112867, 1.7645047084336677e-17),
Double(0.9569403357322088, 4.05538698618757e-17),
Double(0.9807852804032304, 1.8546939997825006e-17),
Double(0.9951847266721969, -4.2486913678304403e-17),
Double(1.0, -1.1210807766491662e-66),
Double(0.9951847266721969, -4.248691367830441e-17),
Double(0.9807852804032304, 1.8546939997825003e-17),
Double(0.9569403357322088, 4.05538698618757e-17),
Double(0.9238795325112867, 1.7645047084336674e-17),
Double(0.881921264348355, -1.9843248405890562e-17),
Double(0.8314696123025452, 1.4073856984728124e-18),
Double(0.773010453362737, -3.256590703364977e-17),
Double(0.7071067811865476, -4.833646656726456e-17),
Double(0.6343932841636455, 1.0420901929280033e-17),
Double(0.5555702330196022, 4.7094109405616756e-17),
Double(0.47139673682599764, 6.516678136069009e-18),
Double(0.3826834323650898, -1.0050772696461588e-17),
Double(0.2902846772544624, -1.892797870777425e-17),
Double(0.19509032201612828, -7.991079068461768e-18),
Double(0.0980171403295606, -1.6345823622442887e-18),
Double(-2.9947698097183397e-33, 1.1124542208633653e-49),
Double(-0.0980171403295606, 1.6345823622442521e-18),
Double(-0.19509032201612828, 7.991079068461727e-18),
Double(-0.2902846772544624, 1.892797870777424e-17),
Double(-0.3826834323650898, 1.0050772696461581e-17),
Double(-0.47139673682599764, -6.5166781360690145e-18),
Double(-0.5555702330196022, -4.709410940561676e-17),
Double(-0.6343932841636455, -1.0420901929280028e-17),
Double(-0.7071067811865476, 4.833646656726456e-17),
Double(-0.773010453362737, 3.2565907033649785e-17),
Double(-0.8314696123025452, -1.407385698472802e-18),
Double(-0.881921264348355, 1.9843248405890578e-17),
Double(-0.9238795325112867, -1.7645047084336662e-17),
Double(-0.9569403357322088, -4.05538698618757e-17),
Double(-0.9807852804032304, -1.8546939997825006e-17),
Double(-0.9951847266721969, 4.248691367830441e-17),
Double(-1.0, 3.068418716632831e-65),
Double(-0.9951847266721969, 4.248691367830441e-17),
Double(-0.9807852804032304, -1.8546939997825003e-17),
Double(-0.9569403357322088, -4.0553869861875694e-17),
Double(-0.9238795325112867, -1.7645047084336668e-17),
Double(-0.881921264348355, 1.9843248405890565e-17),
Double(-0.8314696123025452, -1.407385698472797e-18),
Double(-0.773010453362737, 3.256590703364977e-17),
Double(-0.7071067811865476, 4.833646656726457e-17),
Double(-0.6343932841636455, -1.0420901929280039e-17),
Double(-0.5555702330196022, -4.709410940561676e-17),
Double(-0.47139673682599764, -6.516678136069028e-18),
Double(-0.3826834323650898, 1.0050772696461658e-17),
Double(-0.2902846772544624, 1.8927978707774248e-17),
Double(-0.19509032201612828, 7.991079068461796e-18),
Double(-0.0980171403295606, 1.6345823622442672e-18),
#Double(5.989539619436679e-33, -2.2249084417267306e-49)
)

cos_npio32 = (
Double(1.0, 0.0),
Double(0.9951847266721969, -4.248691367830441e-17),
Double(0.9807852804032304, 1.8546939997825006e-17),
Double(0.9569403357322088, 4.05538698618757e-17),
Double(0.9238795325112867, 1.7645047084336677e-17),
Double(0.881921264348355, -1.9843248405890562e-17),
Double(0.8314696123025452, 1.407385698472803e-18),
Double(0.773010453362737, -3.256590703364977e-17),
Double(0.7071067811865476, -4.833646656726457e-17),
Double(0.6343932841636455, 1.0420901929280033e-17),
Double(0.5555702330196022, 4.709410940561676e-17),
Double(0.47139673682599764, 6.5166781360690214e-18),
Double(0.3826834323650898, -1.0050772696461586e-17),
Double(0.2902846772544624, -1.8927978707774255e-17),
Double(0.19509032201612828, -7.99107906846173e-18),
Double(0.0980171403295606, -1.634582362244275e-18),
Double(-1.4973849048591698e-33, 5.562271104316826e-50),
Double(-0.0980171403295606, 1.6345823622442537e-18),
Double(-0.19509032201612828, 7.991079068461728e-18),
Double(-0.2902846772544624, 1.892797870777425e-17),
Double(-0.3826834323650898, 1.0050772696461583e-17),
Double(-0.47139673682599764, -6.516678136069013e-18),
Double(-0.5555702330196022, -4.709410940561675e-17),
Double(-0.6343932841636455, -1.0420901929280036e-17),
Double(-0.7071067811865476, 4.833646656726457e-17),
Double(-0.773010453362737, 3.2565907033649766e-17),
Double(-0.8314696123025452, -1.407385698472808e-18),
Double(-0.881921264348355, 1.984324840589056e-17),
Double(-0.9238795325112867, -1.7645047084336677e-17),
Double(-0.9569403357322088, -4.05538698618757e-17),
Double(-0.9807852804032304, -1.8546939997825012e-17),
Double(-0.9951847266721969, 4.2486913678304403e-17),
Double(-1.0, 4.484323106596665e-66),
Double(-0.9951847266721969, 4.248691367830441e-17),
Double(-0.9807852804032304, -1.8546939997825003e-17),
Double(-0.9569403357322088, -4.0553869861875694e-17),
Double(-0.9238795325112867, -1.7645047084336674e-17),
Double(-0.881921264348355, 1.9843248405890562e-17),
Double(-0.8314696123025452, -1.4073856984728047e-18),
Double(-0.773010453362737, 3.2565907033649766e-17),
Double(-0.7071067811865476, 4.8336466567264573e-17),
Double(-0.6343932841636455, -1.042090192928005e-17),
Double(-0.5555702330196022, -4.709410940561677e-17),
Double(-0.47139673682599764, -6.51667813606904e-18),
Double(-0.3826834323650898, 1.0050772696461555e-17),
Double(-0.2902846772544624, 1.8927978707774258e-17),
Double(-0.19509032201612828, 7.991079068461733e-18),
Double(-0.0980171403295606, 1.6345823622442535e-18),
Double(-7.8337969295008e-33, 5.173596326540973e-49),
Double(0.0980171403295606, -1.63458236224422e-18),
Double(0.19509032201612828, -7.991079068461725e-18),
Double(0.2902846772544624, -1.8927978707774227e-17),
Double(0.3826834323650898, -1.0050772696461569e-17),
Double(0.47139673682599764, 6.516678136069015e-18),
Double(0.5555702330196022, 4.7094109405616774e-17),
Double(0.6343932841636455, 1.0420901929280038e-17),
Double(0.7071067811865476, -4.833646656726457e-17),
Double(0.773010453362737, -3.256590703364977e-17),
Double(0.8314696123025452, 1.4073856984728055e-18),
Double(0.881921264348355, -1.984324840589057e-17),
Double(0.9238795325112867, 1.7645047084336705e-17),
Double(0.9569403357322088, 4.05538698618757e-17),
Double(0.9807852804032304, 1.8546939997825018e-17),
Double(0.9951847266721969, -4.248691367830441e-17),
#Double(1.0, -1.7937292426403932e-65)
)

function index_npio32(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    result = 1
    for nx in npio32
        x < nx && break
        result += 1
    end
    return result
end

index_sin_npio32(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    sin_npio32[index_pio32(x)]

index_cos_npio32(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis} =
    cos_npio32[index_pio32(x)]

function index_sincos_pio32(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    idx = index_npio32(x)
    return sin_npio32[idx], cos_npio32[idx]
end

#=
   sin(a+b) = sin(a)*cos(b) + cos(a)*sin(b)
   cos(a+b) = cos(a)*cos(b) - sin(a)*sin(b)
=#


function sin_circle(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result1 = mul223(sin_part.hi, sin_part.lo, cos_rest.hi, cos_rest.lo)
    result2 = mul223(cos_part.hi, cos_part.lo, sin_rest.hi, sin_rest.lo)
    result  = add332(result1, result2)
    return Double(Accuracy, result)
end

function cos_circle(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result1 = mul223(cos_part.hi, cos_part.lo, cos_rest.hi, cos_rest.lo)
    result2 = mul223(sin_part.hi, sin_part.lo, sin_rest.hi, sin_rest.lo)
    result = sub332(result1, result2)
    return Double(Accuracy, result)
end

function sincos_circle(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    s = sin_part*cos_rest
    s += cos_part*sin_rest
    c = cos_part*cos_rest
    c -= sin_part*sin_rest
    return s, c
end


function sin_circle(x::Double{T,Performance}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result = sin_part*cos_rest
    result += cos_part*sin_rest
    return result
end

function cos_circle(x::Double{T,Performance}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    result = cos_part*cos_rest
    result = result - sin_part*sin_rest
    return result
end

function sincos_circle(x::Double{T,Performance}) where {T<:AbstractFloat}
    idx = index_npio32(x)
    pipart = npio32[idx]
    rest = x - pipart
    sin_part = sin_npio32[idx]
    cos_part = cos_npio32[idx]
    sin_rest, cos_rest = sincos_taylor(rest)
    s = sin_part*cos_rest
    s += cos_part*sin_rest
    c = cos_part*cos_rest
    c -= sin_part*sin_rest
    return s, c
end

function sin(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    iszero(x) && return zero(x)
    !isfinite(x) && return nan(typeof(x))
    y = abs(x)
    if y >= twopi_accuracy
       y = y / twopi_accuracy
       y = modf(y)[1]
    end
    z = sin_circle(y)
    z = copysign(z, x)
    return z
end

function cos(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    iszero(x) && return one(x)
    !isfinite(x) && return nan(typeof(x))
    y = abs(x)
    if y >= twopi_accuracy
       y = y / twopi_accuracy
       y = modf(y)[1]
    end
    z = cos_circle(y)
    return z
end


function sincos(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    iszero(x) && return (zero(typeof(x)), one(typeof(x)))
    !isfinite(x) && return (nan(typeof(x)), nan(typeof(x)))
    y = abs(x)
    if y >= twopi_accuracy
       y = y / twopi_accuracy
       y = modf(y)[1]
    end
    s = sin_circle(y)
    s = copysign(s, x)
    c = cos_circle(y)
    return s, c
end


function sin(x::Double{T,Performance}) where {T<:AbstractFloat}
    iszero(x) && return zero(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    y = abs(x)
    if y >= twopi_performance
       y = y / twopi_performance
       y = modf(y)[1]
    end
    z = sin_circle(y)
    z = copysign(z, x)
    return z
end

function cos(x::Double{T,Performance}) where {T<:AbstractFloat}
    iszero(x) && return one(typeof(x))
    !isfinite(x) && return nan(typeof(x))
    y = abs(x)
    if y >= twopi_performance
       y = y / twopi_performance
       y = modf(y)[1]
    end    
    z = cos_circle(y)
    return z
end

function sincos(x::Double{T,Performance}) where {T<:AbstractFloat}
    iszero(x) && return (zero(typeof(x)), one(typeof(x)))
    !isfinite(x) && return (nan(typeof(x)), nan(typeof(x)))
    y = abs(x)
    if y >= twopi_performance
       y = y / twopi_performance
       y = modf(y)[1]
    end   
    s = sin_circle(y)
    s = copysign(s, x)
    c = cos_circle(y)
    return s, c
end

function tan(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    s, c = sincos(x)
    return s/c
end

function csc(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    return inv(sin(x))
end

function sec(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    return inv(cos(x))
end

function cot(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    s, c = sin(x), cos(x)
    return c/s
end
