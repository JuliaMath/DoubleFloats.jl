function Base.string(x::Double{T,EMPHASIS}) where {T}
    return string(EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
function Base.string(x::Double{T,ALT_EMPHASIS}) where {T}
    return string(ALT_EMPHASIS_STR,"Double(",x.hi,", ",x.lo,")")
end
function Base.show(io::IO, x::Double{T,E}) where  {T, E<:Emphasis}
    print(io, string(x))
end

