# Random

```julia
julia> rand(Double64)
0.2654749880242928

julia> rand(Double32, 4)
4-element Array{DoubleFloat{Float32},1}:
 0.62278694
 0.14700651
 0.42059994
 0.8824145 

julia> randpm(Double32)
-0.78260666

julia> randpm(Double64, 4)
4-element Array{DoubleFloat{Float64},1}:
  0.8066283194653339
  0.3846875811169719
 -0.8318619362182055
 -0.1718555031982676

julia> rand(ComplexDF32)
0.7863289 + 0.9202755im

julia> randpm(ComplexDF32,5)
5-element Array{Complex{DoubleFloat{Float32}},1}:
 -0.22268367 + 0.94761634im
   0.9173372 - 0.51481026im
  0.22448015 + 0.20910525im
 -0.25364602 + 0.4772849im 
 -0.52076036 - 0.40857565im
```
