# use convert(String, x) to obtain a reparsable string (also show(io, x))
# use String(x) to obtain a string of a 2-value tuple  (also show(x))

function Base.convert(::Type{String}, x::Double{T,EMPHASIS}) where {T}
    return string(EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
function Base.convert(::Type{String}, x::Double{T,ALT_EMPHASIS}) where {T}
    return string(ALT_EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end

function Base.string(x::Double{T,EMPHASIS}) where {T}
    return string("(",x.hi,", ",x.lo,")")
end
function Base.string(x::Double{T,ALT_EMPHASIS}) where {T}
    return string("(",x.hi,", ",x.lo,")")
end

function Base.show(io::IO, x::Double{T,E}) where  {T, E<:Emphasis}
    print(io, convert(String, x))
end

function Base.show(x::Double{T,E}) where  {T, E<:Emphasis}
    print(Base.STDOUT, string(x))
end

