"""
    *(a, b)

A more performant version of `a * b` where a, b are matrices
"""
function Base.:(*)(a::Array{DoubleFloat{T},2}, b::Array{DoubleFloat{T},2}) where {T<:AbstractFloat}
    if isempty(a) || isempty(b)
        throw(ErrorException("cannot multiply empty matrices"))
    end
    arows, acols = size(a)
    brows, bcols = size(b)
    if  acols != brows || arows != bcols
        throw(ErrorException(string("size(a) != size(b'): ",size(a), " != ", size(b'))))
    end
    
    result_rows, result_cols = arows, bcols  
    result = reshape(Array{DoubleFloat{T}, 1}(undef, result_rows*result_cols), (result_rows, result_cols))

    for bcol = 1:bcols
        for arow=1:arows
            asum = zero(DoubleFloat{T})
            for acol=1:acols
                @inbounds asum = fma(a[arow,acol], b[acol,bcol], asum)
            end
            @inbounds result[arow,bcol] = asum
        end
    end

    return result
end


function Base.:(*)(a::Array{DoubleFloat{T},2}, b::Array{T,2}) where {T<:AbstractFloat}
    if isempty(a) || isempty(b)
        throw(ErrorException("cannot multiply empty matrices"))
    end
    arows, acols = size(a)
    brows, bcols = size(b)
    if  acols != brows || arows != bcols
        throw(ErrorException(string("size(a) != size(b'): ",size(a), " != ", size(b'))))
    end
    
    result_rows, result_cols = arows, bcols  
    result = reshape(Array{DoubleFloat{T}, 1}(undef, result_rows*result_cols), (result_rows, result_cols))

    for bcol = 1:bcols
        for arow=1:arows
            asum = zero(DoubleFloat{T})
            for acol=1:acols
                @inbounds asum = fma(a[arow,acol], b[acol,bcol], asum)
            end
            @inbounds result[arow,bcol] = asum
        end
    end

    return result
end


function Base.:(*)(a::Array{T,2}, b::Array{DoubleFloat{T},2}) where {T<:AbstractFloat}
    if isempty(a) || isempty(b)
        throw(ErrorException("cannot multiply empty matrices"))
    end
    arows, acols = size(a)
    brows, bcols = size(b)
    if  acols != brows || arows != bcols
        throw(ErrorException(string("size(a) != size(b'): ",size(a), " != ", size(b'))))
    end
    
    result_rows, result_cols = arows, bcols  
    result = reshape(Array{DoubleFloat{T}, 1}(undef, result_rows*result_cols), (result_rows, result_cols))
   
    aa = DoubleFloat{T}.(a)
    for bcol = 1:bcols
        for arow=1:arows
            asum = zero(DoubleFloat{T})
            for acol=1:acols
                @inbounds asum = fma(aa[arow,acol], b[acol,bcol], asum)
            end
            @inbounds result[arow,bcol] = asum
        end
    end

    return result
end


