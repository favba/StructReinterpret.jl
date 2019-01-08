using StructReinterpret
using Test 

@testset "Unidimensional Vector of Tuples" begin

    a = [1., 2., 3., 4., 5., 6., 7., 8., 9.]
    @inferred struct_reinterpret(NTuple{3,Float64},a)
    ra = struct_reinterpret(NTuple{3,Float64},a)

    @test size(ra) === (3,)

    @test ra[1] === (1.,2.,3.)
    @test ra[2] === (4.,5.,6.)

    @test setindex!(ra,(3,2,1),1) == [(3.,2.,1.),(4.,5.,6.),(7.,8.,9.)]

    @test setindex!(ra,(3,2,1),2) == [(3.,2.,1.),(3.,2.,1.),(7.,8.,9.)]

    @test_throws BoundsError getindex(ra,4)
    @test_throws BoundsError setindex!(ra,(1,1,1),4)

end

@testset "2D Array of Tuples" begin

    a = [1 5 9 13
         2 6 10 14
         3 7 11 15
         4 8 12 16]
    @inferred struct_reinterpret(NTuple{2,Int},a)
    ra = struct_reinterpret(NTuple{2,Int},a)

    @test size(ra) === (2,4)

    @test ra[1,1] === (1,2)
    @test ra[2,1] === (3,4)
    @test ra[2,4] === (15,16)

    @test setindex!(ra,(2,1),1,1) == 
    [(2, 1) (5,6) (9,10) (13,14)
     (3,4) (7,8) (11,12) (15,16)]

    @test setindex!(ra,(2,1),2,4) == 
    [(2, 1) (5,6) (9,10) (13,14)
     (3,4) (7,8) (11,12) (2,1)]


    @test_throws BoundsError getindex(ra,3,4)
    @test_throws BoundsError setindex!(ra,(1,1),2,5)
end

struct Vec3D{T<:Number}
    x::T
    y::T
    z::T
end

@testset "Unidimensional Vector of struct Vec3D" begin

    a = [1., 2., 3., 4., 5., 6., 7., 8., 9.]
    @inferred struct_reinterpret(Vec3D{Float64},a)
    ra = struct_reinterpret(Vec3D{Float64},a)

    @test size(ra) === (3,)

    @test ra[1] === Vec3D{Float64}(1.,2.,3.)
    @test ra[2] === Vec3D{Float64}(4.,5.,6.)

    @test setindex!(ra,Vec3D{Float64}(3,2,1),1) == [Vec3D{Float64}(3.,2.,1.),Vec3D{Float64}(4.,5.,6.),Vec3D{Float64}(7.,8.,9.)]

    @test setindex!(ra,Vec3D{Float64}(3,2,1),2) == [Vec3D{Float64}(3.,2.,1.),Vec3D{Float64}(3.,2.,1.),Vec3D{Float64}(7.,8.,9.)]

    @test_throws BoundsError getindex(ra,4)
    @test_throws BoundsError setindex!(ra,Vec3D{Float64}(1.,1.,1.),4)

end

struct Vec2D{T<:Number}
    x::T
    y::T
end

@testset "2D Array of Vec2D" begin

    a = [1 5 9 13
         2 6 10 14
         3 7 11 15
         4 8 12 16]
    @inferred struct_reinterpret(Vec2D{Int},a)
    ra = struct_reinterpret(Vec2D{Int},a)

    @test size(ra) === (2,4)

    @test ra[1,1] === Vec2D{Int}(1,2)
    @test ra[2,1] === Vec2D{Int}(3,4)
    @test ra[2,4] === Vec2D{Int}(15,16)

    @test setindex!(ra,Vec2D{Int}(2,1),1,1) == 
    [Vec2D{Int}(2, 1) Vec2D{Int}(5,6) Vec2D{Int}(9,10) Vec2D{Int}(13,14)
     Vec2D{Int}(3,4) Vec2D{Int}(7,8) Vec2D{Int}(11,12) Vec2D{Int}(15,16)]

    @test setindex!(ra,Vec2D{Int}(2,1),2,4) == 
    [Vec2D{Int}(2, 1) Vec2D{Int}(5,6) Vec2D{Int}(9,10) Vec2D{Int}(13,14)
     Vec2D{Int}(3,4) Vec2D{Int}(7,8) Vec2D{Int}(11,12) Vec2D{Int}(2,1)]


    @test_throws BoundsError getindex(ra,3,4)
    @test_throws BoundsError setindex!(ra,Vec2D{Int}(1,1),2,5)
end

struct TupleWrapper{N,T}
    x::NTuple{N,T}
end

TupleWrapper{N,T}(e::Vararg{T,N}) where {N,T} = TupleWrapper{N,T}(e)

@testset "Unidimensional Vector of TupleWrapper" begin

    a = [1., 2., 3., 4., 5., 6., 7., 8., 9.]
    @inferred struct_reinterpret(TupleWrapper{3,Float64},a)
    ra = struct_reinterpret(TupleWrapper{3,Float64},a)

    @test size(ra) === (3,)

    @test ra[1] === TupleWrapper{3,Float64}(1.,2.,3.)
    @test ra[2] === TupleWrapper{3,Float64}(4.,5.,6.)

    @test setindex!(ra,TupleWrapper{3,Float64}(3.,2.,1.),1) == [TupleWrapper{3,Float64}(3.,2.,1.),TupleWrapper{3,Float64}(4.,5.,6.),TupleWrapper{3,Float64}(7.,8.,9.)]

    @test setindex!(ra,TupleWrapper{3,Float64}(3.,2.,1.),2) == [TupleWrapper{3,Float64}(3.,2.,1.),TupleWrapper{3,Float64}(3.,2.,1.),TupleWrapper{3,Float64}(7.,8.,9.)]

    @test_throws BoundsError getindex(ra,4)
    @test_throws BoundsError setindex!(ra,TupleWrapper{3,Float64}(1.,1.,1.),4)

end

@testset "2D Array of TupleWrapper" begin

    a = [1 5 9 13
         2 6 10 14
         3 7 11 15
         4 8 12 16]
    @inferred struct_reinterpret(TupleWrapper{2,Int},a)
    ra = struct_reinterpret(TupleWrapper{2,Int},a)

    @test size(ra) === (2,4)

    @test ra[1,1] === TupleWrapper{2,Int}(1,2)
    @test ra[2,1] === TupleWrapper{2,Int}(3,4)
    @test ra[2,4] === TupleWrapper{2,Int}(15,16)

    @test setindex!(ra,TupleWrapper{2,Int}(2,1),1,1) == 
    [TupleWrapper{2,Int}(2, 1) TupleWrapper{2,Int}(5,6) TupleWrapper{2,Int}(9,10) TupleWrapper{2,Int}(13,14)
     TupleWrapper{2,Int}(3,4) TupleWrapper{2,Int}(7,8) TupleWrapper{2,Int}(11,12) TupleWrapper{2,Int}(15,16)]

    @test setindex!(ra,TupleWrapper{2,Int}(2,1),2,4) == 
    [TupleWrapper{2,Int}(2, 1) TupleWrapper{2,Int}(5,6) TupleWrapper{2,Int}(9,10) TupleWrapper{2,Int}(13,14)
     TupleWrapper{2,Int}(3,4) TupleWrapper{2,Int}(7,8) TupleWrapper{2,Int}(11,12) TupleWrapper{2,Int}(2,1)]


    @test_throws BoundsError getindex(ra,3,4)
    @test_throws BoundsError setindex!(ra,TupleWrapper{2,Int}(1,1),2,5)
end

@testset "Argument Errors" begin
    a = rand(10)

    @test_throws ArgumentError struct_reinterpret(NTuple{3,Float64},a)

    @test_throws ArgumentError struct_reinterpret(NTuple{2,Int},a)

    @test_throws ArgumentError struct_reinterpret(Tuple{Int,Float64},a)

    @test_throws ArgumentError struct_reinterpret(Float64,a)
end