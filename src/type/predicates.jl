"""
__Predicates__ are functions that ask "yes or no" questions of their argument[s].     
You can ask of a number "Is this zero?" or "Is this one?" and these predicates
(`iszero`, `isone`) will work as expected with almost all numerical types.
The built-in numerical types let you query finiteness (`isfinite`, `isinf`).

These are the predicates made available for use with DoubleFloats:

> iszero, isnonzero, isone                 #  value == 0, value != 0, value == 1
  ispositive, isnegative,                  #  value >  0, value <  0
  isnonnegative, isnonpositive,            #  value >= 0, value <= 0   
  isinteger, isfractional                  #  value == round(value) 
  isfinite, isinf,                         #  abs(value) != Inf, abs(value) == Inf
  isposinf, isneginf,                      #  value == Inf, value == -Inf
  isnan                                    #  value is not a number (eg 0/0)
    
"""


#=

int arf_is_zero(const arf_t x)

int arf_is_one(const arf_t x)

int arf_is_pos_inf(const arf_t x)

int arf_is_neg_inf(const arf_t x)

int arf_is_nan(const arf_t x)

    Returns nonzero iff x respectively equals 0, 1, +∞, −∞, NaN.
    
int arf_is_inf(const arf_t x)

    Returns nonzero iff x equals either +∞ or −∞.

int arf_is_normal(const arf_t x)

    Returns nonzero iff x is a finite, nonzero floating-point value, 
    i.e. not one of the special values 0, +∞, −∞, NaN.

int arf_is_special(const arf_t x)

    Returns nonzero iff x is one of the special values
    0, +∞, −∞, NaN, i.e. not a finite, nonzero floating-point value.

int arf_is_finite(arf_t x)

    Returns nonzero iff x is a finite floating-point value, i.e. not one of the values
    +∞, −∞, NaN. (Note that this is not equivalent to the negation of arf_is_inf().)
=#


function iszero(x::Double{T,E}) where {T<:FLOPT, E<:Emphasis}
  

end

  iszero, isnonzero, isone                 #  value == 0, value != 0, value == 1
  ispositive, isnegative,                  #  value >  0, value <  0
  isnonnegative, isnonpositive,            #  value >= 0, value <= 0   
  isinteger, isfractional                  #  value == round(value) 
  isfinite, isinf,                         #  abs(value) != Inf, abs(value) == Inf
  isposinf, isneginf,                      #  value == Inf, value == -Inf
  isnan

end
  
