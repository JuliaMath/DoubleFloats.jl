# A SplitMix64 generator owned by the test suite, so that recorded inputs do
# not depend on the stream of Julia's `Random`, which may change between
# Julia versions.

mutable struct SplitMix64
    state::UInt64
end

function next!(g::SplitMix64)
    g.state += 0x9e3779b97f4a7c15
    z = g.state
    z = (z ⊻ (z >> 30)) * 0xbf58476d1ce4e5b9
    z = (z ⊻ (z >> 27)) * 0x94d049bb133111eb
    return z ⊻ (z >> 31)
end

# Uniform on [0, 1) with 53 random bits.
unitfloat!(g::SplitMix64) = (next!(g) >> 11) * 0x1.0p-53
