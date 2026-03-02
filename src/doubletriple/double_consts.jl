const pi_4o1_d64   = (12.56637061435917200,  4.8985871965894130e-16)
const pi_2o1_d64   = ( 6.28318530717958600,  2.4492935982947064e-16)
const pi_1o1_d64   = ( 3.14159265358979300,  1.2246467991473532e-16)
const pi_1o2_d64   = ( 1.57079632679489660,  6.1232339957367660e-17)
const pi_1o4_d64   = ( 0.78539816339744830,  3.0616169978683830e-17)

const pi_4o1_d32 = (12.566371f0, -3.496911f-7)
const pi_4o1_d16 = (Float16(12.56), Float16(0.00387))

const pi_2o1_d32 = (6.2831855f0, -1.7484555f-7)
const pi_2o1_d16 = (Float16(6.28), Float16(0.001935))

const pi_1o1_d32 = (3.1415927f0, -8.742278f-8)
const pi_1o1_d16 = (Float16(3.14), Float16(0.0009675))

const pi_1o2_d32 = (Float32(1.5707964), Float32(-4.371139e-8))
const pi_1o2_d16 = (Float16(1.57), Float16(0.0004838))

const pi_1o4_d32 = (0.7853982f0, -2.1855694f-8)
const pi_1o4_d16 = (Float16(0.785), Float16(0.0002419))

pi4o1(::Type{Double64}) = Double64(pi_4o1_d64)
pi4o1(::Type{Double32}) = Double32(pi_4o1_d32)
pi4o1(::Type{Double16}) = Double16(pi_4o1_d16)

pi2o1(::Type{Double64}) = Double64(pi_2o1_d64)
pi2o1(::Type{Double32}) = Double32(pi_2o1_d32)
pi2o1(::Type{Double16}) = Double16(pi_2o1_d16)

pi1o1(::Type{Double64}) = Double64(pi_1o1_d64)
pi1o1(::Type{Double32}) = Double32(pi_1o1_d32)
pi1o1(::Type{Double16}) = Double16(pi_1o1_d16)

pi1o2(::Type{Double64}) = Double64(pi_1o2_d64)
pi1o2(::Type{Double32}) = Double32(pi_1o2_d32)
pi1o2(::Type{Double16}) = Double16(pi_1o2_d16)

pi1o4(::Type{Double64}) = Double64(pi_1o4_d64)
pi1o4(::Type{Double32}) = Double32(pi_1o4_d32)
pi1o4(::Type{Double16}) = Double16(pi_1o4_d16)
