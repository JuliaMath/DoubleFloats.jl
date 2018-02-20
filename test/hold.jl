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

ulp(x::Double{T,E}) where {T,E} = ulp(LO(x))
ulp(x::Tuple{T,T}) where {T} = ulp(x[2])


function relative_ulp(given, found)
  given_ulp = ulp(given)
  return HI(abs(given - found)) / given_ulp
end
  

function fin(n, val1, val2, f1, f2)
    v1=val1; v2=val2
    for i in 1:n
        v1 = f2(f1(v1,v2),v2)
    end
    return relative_ulp(val1, v1)
  end

function invinv(n, val)
    v=val
    for i in 1:n
        v = inv(inv(v))
    end
    return relative_ulp(val, v)
end
function aua(n, aply::Vector{Function}, unaply::Vector{Function}, val1, val2)
           v1 = val1; v2 = val2; v=val1; for i in 1:n
           for fn in aply
               v = fn(v,v2); 
           end
           for fn in unaply
               v = fn(v, v2); 
            end; end
           return relative_ulp(v1, v)
       end
