"""
    minmidmax(aᵢ, aₖ, aₘ)


sorts three values using minmax thrice   

>   Each line of source text in this
>       implementation is parallel-ready.
>   The three stages are independent.
"""
function minmidmax(a::T, b::T, c::T) where {T}

    b, c = minmax(b, c)
    a, c = minmax(a, c)
    a, b = minmax(a, b)

    return a, b, c
end
