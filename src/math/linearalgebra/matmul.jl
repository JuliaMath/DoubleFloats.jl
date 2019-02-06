"""
    *(a, b)

A more performant version of `a * b` where a, b are matrices
"""
function Base.:(*)(a::Array{DoubleFloat{T},2}, b::Array{DoubleFloat{T},2}) where {T<:AbstractFloat}
    arows, acols = size(a)
    brows, bcols = size(b)
    if  acols != brows
        throw(DimensionMismatch(string("size(a,1) != size(b,2): ",size(a,1), " != ", size(b,2))))
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
    arows, acols = size(a)
    brows, bcols = size(b)
    if  acols != brows
        throw(DimensionMismatch(string("size(a,1) != size(b,2): ",size(a,1), " != ", size(b,2))))
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
    arows, acols = size(a)
    brows, bcols = size(b)
    if  acols != brows
        throw(DimensionMismatch(string("size(a,1) != size(b,2): ",size(a,1), " != ", size(b,2))))
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
