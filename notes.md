```julia
using DoubleFloats, LinearAlgebra
m = reshape(rand(BigFloat, 5*5), (5,5)); fm=Float64.(m); dm=Double64.(m);

julia> Float32(tr(m) - tr(dm))
-5.515537f-33

julia> Float32(det(m) - det(dm))
-3.6832958f-34

julia> Float32.(adjoint(m) .- adjoint(dm))
5×5 Array{Float32,2}:
 -1.93891e-34   1.90586e-34  -9.08298e-36   1.74327e-33   4.98622e-34
 -2.83673e-33  -9.62669e-34  -1.30935e-34   2.25973e-33  -8.81795e-34
 -7.29522e-34   4.25907e-34  -4.39425e-34  -1.36976e-33   7.43426e-34
 -3.4335e-34   -4.3239e-36    6.1866e-35    1.14578e-33  -5.45798e-34
  2.12375e-33   8.6745e-35    4.52805e-35  -4.53302e-35   1.09764e-33

julia> Float32.(inv(m) .- inv(dm))
5×5 Array{Float32,2}:
 -4.9948e-30   -2.74597e-30  -1.8565e-30    2.3607e-30    6.5118e-30 
  6.44136e-30   3.3714e-30    2.11291e-30  -2.98076e-30  -7.43532e-30
 -9.85113e-31  -5.18483e-31  -3.42839e-31   4.67933e-31   1.30927e-30
  2.8115e-30    1.58373e-30   8.92952e-31  -1.30845e-30  -2.93912e-30
 -6.7978e-30   -3.28024e-30  -1.98576e-30   3.01289e-30   7.02272e-30

julia> Float32.((m*m) .- (dm*dm))
5×5 Array{Float32,2}:
 4.44904e-17   2.5384e-17   2.0828e-17   -7.97662e-18  -9.40117e-18
 4.00967e-17   8.67176e-18  2.70869e-17  -3.73303e-18   1.705e-17  
 1.28955e-17   1.24394e-17  1.1963e-17   -2.85611e-18  -5.24482e-18
 2.74108e-17  -2.53045e-18  2.0731e-17    7.12751e-18   1.95265e-17
 5.44782e-17   3.46229e-17  2.7525e-17   -1.32094e-17  -1.26024e-17

matmul2x2(m) = [(m[1,1]*m[1,1])+(m[1,2]*m[2,1]) (m[1,1]*m[1,2])+(m[1,2]*m[2,2]);
                       (m[2,1]*m[1,1])+(m[2,2]*m[2,1]) (m[2,1]*m[1,2])+(m[2,2]*m[2,2])]



julia> using DoubleFloats, GenericLinearAlgebra, Random

julia> m = reshape(rand(BigFloat,2*2), (2,2)); fm=Float64.(m); dm=Double64.(m);

julia> eigvals(m) .- eigvals(dm)
ERROR: UndefVarError: eigvals not defined
Stacktrace:
 [1] top-level scope at none:0

julia> eigvals!(m) .- eigvals!(dm)
ERROR: UndefVarError: eigvals! not defined
Stacktrace:
 [1] top-level scope at none:0

julia> using LinearAlgebra

julia> eigvals(m) .- eigvals(dm)
2-element Array{Complex{BigFloat},1}:
 -4.071640696197188570653575899471960596590629652118186673225473327733181438654675e-32 + 0.0im
 -5.696254126141096064103930886586648783736560608141594381619979715602311585541413e-33 - 0.0im

julia> svdvals(m) .- svdvals(dm)
2-element Array{BigFloat,1}:
 1.178081989479917838447488783454471231112449340685927119701212949822873249002416e-32
 1.349926144342590313924882555904511808363939217207918450313311400847944711997193e-33



# for eigvals
using LinearAlgebra
import LinearAlgebra: rmul!, lmul!
# from GenericLinearAlgebra.jl
juliaBLAS.jl
householder.jl
eigenGeneral.jl
(eigenSelfAdjoint.jl) ?

