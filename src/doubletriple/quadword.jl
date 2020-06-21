function vec_sum(x0::T, x1::T, x2::T, x3::T) where {T}
    s3 = x3
    s2, e3 = two_sum(x2, s3)
    s1, e2 = two_sum(x1, s2)
    s0, e1 = two_sum(x0, s1)
    return s0,e1,e2,e3
end
