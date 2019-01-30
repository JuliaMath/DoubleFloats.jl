# The Types


## Double64


`Double64` is the accuracy stalwart.  Very good values are likely to result.

When used with reasonably sized values, the computations should limit the accrual of relative error to 10⋅𝘂²,
where 𝘂 is the relative rounding unit, the unit_in_the_last_place of the significand, often `eps(x)/2`.
It is possible to accrue relative error steadily; so some experimentation has guided algorithmic selection.
At worst, a sequence of 100_000 arithmetic and elementary operations might admit a relative error of 100_000 * 10⋅𝘂².
The worst is unlikely.

One right way to use this type is

1. map your input from Float64s to Double64s
2. compute with Double64s
3. map your resultant values from Double64s to Float64s

The values obtained with cascaded arithimetic and composed elementary functions
are reliable and their utility is desireable.

### what it is

What is that? 𝘂 is the last bit of the significand as a quantity, so a result that has a relative error
of 1_000_000⋅𝘂 is as a report that the final `ceil(Int, log2(1_000_000))` bits of the result's significand
are to be treated as inexactness rather than quantification. That means, for a Float64 value
(with a 53-bit significand) 53-20 bits remain reliable, while ~38% of the precision has become unavailable
to applications involve other's health, wealth, and well-being that are shepherded by responsible persons.

### how it is used

Were one working with Float32s (a 24-bit significand), the entire result would have become unreliable.
With `Double`, the relative error accompanying any basic arithmetic operation is 10⋅𝘂² (10×𝘂^𝟐).
It is reasonable to see this squaring as pulling in almost second significand's bits.  Our possibly
accrued relative error does eat into the number of reliable bits in this second order significance.
Nonetheless, if your use requires less than one million successive arithmetic operations, the
result obtained is reliable as a Float64 or as a Float32.


