# Show, String, Parse

## Show
```julia
julia> x = sqrt(Double64(2)) / sqrt(Double64(6))
0.5773502691896257

julia> show(IOContext(Base.stdout,:compact=>false),x)
5.7735026918962576450914878050194151e-01

julia> showall(x)
0.5773502691896257645091487805019415

julia> showtyped(x)
Double64(0.5773502691896257, 3.3450280739356326e-17)

julia> c = ComplexDF32(sqrt(df32"2"), cbrt(df32"3"))
1.4142135 + 1.4422495im

julia> showall(c)
1.414213562373095 + 1.442249570307406im

julia> showtyped(c)
ComplexDF32(Double32(1.4142135, 2.4203235e-8), Double32(1.4422495, 3.3793125e-8))
```

## String
```julia
julia> using DoubleFloats

julia> x = sqrt(Double64(2)) / sqrt(Double64(6))
0.5773502691896257

julia> string(x)
"5.7735026918962576450914878050194151e-01"

julia> c = ComplexDF32(sqrt(df32"2"), cbrt(df32"3"))
1.4142135 + 1.4422495im

julia> string(c)
"1.414213562373094 + 1.442249570307406im"

julia> stringtyped(c)
"ComplexD32(Double32(1.4142135, 2.4203233e-8), Double32(1.4422495, 3.3793125e-8))"
```

## Parse
```julia
julia> x = sqrt(Double64(2)) / sqrt(Double64(6))
0.5773502691896257

julia> Meta.parse(stringtyped(x)
:(Double64(0.5773502691896257, 3.3450280739356326e-17))
```
