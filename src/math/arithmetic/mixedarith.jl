for F in (:(+), :(-), :(*), :(/), :(%), :(^))
  @eval begin
      function $F(x::DoubleFloat{T1}, y::T2) where {T1<:IEEEFloat, T2<:Union{Signed, Unsigned, AbstractFloat}}
         return $F(x, DoubleFloat{T1}(y))
      end
      function $F(x::T2, y::DoubleFloat{T1}) where {T1<:IEEEFloat, T2<:Union{Signed, Unsigned, AbstractFloat}}
         return $F(DoubleFloat{T1}(x), y)
      end
  end
end
