function show(io::IO, x::DoubleFloat{T}) where {T<:IEEEFloat}
    str = string(x)
    print(io, str)
end

function show(io::IO, x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat}
    str = string(x)
    print(io, str)
end

function showtyped(io::IO, x::DoubleFloat{T}) where {T<:IEEEFloat}
    str = typedstring(x)
    print(io, str)
end

function showtyped(io::IO, x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat}
    str = typedstring(x)
    print(io, str)
end

function showtyped(x::DoubleFloat{T}) where {T<:IEEEFloat}
    str = typedstring(x)
    print(str)
end

function showtyped(x::DoubleFloat{DoubleFloat{T}}) where {T<:IEEEFloat}
    str = typedstring(x)
    print(str)
end
