struct StructReinterpretArray{StructType,N,ArrayType<:AbstractArray} <: AbstractArray{StructType,N}
    parent::ArrayType
    function StructReinterpretArray(::Type{ST},data::AbstractArray{T,N}) where {ST,T,N}
        NF = check_parent_and_struct_match(ST,T)
        dim = size(data,1)
        dim % NF == 0 || throw(ArgumentError("""
        cannot reinterpret an `$(T)` array to `$(ST)` whose first dimension has size `$(dim)`.
        The resulting array would have non-integral first dimension.
        """))
        return new{ST,N,typeof(data)}(data)
    end
end

struct StructReinterpretDenseArray{StructType,N,ArrayType<:DenseArray} <: DenseArray{StructType,N}
    parent::ArrayType
    function StructReinterpretDenseArray(::Type{ST},data::DenseArray{T,N}) where {ST,T,N}
        NF = check_parent_and_struct_match(ST,T)
        dim = size(data,1)
        dim % NF == 0 || throw(ArgumentError("""
        cannot reinterpret an `$(T)` array to `$(ST)` whose first dimension has size `$(dim)`.
        The resulting array would have non-integral first dimension.
        """))
        return new{ST,N,typeof(data)}(data)
    end
end

const AbstractReinterpretArray{ST,N,AT} = Union{<:StructReinterpretArray{ST,N,AT},<:StructReinterpretDenseArray{ST,N,AT}}