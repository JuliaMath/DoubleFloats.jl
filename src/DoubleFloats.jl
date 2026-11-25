"""
    DoubleFloats

A package for extended precision floating point math.

exported types: `Double64`, `Double32`, `Double16`
                `ComplexDF64`, `ComplexDF32`, `ComplexDF16`
"""
module DoubleFloats

abstract type MultipartFloat <: AbstractFloat end

export DoubleFloat,
    Double64,
    Double32,
    Double16,
    ComplexDF64,
    ComplexDF32,
    ComplexDF16,
    @df64_str,
    @df32_str,
    @df16_str,
    @via_df64,
    @via_df32,
    MultipartFloat,
    HI,
    LO,
    HILO,
    stringtyped,
    showtyped,
    showall,
    isnonzero,
    ispositive,
    isnegative,
    isnonpositive,
    isnonnegative,
    isposinf,
    isneginf,
    isfractional,
    isnormal,
    issquare,
    nan,
    inf,
    posinf,
    neginf,
    ulp,
    intpart,
    fracpart,
    fmod,
    square,
    cube,
    add2,
    sub2,
    mul2,
    div2,
    ⊕,
    ⊖,
    ⊗,
    ⊘,
    spread,
    sld,
    tld,
    signs,
    randpm,
    agm,
    agm1,
    ellipk,
    besselj0,
    besselj1,
    besselj,
    bessely0,
    bessely1,
    bessely,
    gamma,
    loggamma,
    lgamma,
    erf,
    erfc,
    matrixfunction

using Base.MathConstants: pi, golden, ℯ, eulergamma, catalan

using Printf
using Random
import Random: rand, randn

using LinearAlgebra
import LinearAlgebra: norm, mul!, AdjointQ

using GenericLinearAlgebra
using GenericSchur

import Quadmath

import Base:
    hash,
    promote_type,
    promote_rule,
    convert,
    string,
    show,
    parse,
    tryparse,
    eltype,
    signbit,
    sign,
    abs,
    abs2,
    hypot,
    significand,
    exponent,
    precision,
    widen,
    (+),
    (-),
    (*),
    (/),
    (\),
    (^),
    inv,
    sqrt,
    cbrt,
    (==),
    (!=),
    (<),
    (<=),
    (>=),
    (>),
    isequal,
    isless,
    IEEEFloat,
    iszero,
    isone,
    isinf,
    isnan,
    isinf,
    isfinite,
    issubnormal,
    isinteger,
    isodd,
    iseven,
    zero,
    one,
    typemax,
    typemin,
    floatmax,
    floatmin,
    maxintfloat,
    min,
    max,
    minmax,
    minimum,
    maximum,
    floor,
    ceil,
    trunc,
    round,
    div,
    fld,
    cld,
    rem,
    mod,
    rem2pi,
    mod2pi,
    divrem,
    fldmod,
    sqrt,
    cbrt,
    BigFloat,
    BigInt,
    Int8,
    Int16,
    Int32,
    Int64,
    Int128,
    Float64,
    Float32,
    Float16

@static if isdefined(Base, :ispositive)
    import Base: ispositive
end

@static if isdefined(Base, :isnegative)
    import Base: isnegative
end

import Base:
    modf,
    fma,
    muladd,
    log,
    log1p,
    log2,
    log10,
    exp,
    expm1,
    exp2,
    exp10,
    sin,
    cos,
    tan,
    cot,
    asin,
    acos,
    atan,
    acsc,
    asec,
    acot,
    sinh,
    cosh,
    tanh,
    csch,
    sech,
    coth,
    asinh,
    acosh,
    atanh,
    acsch,
    asech,
    acoth,
    sinpi,
    cospi,
    tanpi,
    sincos,
    sincospi,
    cis,
    cispi

import Quadmath: Float128

# Layers, in dependency order. A file may use only what is loaded above it.
# test/layering.jl checks the functions; Julia checks the rest.

# 1. Error-free transformations on machine floats
include("eft/errorfree.jl")
include("eft/quotients.jl")

# 2. The value
include("core/type.jl")
include("core/constructors.jl")
include("core/predicates.jl")
include("core/specialvalues.jl")
include("core/reflection.jl")

# 3. Routes: the records that describe a kernel
include("routes/batchrecords.jl")

# 4. Arithmetic
include("arith/nonfinite.jl")
include("arith/kernels.jl")
include("arith/batchops.jl")
include("arith/operators.jl")
include("arith/mixed.jl")
include("arith/fma.jl")
include("arith/rounding.jl")
include("arith/divrem.jl")
include("arith/hypot.jl")

# 5. The Base contract
include("contract/promote.jl")
include("contract/convert.jl")
include("contract/compare.jl")
include("contract/approx.jl")
include("contract/quadmath.jl")

# 6. Constants and coefficient tables
include("constants/double.jl")
include("constants/triple.jl")
include("constants/triple_consts.jl")
include("constants/triple_pi.jl")
include("constants/tables.jl")

# 7. Elementary functions
include("elementary/reduce.jl")
include("elementary/explog.jl")
include("elementary/trig.jl")
include("elementary/arctrig.jl")
include("elementary/hyperbolic.jl")
include("elementary/archyperbolic.jl")
include("elementary/widened.jl")
include("elementary/double32.jl")
include("elementary/complexpow.jl")
include("elementary/complex.jl")

# 8. Batch evaluation
include("batch/simdmap.jl")
include("batch/double32.jl")

# 9. Text
include("io/string.jl")
include("io/show.jl")
include("io/parse.jl")

# 10. Random numbers
include("random/rand.jl")

# 11. Matrices
include("linalg/support.jl")
include("linalg/matrixfunction.jl")

include("macros.jl")

# Special functions, to become an extension
import SpecialFunctions: erf, erfc, gamma, logabsgamma, besselj0, besselj1, besselj, bessely0, bessely1, bessely, ellipk
include("special/specialfunctions.jl")

end # module DoubleFloats
