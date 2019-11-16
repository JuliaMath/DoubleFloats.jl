import .SpecialFunctions
import .SpecialFunctions: erf, erfc, besselj0, besselj1, bessely0, bessely1,
    besselj, bessely, gamma, lgamma
using Quadmath
import Quadmath: Float128, Cfloat128
#=
erf(x::Float128) =
    Float128(@ccall(libquadmath.erfq(x::Cfloat128)::Cfloat128))
erfc(x::Float128) =
    Float128(@ccall(libquadmath.erfcq(x::Cfloat128)::Cfloat128))

besselj0(x::Float128) =
    Float128(@ccall(libquadmath.j0q(x::Cfloat128)::Cfloat128))
besselj1(x::Float128) =
    Float128(@ccall(libquadmath.j1q(x::Cfloat128)::Cfloat128))

bessely0(x::Float128) =
    Float128(@ccall(libquadmath.y0q(x::Cfloat128)::Cfloat128))
bessely1(x::Float128) =
    Float128(@ccall(libquadmath.y1q(x::Cfloat128)::Cfloat128))

besselj(n::Integer, x::Float128) =
    Float128(@ccall(libquadmath.jnq(n::Cint, x::Cfloat128)::Cfloat128))
bessely(n::Integer, x::Float128) =
    Float128(@ccall(libquadmath.ynq(n::Cint, x::Cfloat128)::Cfloat128))

gamma(x::Float128) =
    Float128(@ccall(libquadmath.tgammaq(x::Cfloat128)::Cfloat128))
lgamma(x::Float128) =
    Float128(@ccall(libquadmath.lgammaq(x::Cfloat128)::Cfloat128))
=#
