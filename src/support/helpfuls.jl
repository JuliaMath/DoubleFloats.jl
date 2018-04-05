"""
    minmedmax(aᵢ, aₖ, aₘ)


sorts three values using minmax thrice   

>   Each line of source text in this
>       implementation is parallel-ready.
>   The three stages are independent.
"""
function min_to_max(a::T, b::T, c::T) where {T}

    b, c = minmax(b, c)
    a, c = minmax(a, c)
    a, b = minmax(a, b)

    return a, b, c
end

"""
    min_to_max(x𝘩, x𝘪, x𝘫, x𝘬)


sorts four values using minmax five times

>   This implementation is parallel-ready.
>   The three stages are independent.
"""
function min_to_max(a::T, b::T, c::T, d::T) where {T}
                            #          parallel A, B, C
    a, b = minmax(a, b)     # stage A
    c, d = minmax(c, d)     #   sequential: two minmax

    a, c = minmax(a, c)     # stage B
    b, d = minmax(b, d)     #   sequential: two minmax

    b, c = minmax(b, c)     # stage C

    return a, b, c, d
end
