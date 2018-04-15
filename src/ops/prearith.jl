function zero(::Type{Mag})
    z = init(Mag)
    return z
end

function one(::Type{Mag})
    z = init(Mag)
    x = one(UInt)
    ccall(@libarb(mag_set_ui), Cvoid, (Ref{Mag}, Culong), z, x)
    return z
end

function two(::Type{Mag})
    z = init(Mag)
    x = one(UInt) + one(UInt)
    ccall(@libarb(mag_set_ui), Cvoid, (Ref{Mag}, Culong), z, x)
    return z
end

function onehalf(::Type{Mag})
    z = init(Mag)
    x = 0.5
    ccall(@libarb(mag_set_d), Cvoid, (Ref{Mag}, Cdouble), z, x)
    return z
end
