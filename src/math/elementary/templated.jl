for F in (# :mod2pi, :square, :cube, :sqrt, 
          :cbrt,
          :exp, :expm1, :log, :log1p, :log2, :log10, 
          :sin, :cos, :tan, :csc, :sec, :cot,
          :asin, :acos, :atan, :acsc, :asec, :acot,
          :sinh, :cosh, :tanh, :csch, :sech, :coth,
          :asinh, :acosh, :atanh, :acsch, :asech, :acoth)
  @eval begin
    $F(x::DoubleF32) = DoubleF32($F(DoubleF64(x)))
    $F(x::DoubleF16) = DoubleF16($F(DoubleF64(x)))
    $F(x::DoubleFloat{DoubleF32}) = DoubleFloat{DoubleF32}($F(DoubleFloat{DoubleF64}(x)))
    $F(x::DoubleFloat{DoubleF16}) = DoubleFloat{DoubleF16}($F(DoubleFloat{DoubleF64}(x)))
  end
end

"""
    DomainGuard{T}

An easy way to provide mathematical functions
guards that disallow out-of-domain processing
describes the canonical value-span and offers
the manner of reductive domain comprehension.

For discontinous [gapping} periodic functions,
all that spans any of a subdomain collective
is included and admissable.  Each evaluand is
provisional; quantities with qualities map
the domain-reachable onto canonical values.

""" DomainGuard

#=
   missing values participate in exclusion
   given values bound regions of inclusion
=#

struct DomainGuard{T}
          
    maxneg::T           # most  negagtive magnitude of primary domain
    minneg::T           # least negative  magnitude of primary domain
    minpos::T           # zero or least positive magnitude of primary domain
    maxpos::T           # +inf or most positive magnitude of pa

    reduct::Function    # comprehensive domain >=>=> canonical domain 

                        # boolean-valued states for each specialized numerica   
    posinf::Bool
    posval::Bool
    negval::Bool
    neginf::Bool
 
    okzero::Bool

end
