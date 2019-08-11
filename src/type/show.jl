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


Base.Printf.fix_dec(x::Double64, n::Int, digits) =
    Base.Printf.fix_dec(Float64(x),n,digits)

Base.Printf.fix_dec(x::Double32, n::Int, digits) =
    Base.Printf.fix_dec(Float64(x),n,digits)

Base.Printf.fix_dec(x::Double16, n::Int, digits) =
    Base.Printf.fix_dec(Float32(x),n,digits)

Base.Printf.ini_dec(x::Double64, n::Int, digits) =
    Base.Printf.ini_dec(Float64(x),n,digits)

Base.Printf.ini_dec(x::Double32, n::Int, digits) =
    Base.Printf.ini_dec(Float64(x),n,digits)

Base.Printf.ini_dec(x::Double16, n::Int, digits) =
    Base.Printf.ini_dec(Float32(x),n,digits)
