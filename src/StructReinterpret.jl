module StructReinterpret

export struct_reinterpret, reinterpreted_getindex, reinterpreted_setindex!

include("utils.jl")
include("types.jl")


"""
    struct_reinterpret(::Type{StructType}, A::AbstractArray{T,N})

Returns an array of StructType's formed by contiguous values of A.
StructType must be a composite type whose fields are all of the same type of T.
The resulting array has the same values as that returned by `reinterpret`, but provides a faster `getindex` method. 

# Examples
```jldoctest
julia> struct_reinterpret(NTuple{2,Int}, [1, 2, 3, 4, 5, 6])
3-element StructReinterpret.StructReinterpretArray{Tuple{Int64,Int64},1,Array{Int64,1}}:
 (1, 2)
 (3, 4)
 (5, 6)
```
"""
struct_reinterpret(T::Type,data::AbstractArray) = StructReinterpretArray(T,data)
struct_reinterpret(T::Type,data::DenseArray) = StructReinterpretDenseArray(T,data)


@generated function Base.size(a::AbstractReinterpretArray{ST,N,AT}) where {ST,N,AT}
    NF = myfieldcount(ST)
    ex = quote data = a.parent end
    t = Expr(:tuple)
    push!(t.args,:(div(size(data,1),$NF)))
    for i = 2:N
        push!(t.args,:(size(data,$i)))
    end
    push!(ex.args,t)
    return ex
end

Base.IndexStyle(::Type{<:AbstractReinterpretArray{ST,N,AT}}) where {ST,N,AT} = IndexStyle(AT)

@generated function reinterpreted_getindex(::Type{ST}, data::AbstractArray{T,N},i::Int) where {ST,T,N}
    NF = myfieldcount(ST)
    ex = Expr(:block)
    exarg = ex.args
    push!(exarg,Expr(:meta,:inline))
    push!(exarg,:(I=$NF*i))
    push!(exarg,:(@boundscheck checkbounds(data,I)))
    element = Expr(:new,ST)
    if is_tuple_wrapper(ST)
        push!(element.args,Expr(:tuple))
        struct_args = element.args[2].args
    else
        struct_args = element.args
    end
    for j in 1:(NF-1)
        push!(struct_args,:(@inbounds data[I-$(NF-j)]))
    end
    push!(struct_args,:(@inbounds data[I]))
 
    push!(exarg, element)
    return ex
end

@inline Base.@propagate_inbounds function Base.getindex(a::AbstractReinterpretArray{ST,N,AT}, i::Int) where {ST,N,AT}
    data = a.parent
    return reinterpreted_getindex(ST,data,i)
end

@generated function reinterpreted_getindex(::Type{ST}, data::AbstractArray{T,N},i::Vararg{Int,N}) where {ST,T,N}
    NF = myfieldcount(ST)
    ex = Expr(:block)
    exarg = ex.args
    push!(exarg,Expr(:meta,:inline))
    push!(exarg,:(I=$NF*i[1]))
    rest_of_indices = Vector{Any}()
    for j = 2:N
        push!(rest_of_indices,:(i[$j]))
    end
    push!(exarg,:(@boundscheck $(Expr(:call,:checkbounds,:data,:I,rest_of_indices...))))
    element = Expr(:new,ST)
    if is_tuple_wrapper(ST)
        push!(element.args,Expr(:tuple))
        struct_args = element.args[2].args
    else
        struct_args = element.args
    end
    for j in 1:(NF-1)
        push!(struct_args,:(@inbounds $(Expr(:call, :getindex, :data, :(I-$(NF-j)), rest_of_indices...))))
    end
    push!(struct_args,:(@inbounds $(Expr(:call, :getindex, :data, :I, rest_of_indices...))))
 
    push!(exarg, element)
    return ex
end

@inline Base.@propagate_inbounds function Base.getindex(a::AbstractReinterpretArray{ST,N,AT}, i::Vararg{Int,N}) where {ST,N,AT}
    data = a.parent
    return reinterpreted_getindex(ST,data,i...)
end

@generated function reinterpreted_setindex!(data::AbstractArray{T,N},::Type{ST},val,i::Int) where {ST,T,N}
    NF = myfieldcount(ST)
    ex = quote
        $(Expr(:meta,:inline))
        I=$NF*i
        @boundscheck checkbounds(data,I)
    end
    exarg = ex.args

    push!(exarg, is_tuple_wrapper(ST) ? :(val2 = getfield(convert($ST,val),1)) : :(val2 = convert($ST,val)))

    for j in 1:(NF-1)
        push!(exarg,:(@inbounds $(Expr(:call,:setindex!, :data, :(getfield(val2,$j)), :(I-$(NF-j))))))
    end
    push!(exarg,:(@inbounds $(Expr(:call,:setindex!, :data, :(getfield(val2,$NF)), :I))))
 
    return ex
end

@inline Base.@propagate_inbounds function Base.setindex!(a::AbstractReinterpretArray{ST,N,AT}, v,i::Int) where {ST,N,AT}
    data = a.parent
    reinterpreted_setindex!(data,ST,v,i)
    return a
end

@generated function reinterpreted_setindex!(data::AbstractArray{T,N},::Type{ST},val::VT,i::Vararg{Int,N}) where {ST,T,N,VT}
    NF = myfieldcount(ST)
    rest_of_indices = Vector{Any}()

    for j = 2:N
        push!(rest_of_indices,:(i[$j]))
    end

    ex = quote
        $(Expr(:meta,:inline))
        I=$NF*i[1]
        @boundscheck $(Expr(:call,:checkbounds,:data,:I,rest_of_indices...))
    end
    exarg = ex.args

    push!(exarg, is_tuple_wrapper(ST) ? :(val2 = getfield(convert($ST,val),1)) : :(val2 = convert($ST,val)))

    for j in 1:(NF-1)
        push!(exarg,:(@inbounds $(Expr(:call,:setindex!, :data, :(getfield(val2,$j)), :(I-$(NF-j)),rest_of_indices...))))
    end
    push!(exarg,:(@inbounds $(Expr(:call,:setindex!, :data, :(getfield(val2,$NF)), :I,rest_of_indices...))))
 
    return ex
end

@inline Base.@propagate_inbounds function Base.setindex!(a::AbstractReinterpretArray{ST,N,AT}, v,i::Vararg{Int,N}) where {ST,N,AT}
    data = a.parent
    reinterpreted_setindex!(data,ST,v,i...)
    return a
end

Base.unsafe_convert(::Type{Ptr{T}}, a::StructReinterpretDenseArray{T,N,A} where N) where {T,A} = Ptr{T}(pointer(a.parent))

end # module
