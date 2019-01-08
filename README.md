# StructReinterpret.jl

[![Build Status](https://travis-ci.org/favba/StructReinterpret.jl.svg?branch=master)](https://travis-ci.org/favba/StructReinterpret.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/b35ephpx1s1uj97m?svg=true)](https://ci.appveyor.com/project/favba/structreinterpret-jl)
[![Coverage Status](https://coveralls.io/repos/github/favba/StructReinterpret.jl/badge.svg?branch=master)](https://coveralls.io/github/favba/StructReinterpret.jl?branch=master)
[![codecov](https://codecov.io/gh/favba/StructReinterpret.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/favba/StructReinterpret.jl)

This package provides an array type similar to `ReinterpretArray` for reinterpreting bits type element arrays as an array of a homogeneous struct. It works with `NTuple` wrapper structs as well, such as `StaticArray`s.
Since the scope of this package is limited to homogeneous structs, we are able to provide a faster implementation of `getindex`.
The reinterpreted views are constructed using the function `struct_reinterpret(::Type{StructType}, A::Array)`.

## Quick start

```julia
julia> using StructReinterpret

julia> using BenchmarkTools

julia> using StaticArrays

julia> a = rand(16,16)
16×16 Array{Float64,2}:
 0.875014    0.416685   0.621561   0.384859   0.667835   …  0.216662    0.374557   0.917396   0.130807
 0.246099    0.0342423  0.954619   0.97971    0.965025      0.102531    0.0383284  0.209974   0.510821
 0.216308    0.419426   0.0832236  0.255366   0.946569      0.0964819   0.866634   0.976113   0.881321
 0.809495    0.978105   0.794213   0.0227254  0.546804      0.035234    0.0291488  0.892203   0.561338
 0.508886    0.715384   0.298849   0.73234    0.868665      0.370543    0.398822   0.853815   0.763415
 0.516966    0.13554    0.357667   0.270016   0.294258   …  0.612717    0.40947    0.87473    0.722321
 0.0588623   0.49227    0.677219   0.513642   0.399244      0.00378207  0.335834   0.575709   0.560295
 0.40336     0.112596   0.65482    0.110796   0.501041      0.824756    0.602597   0.41101    0.148798
 0.416314    0.900824   0.495721   0.0565835  0.303076      0.042943    0.40373    0.730327   0.216735
 0.227081    0.464685   0.853119   0.739154   0.899333      0.430394    0.444928   0.670904   0.633727
 0.369514    0.879112   0.223657   0.138067   0.0621263  …  0.331263    0.7227     0.682614   0.487437
 0.460371    0.780633   0.524148   0.923904   0.493046      0.630204    0.452069   0.0684457  0.462189
 0.00884589  0.737021   0.0282085  0.777078   0.255077      0.857888    0.211491   0.286567   0.698837
 0.132446    0.973928   0.206144   0.766223   0.767426      0.211002    0.0129859  0.120143   0.887541
 0.91351     0.814305   0.142757   0.897146   0.819569      0.924263    0.350141   0.617936   0.133594
 0.72665     0.998746   0.116852   0.502043   0.205864   …  0.790677    0.0130923  0.745223   0.931052

julia> sr = struct_reinterpret(SVector{2,Float64},a) # reinterpret function provided by this package
8×16 StructReinterpret.StructReinterpretDenseArray{SArray{Tuple{2},Float64,1,2},2,Array{Float64,2}}:
 [0.875014, 0.246099]    [0.416685, 0.0342423]  …  [0.917396, 0.209974]   [0.130807, 0.510821]
 [0.216308, 0.809495]    [0.419426, 0.978105]      [0.976113, 0.892203]   [0.881321, 0.561338]
 [0.508886, 0.516966]    [0.715384, 0.13554]       [0.853815, 0.87473]    [0.763415, 0.722321]
 [0.0588623, 0.40336]    [0.49227, 0.112596]       [0.575709, 0.41101]    [0.560295, 0.148798]
 [0.416314, 0.227081]    [0.900824, 0.464685]      [0.730327, 0.670904]   [0.216735, 0.633727]
 [0.369514, 0.460371]    [0.879112, 0.780633]   …  [0.682614, 0.0684457]  [0.487437, 0.462189]
 [0.00884589, 0.132446]  [0.737021, 0.973928]      [0.286567, 0.120143]   [0.698837, 0.887541]
 [0.91351, 0.72665]      [0.814305, 0.998746]      [0.617936, 0.745223]   [0.133594, 0.931052]

julia> r = reinterpret(SVector{2,Float64},a)
8×16 reinterpret(SArray{Tuple{2},Float64,1,2}, ::Array{Float64,2}):
 [0.875014, 0.246099]    [0.416685, 0.0342423]  …  [0.917396, 0.209974]   [0.130807, 0.510821]
 [0.216308, 0.809495]    [0.419426, 0.978105]      [0.976113, 0.892203]   [0.881321, 0.561338]
 [0.508886, 0.516966]    [0.715384, 0.13554]       [0.853815, 0.87473]    [0.763415, 0.722321]
 [0.0588623, 0.40336]    [0.49227, 0.112596]       [0.575709, 0.41101]    [0.560295, 0.148798]
 [0.416314, 0.227081]    [0.900824, 0.464685]      [0.730327, 0.670904]   [0.216735, 0.633727]
 [0.369514, 0.460371]    [0.879112, 0.780633]   …  [0.682614, 0.0684457]  [0.487437, 0.462189]
 [0.00884589, 0.132446]  [0.737021, 0.973928]      [0.286567, 0.120143]   [0.698837, 0.887541]
 [0.91351, 0.72665]      [0.814305, 0.998746]      [0.617936, 0.745223]   [0.133594, 0.931052]

julia> nr = Array(r) 
8×16 Array{SArray{Tuple{2},Float64,1,2},2}:
 [0.875014, 0.246099]    [0.416685, 0.0342423]  …  [0.917396, 0.209974]   [0.130807, 0.510821]
 [0.216308, 0.809495]    [0.419426, 0.978105]      [0.976113, 0.892203]   [0.881321, 0.561338]
 [0.508886, 0.516966]    [0.715384, 0.13554]       [0.853815, 0.87473]    [0.763415, 0.722321]
 [0.0588623, 0.40336]    [0.49227, 0.112596]       [0.575709, 0.41101]    [0.560295, 0.148798]
 [0.416314, 0.227081]    [0.900824, 0.464685]      [0.730327, 0.670904]   [0.216735, 0.633727]
 [0.369514, 0.460371]    [0.879112, 0.780633]   …  [0.682614, 0.0684457]  [0.487437, 0.462189]
 [0.00884589, 0.132446]  [0.737021, 0.973928]      [0.286567, 0.120143]   [0.698837, 0.887541]
 [0.91351, 0.72665]      [0.814305, 0.998746]      [0.617936, 0.745223]   [0.133594, 0.931052]

julia> @benchmark sum($nr) # for base comparision
BenchmarkTools.Trial:
  memory estimate:  0 bytes
  allocs estimate:  0
  --------------
  minimum time:     95.649 ns (0.00% GC)
  median time:      95.782 ns (0.00% GC)
  mean time:        96.023 ns (0.00% GC)
  maximum time:     155.224 ns (0.00% GC)
  --------------
  samples:          10000
  evals/sample:     950

julia> @benchmark sum($r) # julia's built-in reinterpret array
BenchmarkTools.Trial:
  memory estimate:  0 bytes
  allocs estimate:  0
  --------------
  minimum time:     120.977 ns (0.00% GC)
  median time:      121.432 ns (0.00% GC)
  mean time:        122.028 ns (0.00% GC)
  maximum time:     550.409 ns (0.00% GC)
  --------------
  samples:          10000
  evals/sample:     907

julia> @benchmark sum($sr) # this packages implementation of reinterpret array
BenchmarkTools.Trial:
  memory estimate:  0 bytes
  allocs estimate:  0
  --------------
  minimum time:     96.732 ns (0.00% GC)
  median time:      97.040 ns (0.00% GC)
  mean time:        97.705 ns (0.00% GC)
  maximum time:     246.368 ns (0.00% GC)
  --------------
  samples:          10000
  evals/sample:     949

```