function show(io::IOContext, x::DoubleFloat{T}) where {T<:IEEEFloat}
    compact = get(io, :compact, true)
    if compact
        str = string(x.hi)
    else
        str = string(x)
    end
    print(io.io, str)
end

function show(io::IO, x::DoubleFloat{T}) where {T<:IEEEFloat}
    compact = get(io, :compact, true)
    if compact
        str = string(x.hi)
    else
        str = string(x)
    end
    print(io, str)
end

#show(x::DoubleFloat{T}) where {T<:IEEEFloat} = show(Base.stdout, x)
    
show(io::IO, ::MIME"text/plain", x::DoubleFloat{T}) where {T<:IEEEFloat} = show(io, x)


function showtyped(io::IO, x::DoubleFloat{T}) where {T<:IEEEFloat}
    str = stringtyped(x)
    print(io, str)
end

showtyped(io::IO, ::MIME"text/plain", x::DoubleFloat{T}) where {T<:IEEEFloat} = showtyped(io, x)

showtyped(x::DoubleFloat{T}) where {T<:IEEEFloat} = showtyped(Base.stdout, x)
