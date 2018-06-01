DoubleF64(x::DoubleF32) = DoubleF64(FastTwoSum(Float64(HI(x)), Flost64(LO(x)))...,)
DoubleF64(x::DoubleF16) = DoubleF64(FastTwoSum(Float64(HI(x)), Flost64(LO(x)))...,)
DoubleF32(x::DoubleF16) = DoubleF32(FastTwoSum(Float32(HI(x)), Flost32(LO(x)))...,)

function DoubleF32(x::DoubleF64)
    hi64, lo64 = HILO(x)
    hi64a = reinterpret(Float64, (reinterpret(UInt64, hi64) & 0xFFFFFFFF00000000))
    hi64b = hi64 - hi64a
    lo64a = reinterpret(Float64, (reinterpret(UInt64, lo64) & 0xFFFFFFFF00000000))
    lo64b = lo64 - lo64b
    hi32a, hi32b = Float32(hi64a), Float32(hi64b)
    lo32a, lo32b = Float32(lo64a), Float32(lo64b)
    hi32, lo32 = add_hilo_2(hi32a, hi32b, lo32a, lo32b)
    return DoubleF32(hi32, lo32)
end

function DoubleF16(x::DoubleF64)
    hi64, lo64 = HILO(x)
    hi64a = reinterpret(Float64, (reinterpret(UInt64, hi64) & 0xFFFFFFFF00000000))
    hi64b = hi64 - hi64a
    lo64a = reinterpret(Float64, (reinterpret(UInt64, lo64) & 0xFFFFFFFF00000000))
    lo64b = lo64 - lo64b
    hi16a, hi16b = Float16(hi64a), Float16(hi64b)
    lo16a, lo16b = Float16(lo64a), Float16(lo64b)
    hi16, lo16 = add_hilo_2(hi16a, hi16b, lo16a, lo16b)
    return DoubleF16(hi16, lo16)
end

function DoubleF16(x::DoubleF32)
    hi32, lo32 = HILO(x)
    hi32a = reinterpret(Float32, (reinterpret(UInt32, hi32) & 0xFFFF0000))
    hi32b = hi32 - hi32a
    lo32a = reinterpret(Float32, (reinterpret(UInt32, lo32) & 0xFFFF0000))
    lo32b = lo32 - lo32b
    hi16a, hi16b = Float16(hi64a), Float16(hi64b)
    lo16a, lo16b = Float16(lo64a), Float16(lo64b)
    hi16, lo16 = add_hilo_2(hi16a, hi16b, lo16a, lo16b)
    return DoubleF16(hi16, lo16)
end

