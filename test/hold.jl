for (U,F) in ((:UInt64, :Float64), (:UInt32, :Float32), (:UInt16, :Float16))
  @eval begin
   @inline function ufp(x::$F)
       u = reinterpret($U, x)
       u = (u >> (precision($F)-1)) << (precision($F)-1)
       return reinterpret($F, u)
   end
  end
end

const Float64ulp = inv(ldexp(1.0, precision(Float64)))
const Float32ulp = inv(ldexp(1.0, precision(Float32)))
const Float16ulp = inv(ldexp(1.0, precision(Float16)))

@inline ulp(x::Float64) = ufp(x) * Float64ulp
@inline ulp(x::Float32) = ufp(x) * Float32ulp
@inline ulp(x::Float16) = ufp(x) * Float16ulp


function fin(n, val1, val2, f1, f2)
    v1=val1; v2=val2
    for i in 1:n
        v1 = f2(f1(v1,v2),v2)
    end
    return abs(HI(val1-v1))/ulp(LO(val1))
end

function invinv(n, val)
    v=val
    for i in 1:n
        v = inv(inv(v))
    end
    return abs(HI(val-v))/ulp(LO(val))
end

