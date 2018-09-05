for F in (:(+), :(-), :(*), :(/), :(%), :(^))
  @eval begin
      function $F(x::DoubleFloat{T1}, y::Union{Signed, Unsigned, IEEEFloat}) where {T1<:IEEEFloat}
         return $F(x, DoubleFloat{T1}(y))
      end
      function $F(x::Union{Signed, Unsigned, IEEEFloat}, y::DoubleFloat{T1}) where {T1<:IEEEFloat}
         return $F(DoubleFloat{T1}(x), y)
      end
  end
end
