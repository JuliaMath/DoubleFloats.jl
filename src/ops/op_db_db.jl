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

@inline function inv_db_db(x::Double{T,Accuracy}) where {T<:AbstractFloat}
    hi, lo = inv_dd_dd(HILO(x))
    return Double(Accuracy, hi, lo)
end

@inline function inv_db_db(x::Double{T,Performance}) where {T<:AbstractFloat}
    hi, lo = inv_dd_dd_fast(HILO(x))
    return Double(Performance, hi, lo)
end

@inline function sqrt_db_db(x::Double{T,E}) where {T<:AbstractFloat, E<:Emphasis}
    hi, lo = sqrt_dd_dd(HILO(x))
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
