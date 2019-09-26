import Printf: ini_dec, fix_dec, ini_hex, ini_HEX

function show(io::IO, x::DoubleFloat{T}) where {T<:IEEEFloat}
    compact = get(io, :compact, true)
    if compact
        str = string(x.hi)
    else
        str = string(x)
    end
    print(io, str)
end

function show(io::IO, x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    re, im = reim(x)
    imstr = isfinite(im) ? "im" : "*im"
    compact = get(io, :compact, true)
    if compact
        str = string(HI(re), (signbit(x.im.hi) ? " - " : " + "), abs(HI(im)), imstr)
    else
        str = string(re, (signbit(HI(im)) ? " - " : " + "), abs(im), imstr)
    end
    print(io, str)
end


show(x::DoubleFloat{T}) where {T<:IEEEFloat} = show(Base.stdout, x)

show(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = show(Base.stdout, x)


function showtyped(io::IO, x::DoubleFloat{T}) where {T<:IEEEFloat}
    str = stringtyped(x)
    print(io, str)
end

function showtyped(io::IO, x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    str = stringtyped(x)
    print(io, str)
end

showtyped(x::DoubleFloat{T}) where {T<:IEEEFloat} = showtyped(Base.stdout, x)

showtyped(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = showtyped(Base.stdout, x)

showall(x::DoubleFloat{T}) where {T<:IEEEFloat} = print(Base.stdout, string(x))

showall(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = print(Base.stdout, string(x))


if VERSION < v"1.1"
using Base.Grisu: DIGITSs
    fix_dec(out, d::Double64, flags::String, width::Int, precision::Int, c::Char) = 
        fix_dec(out, Float64(d), flags, width, precision, c, DIGITSs[Threads.threadid()])
    fix_dec(out, d::Double32, flags::String, width::Int, precision::Int, c::Char) = 
        fix_dec(out, Float32(d), flags, width, precision, c, DIGITSs[Threads.threadid()])
    fix_dec(out, d::Double16, flags::String, width::Int, precision::Int, c::Char) = 
        fix_dec(out, Float16(d), flags, width, precision, c, DIGITSs[Threads.threadid()])
    ini_dec(out, d::Double64, flags::String, width::Int, precision::Int, c::Char) = 
        ini_dec(out, Float64(d), flags, width, precision, c, DIGITSs[Threads.threadid()])
    ini_dec(out, d::Double32, flags::String, width::Int, precision::Int, c::Char) = 
        ini_dec(out, Float32(d), flags, width, precision, c, DIGITSs[Threads.threadid()])
    ini_dec(out, d::Double16, flags::String, width::Int, precision::Int, c::Char) = 
        ini_dec(out, Float16(d), flags, width, precision, c, DIGITSs[Threads.threadid()])
        
    fix_dec(x::Double64, n::Int) = fix_dec(Float64(x), n)
    fix_dec(x::Double32, n::Int) = fix_dec(Float64(x), n)
    fix_dec(x::Double16, n::Int) = fix_dec(Float32(x), n)
    ini_dec(x::Double64, n::Int) = ini_dec(Float64(x), n)
    ini_dec(x::Double32, n::Int) = ini_dec(Float64(x), n)
    ini_dec(x::Double16, n::Int) = ini_dec(Float32(x), n)
else   
    fix_dec(out, d::Double64, flags::String, width::Int, precision::Int, c::Char, digits) = 
        fix_dec(out, Float64(d), flags, width, precision, c, digits)
    fix_dec(out, d::Double32, flags::String, width::Int, precision::Int, c::Char, digits) = 
        fix_dec(out, Float32(d), flags, width, precision, c, digits)
    fix_dec(out, d::Double16, flags::String, width::Int, precision::Int, c::Char, digits) = 
        fix_dec(out, Float16(d), flags, width, precision, c, digits)
    ini_dec(out, d::Double64, flags::String, width::Int, precision::Int, c::Char, digits) = 
        ini_dec(out, Float64(d), flags, width, precision, c, digits)
    ini_dec(out, d::Double32, flags::String, width::Int, precision::Int, c::Char, digits) = 
        ini_dec(out, Float32(d), flags, width, precision, c, digits)
    ini_dec(out, d::Double16, flags::String, width::Int, precision::Int, c::Char, digits) = 
        ini_dec(out, Float16(d), flags, width, precision, c, digits)

    fix_dec(x::Double64, n::Int, digits) = fix_dec(Float64(x), n, digits)
    fix_dec(x::Double32, n::Int, digits) = fix_dec(Float64(x), n, digits)
    fix_dec(x::Double16, n::Int, digits) = fix_dec(Float32(x), n, digits)
    ini_dec(x::Double64, n::Int, digits) = ini_dec(Float64(x), n, digits)
    ini_dec(x::Double32, n::Int, digits) = ini_dec(Float64(x), n, digits)
    ini_dec(x::Double16, n::Int, digits) = ini_dec(Float32(x), n, digits)
end
