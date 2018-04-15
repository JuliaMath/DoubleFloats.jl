# DoubleFloats: Appropriate Use

## [Introduction](https://github.com/JuliaMath/DoubleFloats.jl/blob/master/docs/src/lookingahead.md)

```
 
```

### Double


`Double` is the accuracy stalwart.  The algorithms and refinements that apply when used with reasonably
sized values, should limit the accrual of relative error from any basic arithmetic operation to 10⋅𝘂²,    
where 𝘂 is the relative rounding unit, the unit_in_the_last_place of the significand, often `eps(x)/2`.   
It is possible to accrue relative error steadily; so some experimentation guided algorithmic selection.
At worst, a sequence of 100_000 arithmetic operations might admit a relative error of 100_000 * 10⋅𝘂².

### what it is

What is that? 𝘂 is the last bit of the significand as a quantity, so a result that has a relative error
of 1_000_000⋅𝘂 is as a report that the final `ceil(Int, log2(1_000_000))` bits of the result's significand
are to be treated as inexactness rather than quantification. That means, for a Float64 value
(with a 53-bit significand) 53-20 bits remain reliable, while ~38% of the precision has become unvailable
to applications involve other's health, wealth, and well-being that are sheparded by responsible persons.

### how it is used

Were one working with Float32s (a 24-bit significand), the entire result would have become unreliable.
With `Double`, the relative error accompanying any basic arithmetic operation is 10⋅𝘂² (10×𝘂^𝟐).
It is reasonable to see this squaring as pulling in almost second significand's bits.  Our possibly
accrued relative error does eat into the number of reliable bits in this second order significance.
Nonetheless, if your use requires less than one million successive arithimetic operations, the
result obtained is reliable as a Float64 or as a Float32.

```
 
```


## FastDouble

`FastDoubles` do not have this way of working; instead, they offer a more performant alternative.
With computations that are heavily reliant upon elementary functions, `FastDoubles` are helpful.

When your work involves significant computational time, and your computations are numerical,
and they are sensitive, running through the work using `FastDoubles` is a good way to gain
insight into what is to come, an with that to better select your approach and its qualifications.
It may be that `FastDoubles` provide the scenario with ample assuredness.  Or, you may see that
there is no need to go beyond the usual IEEE754-2008 floating point types (Float64, Float32).
And there will be occasions wherewith `Double` is want well-met.

It is much easier to be at ease with one's own well-founded importances when one sees the ease.


### what it is

`FastDouble` is used interchangably with `Double`.  These are _sticky_ numerical types, feeding
forward `FastDouble`s will continue calculation with `FastDoubles`.  Providing `Doubles` for the
parametrics will causally entail using `Doubles`.

### how it is used

It is unwise to provide a mix of `Double` and `FastDouble` to the same flow.

This design provides that `Accuracy` subsume `Performance`.  Once given reason
to prefer a more accurate valuation, there is scant likelihood that redressing this would
be of beneift.  Should the need arise, it is quite simple to interconvert these types:

```julia
using DoubleFloats

an_accurate_variable  = 4 * inv(Double(pi))
a_performant_variable = FastDouble(golden)^2 - 1

henceforth_performant = FastDouble(an_accurate_variable)
hencefort_accurate    = Double(a_performant_variable)
```




#### the basic arithmetic operations
- addition, subtraction 
- multiplication, square, cube
- reciprocation, division, square root, cube root

#### rounding
- RoundNearest, RoundUp, RoundDown
- RoundToZero, RoundFromZero
- RoundNearestTiesAway, RoundNearestTiesUp

#### elementary mathematical functions
 - log, exp
 - sin, cos, tan, csc, sec, cot
 - asin, acos, atan, acsc, asec, acot
 - sinh, cosh, tanh, csch, sech, coth
 - asinh, acosh, atanh, acsch, asech, acoth

