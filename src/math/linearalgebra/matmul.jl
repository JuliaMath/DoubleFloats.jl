"""
    mul!(c, a, b)

A more performant version of `c = a * b` where a, b, c are matrices
"""
function LinearAlgebra.mul!(c::Array{DoubleFloat{T},2}, a::Array{DoubleFloat{T},2}, b::Array{DoubleFloat{T},2}) where {T<:AbstractFloat}
    arows, acols = size(a)
    brows, bcols = size(b)
    if  acols != brows
        throw(DimensionMismatch(string("size(a,1) != size(b,2): ",size(a,1), " != ", size(b,2))))
    end
    if size(c,1) != arows || size(c,2) != bcols
        throw(DimensionMismatch("result c has dimensions $(size(c)), needs ($arows,$bcols)"))
    end

    @inbounds for bcol = 1:bcols
        for arow=1:arows
            asum = zero(DoubleFloat{T})
            for acol=1:acols
                @inbounds asum = fma(a[arow,acol], b[acol,bcol], asum)
            end
            @inbounds c[arow,bcol] = asum
        end
    end

    return c
end


function LinearAlgebra.mul!(c::Array{DoubleFloat{T},2}, a::Array{DoubleFloat{T},2}, b::Array{T,2}) where {T<:AbstractFloat}
    arows, acols = size(a)
    brows, bcols = size(b)
    if  acols != brows
        throw(DimensionMismatch(string("size(a,1) != size(b,2): ",size(a,1), " != ", size(b,2))))
    end
    if size(c,1) != arows || size(c,2) != bcols
        throw(DimensionMismatch("result c has dimensions $(size(c)), needs ($arows,$bcols)"))
    end

    @inbounds for bcol = 1:bcols
        for arow=1:arows
            asum = zero(DoubleFloat{T})
            for acol=1:acols
                @inbounds asum = fma(a[arow,acol], b[acol,bcol], asum)
            end
            @inbounds c[arow,bcol] = asum
        end
    end

    return c
end


function LinearAlgebra.mul!(c::Array{DoubleFloat{T},2}, a::Array{T,2}, b::Array{DoubleFloat{T},2}) where {T<:AbstractFloat}
    arows, acols = size(a)
    brows, bcols = size(b)
    if  acols != brows
        throw(DimensionMismatch(string("size(a,1) != size(b,2): ",size(a,1), " != ", size(b,2))))
    end
    if size(c,1) != arows || size(c,2) != bcols
        throw(DimensionMismatch("result c has dimensions $(size(c)), needs ($arows,$bcols)"))
    end

    @inbounds for bcol = 1:bcols
        for arow=1:arows
            asum = zero(DoubleFloat{T})
            for acol=1:acols
                @inbounds asum = fma(a[arow,acol], b[acol,bcol], asum)
            end
            @inbounds c[arow,bcol] = asum
        end
    end

    return c
end
