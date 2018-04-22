#=
    minmax()s functions from SortingNetworks.jl
    maxmin()s are order predicate duals of minmax()s
=#


# from Base
# maxmin(x::T, y::T) where {T<:AbstractFloat} = x < y ? (y, x) : (x, y)
maxmin(x::T, y::T) where {T<:AbstractFloat} =
    ifelse(isnan(x) | isnan(y), ifelse(isnan(x), (y,y), (x,x)),
           ifelse((y > x) | (signbit(x) > signbit(y)), (y,x), (x,y)))


"""
    maxmin(x𝘪, x𝘫, x𝘬)


sorts three values using minmax thrice

>   Each line of source text in this
>       implementation is parallel-ready.
>   The three stages are independent.
"""
@inline function maxmin(a::T, b::T, c::T) where {T}
                        #          parallel A, B, C
    b, c = maxmin(b, c) # stage A

    a, c = maxmin(a, c) # stage B

    a, b = maxmin(a, b) # stage C

    return a, b, c
end

"""
    maxmin(x𝘩, x𝘪, x𝘫, x𝘬)


sorts four values using maxmin five times

>   This implementation is parallel-ready.
>   The three stages are independent.
"""
@inline function maxmin(a::T, b::T, c::T, d::T) where {T}
                            #          parallel A, B, C
    a, b = maxmin(a, b)     # stage A
    c, d = maxmin(c, d)     #   sequential: two maxmin

    a, c = maxmin(a, c)     # stage B
    b, d = maxmin(b, d)     #   sequential: two maxmin

    b, c = maxmin(b, c)     # stage C

    return a, b, c, d
end



"""
    minmax(x𝘪, x𝘫, x𝘬)


sorts three values using minmax thrice

>   Each line of source text in this
>       implementation is parallel-ready.
>   The three stages are independent.
"""
@inline function minmax(a::T, b::T, c::T) where {T}
                        #          parallel A, B, C
    b, c = minmax(b, c) # stage A

    a, c = minmax(a, c) # stage B

    a, b = minmax(a, b) # stage C

    return a, b, c
end

"""
    minmax(x𝘩, x𝘪, x𝘫, x𝘬)


sorts four values using minmax five times

>   This implementation is parallel-ready.
>   The three stages are independent.
"""
@inline function minmax(a::T, b::T, c::T, d::T) where {T}
                            #          parallel A, B, C
    a, b = minmax(a, b)     # stage A
    c, d = minmax(c, d)     #   sequential: two minmax

    a, c = minmax(a, c)     # stage B
    b, d = minmax(b, d)     #   sequential: two minmax

    b, c = minmax(b, c)     # stage C

    return a, b, c, d
end
