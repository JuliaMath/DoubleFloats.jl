# Constants and helpers shared by the unit tests.

const phi = Base.MathConstants.golden
const eulergamma = Base.MathConstants.eulergamma

const phi_df64 = Double64(phi)
const phi_df32 = Double32(phi)
const gamma_df64 = Double64(eulergamma)
const gamma_df32 = Double32(eulergamma)

const phi_df64hi = HI(phi_df64);
const phi_df64lo = LO(phi_df64)
const phi_df32hi = HI(phi_df32);
const phi_df32lo = LO(phi_df32)
const gamma_df64hi = HI(gamma_df64);
const gamma_df64lo = LO(gamma_df64)
const gamma_df32hi = HI(gamma_df32);
const gamma_df32lo = LO(gamma_df32)

# Reach names the package does not export.
macro df(func)
    :(DoubleFloats.$func)
end
macro df(func, arg)
    :(DoubleFloats.$func($arg))
end
macro df(func, arg1, arg2)
    :(DoubleFloats.$func($arg1, $arg2))
end
macro df(func, arg1, arg2, arg3)
    :(DoubleFloats.$func($arg1, $arg2, $arg3))
end
macro df(func, arg1, arg2, arg3, arg4)
    :(DoubleFloats.$func($arg1, $arg2, $arg3, $arg4))
end
