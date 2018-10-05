function show(io::IO, x::DoubleFloat{T}) where {T<:IEEEFloat}
    str = string(x)
    print(io, str)
end

show(io::IO, ::MIME"text/plain", x::DoubleFloat{T}) where {T<:IEEEFloat} = show(io, x)

function show(io::IO, x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat}
    str = string(x)
    print(io, str)
end

function showtyped(io::IO, x::DoubleFloat{T}) where {T<:IEEEFloat}
    str = stringtyped(x)
    print(io, str)
end

showtyped(io::IO, ::MIME"text/plain", x::DoubleFloat{T}) where {T<:IEEEFloat} = showtyped(io, x)

function showtyped(io::IO, x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat}
    str = stringtyped(x)
    print(io, str)
end

function showtyped(x::DoubleFloat{T}) where {T<:IEEEFloat}
    str = stringtyped(x)
    print(str)
end

function showtyped(x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat}
    str = stringtyped(x)
    print(str)
end
