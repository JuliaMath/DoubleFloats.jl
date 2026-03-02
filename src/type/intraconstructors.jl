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
