# Random numbers

Use `rand(T)` for a uniform sample on the unit interval and
`rand(T, n)` for a vector of samples. The complex sampler draws
the real and imaginary parts separately.

For real DoubleFloats, `randn(T)` draws a standard normal sample.
`randpm(T)` applies a random sign to a uniform sample. For complex
values, `randpm` applies signs to the two components independently.

```@example random_samples
using DoubleFloats, Random

rng = MersenneTwister(42)
uniform = rand(rng, Double64, 4)
normal = randn(rng, Double64)
signed = randpm(rng, ComplexDF64, 4)

@assert length(uniform) == length(signed) == 4
@assert normal isa Double64
nothing
```

An explicit RNG makes the example independent of the session's default
generator. For `randpm`, the explicit RNG methods accept
`MersenneTwister`.
