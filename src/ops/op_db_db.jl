@inline function abs_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = abs_dd_dd(HILO(x))
    return Double(E, hi, lo)
end

@inline function neg_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = neg_dd_dd(HILO(x))
    return Double(E, hi, lo)
end

@inline function negabs_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = negabs_dd_dd(HILO(x))
    return Double(E, hi, lo)
end

@inline function inv_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = inv_dd_dd(HILO(x))
    return Double(E, hi, lo)
end

function root2_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
     iszero(x) && return x
     signbit(x) && throw(DomainError("sqrt(x) expects x >= 0"))

     xhi, xlo = HILO(x)
     half = T(0.5)
     dhalf = Double{T,E}(half)

     r = inv(sqrt(xhi))
     h = Double{T,E}(xhi * half, xlo * half)

     r2 = r * r
     hr2 = h * r2
     radj = dhalf - hr2
     radj = radj * r
     r = r + radj

     r2 = r * r
     hr2 = h * r2
     radj = dhalf - hr2
     radj = radj * r
     r = r + radj

     r = r * x
     return r
end
   
function inv_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    xhi, xlo = HILO(x)
    db1 = one(Double{T,E})
    q0 = one(T) / xhi
    xq0 = mul_dbfp_db(x, q0)
    r   = sub_dbdb_db(db1, xq0)
    q1  = HI(r) / xhi
    xq1 = mul_dbfp_db(x, q1)
    r   = sub_dbdb_db(db1, xq1)
    q2  = HI(r) / xhi
   
    xhi, xlo = add_hilo_2(q0, q1, q2)
    return Double(E, xhi, xlo)
end
