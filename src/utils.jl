function all_same_type(::Type{T}) where T
    r = Vector{Any}()
    for s in fieldnames(T)
        push!(r,fieldtype(T,s))
    end
    re = all(y->y===r[1],r)
    return re
end

function is_tuple_wrapper(::Type{ST}) where ST
    return fieldcount(ST) == 1 && fieldtype(ST,1) <: NTuple
end

@generated function check_parent_and_struct_match(::Type{ST},::Type{T}) where {ST,T}

    t = ST
    allsame = false
    isstruct = false
    NF = 1
    if fieldcount(ST) != 0 
        isstruct = true
        if is_tuple_wrapper(ST)
            IST = fieldtype(ST,1)
            NF = fieldcount(IST)
            t = fieldtype(IST,1)
            allsame = all_same_type(IST)
        else
            NF = fieldcount(ST)
            t = fieldtype(ST,1)
            allsame = all_same_type(ST)
        end
    end

    correctArrayType = t === T

    return quote
        $isstruct || throw(ArgumentError("Type $ST is not supported, only composite types."))

        $allsame || throw(ArgumentError("Struct $ST not supported. All struct elements must have the same type."))

        $correctArrayType || throw(ArgumentError("Array type does not match struct fields type."))

        return $NF
    end
end

myfieldcount(::Type{ST}) where {ST} = is_tuple_wrapper(ST) ? fieldcount(fieldtype(ST,1)) : fieldcount(ST)
