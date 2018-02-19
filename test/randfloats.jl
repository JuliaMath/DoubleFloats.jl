#= for significands in [1, 2), exponents are powers of 2
exponent_max(::Type{Float16})  =   15
exponent_max(::Type{Float32})  =  127
exponent_max(::Type{Float64})  = 1023
exponent_min(::Type{Float16})  = 1 -   15
exponent_min(::Type{Float32})  = 1 -  127
exponent_min(::Type{Float64})  = 1 - 1023
=#
# for significands in [0.5, 1)
exponent_max(::Type{Float16})  =   15+1
exponent_max(::Type{Float32})  =  127+1
exponent_max(::Type{Float64})  = 1023+1
exponent_min(::Type{Float16})  = 2 -   15
exponent_min(::Type{Float32})  = 2 -  127
exponent_min(::Type{Float64})  = 2 - 1023

for (U,F) in ((:UInt64, :Float64), (:UInt32, :Float32), (:UInt16, :Float16))
    @eval begin
        function randf(::Type{$F})
            r = $F(Inf)
            while !isfinite(r)
                r = reinterpret($F, rand($U))
            end
            return r
        end
        function randfloat(::Type{$F}, n::Int=1; emin::Int=exponent_min($F), emax::Int=exponent_max($F), signed::Bool=false)
            emin, emax = minmax(emin, emax)
            emin = max(exponent_min($F), emin)
            emax = min(exponent_max($F), emax)
            n = max(1, n)
            result = rand($F, n)
            # significands in [0.5, 1)
            result *= 0.5
            result += 0.5
            exponent = rand(emin:1:emax, n)
            for i in 1:n
                result[i] = ldexp(result[i], exponent[i]) 
            end
            if signed
               signs = rand(-1:2:1,n)
               for i in 1:n
                   result[i] = copysign(result[i], signs[i])
               end
            end
            return result
        end
    end
end
