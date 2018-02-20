# DoubleFloats: some good use


## looking ahead

When you are `using DoubleFloats`, two related numeric types become available: `Double` and `FastDouble`.

These types are identical in coverage and compatibility. Any function that knows of one knows of both.
Every function that is imported from Base.Math and overloaded in order to just work and work well with
`Double`s will do the same with `FastDoubles`.  And they utilize identical code for some of their work.



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
With `Double`, the relative error accompanying any basic arithmetic operation is 10⋅𝘂² (10*𝘂^𝟐).
It is reasonable to see this squaring as pulling in almost second significand's bits.  Our possibly
accrued relative error does eat into the number of reliable bits in this second order significance.
Nonetheless, if your use requires less than one million successive arithimetic operations, the
result obtained is reliable as a Float64 or as a Float32.

====


## FastDouble

`FastDoubles` do not have this way of working; instead, they offer a more performant alternative.
With computations that are heavily reliant upon elementary functions, `FastDoubles` are helpful.

### what it is



### how it is used




#### the basic arithmetic operations
- addition, subtraction, 
- multiplication, square, cube, fourth power
- reciprocation, division, square root, cube root, fourth root



