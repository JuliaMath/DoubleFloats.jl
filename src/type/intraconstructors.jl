DoubleF64(x::DoubleF32) = DoubleF64(FastTwoSum(Float64(HI(x)), Flost64(LO(x)))...,)
DoubleF64(x::DoubleF16) = DoubleF64(FastTwoSum(Float64(HI(x)), Flost64(LO(x)))...,)
DoubleF32(x::DoubleF16) = DoubleF32(FastTwoSum(Float32(HI(x)), Flost32(LO(x)))...,)

function DoubleF32(x::DoubleF64)
    hi64, lo64 = HILO(x)
    hi32 = Float32(HI(x))
    lo32 = Float32(hi64 - hi32 + lo32)
    hilo32 = FastTwoSum(hi32, lo32)
    return hilo32
end

function DoubleF16(x::DoubleF64)
    hi64, lo64 = HILO(x)
    hi16 = Float16(HI(x))
    lo16 = Float16(hi64 - hi16 + lo16)
    hilo16 = FastTwoSum(hi16, lo16)
    return hilo16
end
