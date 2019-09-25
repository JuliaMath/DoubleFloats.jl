function Base._cpow(z::Complex{DoubleFloat{T}}, p::Complex{DoubleFloat{T}}) where {T<:IEEEFloat}
    pᵣ, pᵢ = reim(p)
    r = abs(z)
    θ = angle(z)
    rᵖ = r^pᵣ * exp(-pᵢ*θ)
    ϕ = pᵣ*θ + pᵢ*log(r)
    if isfinite(ϕ)
        return rᵖ * cis(ϕ)
    else
        iszero(rᵖ) && return zero(Complex{DoubleFloat{T}}) # no way to get correct signs of 0.0
        return Complex{DoubleFloat{T}}(NaN) # non-finite phase angle or NaN input
    end
end
