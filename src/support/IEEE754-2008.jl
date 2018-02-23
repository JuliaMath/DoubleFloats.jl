function raw_exponent(x::Float64)
    u = reinterpret(UInt64, x)
    reinterpret(Int64, ((u >> 52) & 0x7ff))
end
 
function ready_exponent(x::Float64)
    u = reinterpret(UInt64, x)
    reinterpret(Int64, (((u >> 52) & 0x7ff) - 0x3ff))
end

function signed_significand(a::Float64)
    fr, ex = frexp(a)
    ldexp(a, (-ex))
end

function sigexp(signif::Float64, exponent::Int)
    u = reinterpret(UInt64, signif)
    e = reinterpret(UInt64, exponent) << 52
    reinterpret(Float64, e+u)
end


function restore_biased_exponent(ex)
   (reinterpret(UInt64, ex) + 0x3ff) << 52
end
