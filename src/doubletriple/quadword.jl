@inline max_min(x,y) = ifelse(abs(y) < abs(x), (x,y) , (y,x))

function maxtomin(a::T, b::T, c::T, d::T) where {T}
    a, b = max_min(a, b)
    c, d = max_min(c, d)

    a, c = max_min(a, c)
    b, d = max_min(b, d)

    b, c = max_min(b, c)

    return a, b, c, d
end

function maxtomin(a::T, b::T, c::T, d::T) where {T}
    a, b = max_min(a, b)
    c, d = max_min(c, d)
    a, c = max_min(a, c)
    b, d = max_min(b, d)
    b, c = max_min(b, c)
    return a, b, c, d
end

function vec_sum(x0::T, x1::T, x2::T, x3::T) where {T}
    s3 = x3
    s2, e3 = two_sum(x2, s3)
    s1, e2 = two_sum(x1, s2)
    s0, e1 = two_sum(x0, s1)
    return s0,e1,e2,e3
end

function vecsum_errbranch(x::NTuple{4,T}) where {T}
    y = r = e = zeros(T, 4)
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

function fast_vecsum_errbranch(x::NTuple{4,T}) where {T}
    y = zeros(T, 4)
    j = 1
    # e[1] = x1
    # i = 1
    r, t = two_sum(x[1], x[2])
    if t !== zero(T)
       y[j] = r
       e = t
       j += 1
    else
       e = r
    end
    # i = 2
    r, t = two_sum(e, x[3])
    if t !== zero(T)
       y[j] = r
       e = t
       j += 1
    else
       e = r
    end

    y[j], y[j+1] = two_sum(e, x[4])
    return y
end


function fast_vecsum_errbranch(x1::T,x2::T,x3::T,x4::T) where {T}
    y = zeros(T, 4)
    j = 1
    # e[1] = x1
    # i = 1
    r, t = two_sum(x1, x2)
    if t !== zero(T)
       y[j] = r
       e = t
       j += 1
    else
       e = r
    end
    # i = 2
    r, t = two_sum(e, x3)
    if t !== zero(T)
       y[j] = r
       e = t
       j += 1
    else
       e = r
    end

    y[j], y[j+1] = two_sum(e, x4)
    return y
end

function quadword(x1::T, x2::T, x3::T, x4::T) where {T}
    a1, a2 = two_sum(x1, x2)
    b1, b2 = two_sum(x3, x4)
    c1, c2 = two_sum(a1, b1)
    d1, d2 = two_sum(a2, b2)
    e1to4 = vec_sum(c1,c2,d1,d2)
    y = vecsum_errbranch(e1to4)
    return (y...,)
end

@inline function fast_quadword(x1::T, x2::T, x3::T, x4::T) where {T}
    a,b,c,d = maxtomin(x1,x2,x3,x4)
    return fast_vecsum_errbranch(a,b,c,d)
end

