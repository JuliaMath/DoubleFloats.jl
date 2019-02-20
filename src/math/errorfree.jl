#=
this is a canonical implementation
the implemented version benchmarked slightly better under a variety of inputs (julia v1.0.1)
@inline function two_sum(a::T, b::T) where {T<:AbstractFloat}
    hi = a + b
    v  = hi - a
    lo = (a - (hi - v)) + (b - v)
    return hi, lo
end
=#

const FloatWithFMA = Union{Float64, Float32, Float16}

"""
    two_sum(a, b)
Computes `hi = fl(a+b)` and `lo = err(a+b)`.
"""
@inline function two_sum(a::T, b::T) where {T<:FloatWithFMA}
    hi = a + b
    a1 = hi - b
    b1 = hi - a1
    lo = (a - a1) + (b - b1)
    return hi, lo
end

"""
    three_sum(a, b, c)

Computes `hi = fl(a+b+c)` and `md = err(a+b+c), lo = err(md)`.
"""
function three_sum(a::T, b::T, c::T) where {T<:FloatWithFMA}
    s, t   = two_sum(b, c)
    hi, u  = two_sum(a, s)
    md, lo = two_sum(u, t)
    hi, md = two_hilo_sum(hi, md)
    return hi, md, lo
end


"""
    four_sum(a, b, c, d)
    
Computes `hi = fl(a+b+c+d)` and `hm = err(a+b+c+d), ml = err(hm), lo = err(ml)`.
"""
function four_sum(a::T,b::T,c::T,d::T) where {T<:FloatWithFMA}
    t0, t1 = two_sum(a ,  b)
    t0, t2 = two_sum(t0,  c)
    hi, t3 = two_sum(t0,  d)
    t0, t1 = two_sum(t1, t2)
    hm, t2 = two_sum(t0, t3) # here, t0 >= t3
    ml, lo = two_sum(t1, t2)
    return hi, hm, ml, lo
end



"""
    two_sumof3(a, b, c)

Computes `hi = fl(a+b+c)` and `lo = err(a+b+c)`.
"""
function two_sumof3(a::T, b::T, c::T) where {T<:FloatWithFMA}
    s, t = two_sum(b, c)
    x, u = two_sum(a, s)
    y    = u + t
    x, y = two_sum(x, y)
    return x, y
end

@inline two_sum(a::T, b::T, c::T) where {T<:FloatWithFMA} = two_sumof3(a, b, c)

"""
    two_sumof4(a, b, c, d)

Computes `hi = fl(a+b+c+d)` and `lo = err(a+b+c+d)`.
"""
function two_sumof4(a::T, b::T, c::T, d::T) where {T<:FloatWithFMA}
    t0, t1 = two_sum(a ,  b)
    t0, t2 = two_sum(t0,  c)
    a,  t3 = two_sum(t0,  d)
    t0  = t1 + t2
    b   = t0 + t3
    return a, b
end

@inline two_sum(a::T, b::T, c::T, d::T) where {T<:FloatWithFMA} = two_sumof4(a, b, c, d)

function three_sumof4(a::T,b::T,c::T,d::T) where {T<:FloatWithFMA}
    t0, t1 = two_sum(a ,  b)
    t0, t2 = two_sum(t0,  c)
    hi, t3 = two_sum(t0,  d)
    t0, t1 = two_sum(t1, t2)
    hm, t2 = two_sum(t0, t3) # here, t0 >= t3
    ml     = t1 + t2
    return hi, hm, ml
end

@inline three_sum(a::T, b::T, c::T, d::T) where {T<:FloatWithFMA} = thre_sumof4(a, b, c, d)

"""
    two_diff(a, b)

Computes `hi = fl(a-b)` and `lo = err(a-b)`.
"""
@inline function two_diff(a::T, b::T) where {T<:FloatWithFMA}
    hi = a - b
    a1 = hi + b
    b1 = hi - a1
    lo = (a - a1) - (b + b1)
    return hi, lo
end

"""
    two_diffof3(a, b, c)

Computes `hi = fl(a-b-c)` and `lo = err(a-b-c)`.
"""
function two_diffof3(a::T, b::T, c::T) where {T<:FloatWithFMA}
    s, t = two_diff(-b, c)
    x, u = two_sum(a, s)
       y = u + t
    x, y = two_sum(x, y)
    return x, y
end

@inline two_diff(a::T, b::T, c::T) where {T<:FloatWithFMA} = two_diffof3(a, b, c)
        
"""
    two_hilo_sum(a, b)

*unchecked* requirement `|a| ≥ |b|`
Computes `s = fl(a+b)` and `e = err(a+b)`.
"""
@inline function two_hilo_sum(a::T, b::T) where {T<:FloatWithFMA}
    s = a + b
    e = b - (s - a)
    return s, e
end


"""
    three_hilo_sum(a, b, c)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c|`
Computes `s = fl(a+b+c)` and `e1 = err(a+b+c), e2 = err(e1)`.
"""
function three_hilo_sum(a::T,b::T,c::T) where {T<:FloatWithFMA}
    s, t = two_hilo_sum(b, c)
    x, u = two_hilo_sum(a, s)
    y, z = two_hilo_sum(u, t)
    x, y = two_hilo_sum(x, y)
    return x, y, z
end

"""
    two_hilo_sumof3(a, b, c)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c|`
Computes `s = fl(a+b+c)` and `e1 = err(a+b+c)`.
"""
function two_hilo_sumof3(a::T,b::T,c::T) where {T<:FloatWithFMA}
    s, t = two_hilo_sum(b, c)
    x, u = two_hilo_sum(a, s)
    y    = u + t
    x, y = two_hilo_sum(x, y)
    return x, y
end

"""
    four_hilo_sum(a, b, c, d)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c| ≥ |d|`
Computes `s = fl(a+b+c+d)` and `e1 = err(a+b+c+d), e2 = err(e1), e3 = err(e2)`.
"""
function four_hilo_sum(a::T,b::T,c::T,d::T) where {T<:FloatWithFMA}
    t0, t1 = two_hilo_sum(a ,  b)
    t0, t2 = two_hilo_sum(t0,  c)
    hi, t3 = two_hilo_sum(t0,  d)
    t0, t1 = two_hilo_sum(t1, t2)
    hm, t2 = two_hilo_sum(t0, t3) # here, t0 >= t3
    ml, lo = two_hilo_sum(t1, t2)
    return hi, hm, ml, lo
end

"""
    three_hilo_sumof4(a, b, c, d)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c| ≥ |d|`
Computes `s = fl(a+b+c+d)` and `e1 = err(a+b+c+d), e2 = err(e1)`.
"""
function three_hilo_sumof4(a::T,b::T,c::T,d::T) where {T<:FloatWithFMA}
    t0, t1 = two_hilo_sum(a ,  b)
    t0, t2 = two_hilo_sum(t0,  c)
    hi, t3 = two_hilo_sum(t0,  d)
    t0, t1 = two_hilo_sum(t1, t2)
    md, t2 = two_hilo_sum(t0, t3) # here, t0 >= t3
    lo     = t1 + t2
    return hi, md, lo
end


"""
    two_hilo_sumof4(a, b, c, d)
    
*unchecked* requirement `|a| ≥ |b| ≥ |c| ≥ |d|`
Computes `s = fl(a+b+c+d)` and `e1 = err(a+b+c+d)`.
"""
function two_hilo_sumof4(a::T,b::T,c::T,d::T) where {T<:FloatWithFMA}
    t0, t1 = two_hilo_sum(a ,  b)
    t0, t2 = two_hilo_sum(t0,  c)
    hi, t3 = two_hilo_sum(t0,  d)
    t0     = t1 + t2
    lo     = t0 + t3
    return hi, lo
end


@inline function two_prod(a::T, b::T) where {T<:FloatWithFMA}
    s = a * b
    t = fma(a, b, -s)
    return s, t
end
