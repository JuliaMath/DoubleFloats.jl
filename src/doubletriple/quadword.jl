function vec_sum(x0::T, x1::T, x2::T, x3::T) where {T}
    s3 = x3
    s2, e3 = two_sum(x2, s3)
    s1, e2 = two_sum(x1, s2)
    s0, e1 = two_sum(x0, s1)
    return s0,e1,e2,e3
end

function vsum_errbranch(x::NTuple{4,T}) where {T}
    y = zeros(T, 4)
    r = zeros(T, 4)
    e = zeros(T, 4)
    j = 1
    e[1] = x[1]
    for i = 1:2
        r[i], t = two_sum(e[i], x[i+1])
        if t !== zero(T)
            y[j] = r[i]
            e[i+1] = t
            j += 1
        else    
            e[i+1] = r[i]
        end    
    end
    y[j], y[j+1] = two_sum(e[3], x[4])
    return y
end

function quadword(x1::T, x2::T, x3::T, x4::T) where {T}
    a1, a2 = two_sum(x1, x2)
    b1, b2 = two_sum(x3, x4)
    c1, c2 = two_sum(a1, b1)
    d1, d2 = two_sum(a2, b2)
    e1to4 = vec_sum(c1,c2,d1,d2)
    y = vsum_errbranch(e1to4)
    return (y...,)
end

#=
function vec_sum_errbranch(x0::T, x1::T, x2::T, x3::T) where {T}
    # n = 4
    j = zero(T)
    e0 = x0
    r0, et1 = two_sum(e0, x1)
    if !iszero(e1)
        y0 = r0
        e1 = et1
        j += 1
    else
        e1 = r0
    end
    r1, et2 = two_sum(e1, x2)
    if !iszero(e2)
        if iszero(j)
            y0 = r1
            y1 = zero(T)
         else
            y1 = r1
         end   
         e2 = et2
         j += 1
    else
         e2 = r1
    end
    yj, yj+1 = two_sum(e2, e3)
    yj+2,..y3 = zero(T)
    return y0,y1,y2,y3
end
=#
