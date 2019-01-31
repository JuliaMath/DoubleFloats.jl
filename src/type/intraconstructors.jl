Double64(x::Double32) = Double64(FastTwoSum(Float64(HI(x)), Float64(LO(x)))...,)
Double64(x::Double16) = Double64(FastTwoSum(Float64(HI(x)), Float64(LO(x)))...,)
Double32(x::Double16) = Double32(FastTwoSum(Float32(HI(x)), Float32(LO(x)))...,)

function Double16(x::Float64)
    hi = Float16(x)
    lo = Float16(x - Float64(hi))
    return DoubleFloat{Float16}(hi,lo)
end

function Double16(x::Float32)
    hi = Float16(x)
    lo = Float16(x - Float32(hi))
    return DoubleFloat{Float16}(hi,lo)
end

function Double32(x::Float64)
    hi = Float32(x)
    lo = Float32(x - Float64(hi))
    return DoubleFloat{Float16}(hi,lo)
end

function Double16(x::T) where {T<:Signed}
    if x <= maxintfloat(Double16)
        Double16(Float64(x))
    else
        throw(DomainError("$x"))
    end
end

function Double32(x::T) where {T<:Signed}
    if x <= maxintfloat(Double32)
        Double32(Float64(x))
    else
        throw(DomainError("$x"))
    end
end

function Double64(x::T) where {T<:Signed}
    if x <= maxintfloat(Double64)
        if x <= maxintfloat(Float64)
             Double64(Float64(x))
        else
             Double64(BigFloat(BigInt(x)))
        end            
    else
        throw(DomainError("$x"))
    end
end



#=

e.g. DoubleFloat{Float16}(65519.0) does not work properly in these

function Double32(x::Double64)
    hi64, lo64 = HILO(x)
    hi64a = reinterpret(Float64, (reinterpret(UInt64, hi64) & 0xFFFFFFFF00000000))
    hi64b = hi64 - hi64a
    lo64a = reinterpret(Float64, (reinterpret(UInt64, lo64) & 0xFFFFFFFF00000000))
    lo64b = lo64 - lo64b
    hi32a, hi32b = Float32(hi64a), Float32(hi64b)
    lo32a, lo32b = Float32(lo64a), Float32(lo64b)
    hi32, lo32 = two_hilo_sum(hi32a, hi32b, lo32a, lo32b)
    return Double32(hi32, lo32)
end

function Double16(x::Double64)
    hi64, lo64 = HILO(x)
    hi64a = reinterpret(Float64, (reinterpret(UInt64, hi64) & 0xFFFFFFFF00000000))
    hi64b = hi64 - hi64a
    lo64a = reinterpret(Float64, (reinterpret(UInt64, lo64) & 0xFFFFFFFF00000000))
    lo64b = lo64 - lo64b
    hi16a, hi16b = Float16(hi64a), Float16(hi64b)
    lo16a, lo16b = Float16(lo64a), Float16(lo64b)
    hi16, lo16 = two_hilo_sum(hi16a, hi16b, lo16a, lo16b)
    return Double16(hi16, lo16)
end

function Double16(x::Double32)
    hi32, lo32 = HILO(x)
    hi32a = reinterpret(Float32, (reinterpret(UInt32, hi32) & 0xFFFF0000))
    hi32b = hi32 - hi32a
    lo32a = reinterpret(Float32, (reinterpret(UInt32, lo32) & 0xFFFF0000))
    lo32b = lo32 - lo32b
    hi16a, hi16b = Float16(hi64a), Float16(hi64b)
    lo16a, lo16b = Float16(lo64a), Float16(lo64b)
    hi16, lo16 = two_hilo_sum(hi16a, hi16b, lo16a, lo16b)
    return Double16(hi16, lo16)
end

=#
