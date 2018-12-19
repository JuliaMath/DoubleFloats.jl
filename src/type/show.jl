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
    compact = get(io, :compact, true)
    if compact
        str = string(x.re.hi, (signbit(x.im.hi) ? " - " : " + "), abs(x.im.hi), "im")
    else
        str = string(x.re, (signbit(x.im.hi) ? " - " : " + "), abs(x.im), "im")
    end
    print(io, str)
end


for (T,D) in ((:Float64, :"Double64"), (:Float32, :"Double32"), (:Float16, :"Double16")) 
  @eval begin
    function show(io::IO, ::MIME"text/plain", x::Vector{DoubleFloat{$T}})
        println(io, string(length(x),"-element ","Array{",$D,",1}:"))
        for a in x
            spc = signbit(a.hi) ? "" : " "
            println(io, string(spc,a))
        end
        return nothing
    end
    function show(io::IOContext, ::MIME"text/plain", x::Vector{DoubleFloat{$T}})
        iostream = io.io
        println(iostream, string(length(x),"-element ","Array{",$D,",1}:"))
        for a in x
            spc = signbit(a.hi) ? "" : " "
            println(io, spc, a)
        end
        return nothing
    end
  end
endte

#show(x::DoubleFloat{T}) where {T<:IEEEFloat} = show(Base.stdout, x)
    
show(io::IO, x::DoubleFloat{T}) where {T<:IEEEFloat} = show(io, ::MIME"text/plain", x)

show(io::IO, x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = show(io, ::MIME"text/plain", x)

show(x::DoubleFloat{T}) where {T<:IEEEFloat} = show(Base.stdout, x)

show(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = show(Base.stdout, x)


function showtyped(io::IO, x::DoubleFloat{T}) where {T<:IEEEFloat}
    str = stringtyped(x)
    print(io, str)
end

showtyped(io::IO, ::MIME"text/plain", x::DoubleFloat{T}) where {T<:IEEEFloat} = showtyped(io, x)

showtyped(io::IO, ::MIME"text/plain", x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = showtyped(io, x)

showtyped(x::DoubleFloat{T}) where {T<:IEEEFloat} = showtyped(Base.stdout, x)

showtyped(x::Complex{DoubleFloat{T}}) where {T<:IEEEFloat} = showtyped(Base.stdout, x)
