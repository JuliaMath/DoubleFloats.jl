"""
    DoubleFloats.simdmap!(f, dest, x[, y]; threaded=false)

Apply a scalar operation elementwise into `dest` and return it. All vector
operands must have the same axes as `dest`. For power, `y` may also be a
scalar exponent. Tuple results occupy one destination element.
Dense vectors may use specialized kernels with their own rounding.

Overlapping inputs are read from snapshots of their values at entry. By default,
a scalar error leaves the preceding writes in index order. With
`threaded=true`, supported operations on sufficiently large, disjoint dense
vectors can run in parallel. A failing task may leave writes in other chunks.
"""
@inline simdmap!(f::F, dest::AbstractVector, x::AbstractVector; threaded::Bool = false) where {F} =
    _simdmap!(f, dest, (x,), threaded)
@inline simdmap!(f::F, dest::AbstractVector, x::AbstractVector, y::AbstractVector; threaded::Bool = false) where {F} =
    _simdmap!(f, dest, (x, y), threaded)
@inline simdmap!(f::typeof(^), dest::AbstractVector, x::AbstractVector, y::Number; threaded::Bool = false) =
    _simdmap!(f, dest, (x, y), threaded)

# Base.mightalias is useful for ordinary arrays and views. Snapshot unknown
# storage even when its default dataids would claim it is disjoint.
_batch_parent(x) = nothing
_batch_parent(x::Vector) = x
_batch_parent(x::SubArray) = _batch_parent(parent(x))

_batch_overlaps(dest, x::Number) = false

function _batch_overlaps(dest, x::AbstractVector)
    d, a = _batch_parent(dest), _batch_parent(x)
    (d === nothing || a === nothing) && return true
    Base.mightalias(dest, x) && return true
    # Independently wrapped array headers can also cover overlapping buffers.
    (isempty(d) || isempty(a)) && return false
    GC.@preserve d a begin
        p, q = UInt(pointer(d)), UInt(pointer(a))
        return p <= q ? q - p < length(d) * Base.elsize(d) : p - q < length(a) * Base.elsize(a)
    end
end

struct _BatchSnapshot{V,I}
    values::V
    first_index::I
end

_batch_arg(x::Number, i) = x
Base.@propagate_inbounds _batch_arg(x::AbstractVector, i) = x[i]
_batch_arg(x::_BatchSnapshot, i) = x.values[i - x.first_index + 1]
_batch_argtype(x::Number) = typeof(x)
_batch_argtype(x::AbstractVector) = eltype(x)

_batch_source(dest, x::Number) = x
function _batch_source(dest, x::AbstractVector)
    _batch_overlaps(dest, x) || return x
    values = Vector{eltype(x)}(undef, length(x))
    for (j, i) in enumerate(axes(x, 1))
        values[j] = x[i]
    end
    return _BatchSnapshot(values, firstindex(x))
end

@inline function _batch_scalar!(f::F, dest, args, indices) where {F}
    for i in indices
        dest[i] = f(map(x -> _batch_arg(x, i), args)...)
    end
    return dest
end

# Only called with dense vector arguments after their axes are checked.
@inline _batch_eligible(k, args::Tuple{Any}, i) = @inbounds k.eligible(_batch_arg(args[1], i))
@inline _batch_eligible(k, args::Tuple{Any,Any}, i) =
    @inbounds k.eligible(_batch_arg(args[1], i), _batch_arg(args[2], i))
@inline _batch_value(k, args::Tuple{Any}, i) = @inbounds k.evaluate(_batch_arg(args[1], i))
@inline _batch_value(k, args::Tuple{Any,Any}, i) = @inbounds k.evaluate(_batch_arg(args[1], i), _batch_arg(args[2], i))

@noinline function _batch_native!(k::_BatchKernel, dest, args, indices)
    @inbounds @simd ivdep for i in indices
        dest[i] = _batch_value(k, args, i)
    end
    return dest
end

@inline _batch_select(k::_BatchKernel, args, block) = all(i -> _batch_eligible(k, args, i), block) ? k : nothing

@inline function _batch_select(k::Tuple{_BatchKernel,_BatchKernel}, args, block)
    # Pick a regime from the first lane, then check the rest once.
    i = first(block)
    first_kernel, second_kernel = k
    if _batch_eligible(first_kernel, args, i)
        return _batch_select(first_kernel, args, (i + 1):last(block))
    elseif _batch_eligible(second_kernel, args, i)
        return _batch_select(second_kernel, args, (i + 1):last(block))
    end
    return nothing
end

function _batch_blocks!(kernels, f::F, dest, args, indices) where {F}
    length(indices) < _BATCH_BLOCK && return _batch_scalar!(f, dest, args, indices)
    width = _batch_width(kernels)
    for start in first(indices):width:last(indices)
        block = start:min(start + width - 1, last(indices))
        _batch_block!(kernels, f, dest, args, block)
    end
    return dest
end

@inline function _batch_block!(kernels, f::F, dest, args, block) where {F}
    kernel = _batch_select(kernels, args, block)
    return _batch_apply!(kernel, f, dest, args, block)
end

@inline _batch_apply!(k::_BatchKernel, f, dest, args, block) = _batch_native!(k, dest, args, block)
@inline _batch_apply!(::Nothing, f::F, dest, args, block) where {F} = _batch_scalar!(f, dest, args, block)

@inline function _batch_block!(repair::_BatchRepair, f::F, dest, args, block) where {F}
    _batch_try_block!(repair, f, dest, args, block) && return dest
    return _batch_scalar!(f, dest, args, block)
end

@inline function _batch_block!(k::_BatchAlternatives, f::F, dest, args, block) where {F}
    _batch_try_block!(k.preferred, f, dest, args, block) && return dest
    return _batch_block!(k.secondary, f, dest, args, block)
end

# These probes either write the whole block or leave the destination alone.
@inline function _batch_try_block!(k::_BatchKernel, f, dest, args, block)
    _batch_select(k, args, block) === nothing && return false
    _batch_native!(k, dest, args, block)
    return true
end

@inline function _batch_try_block!(repair::_BatchRepair, f::F, dest, args, block) where {F}
    k = repair.kernel
    x = only(args)
    first_rejected = findfirst(i -> !_batch_eligible(k, args, i), block)
    if first_rejected === nothing
        _batch_native!(k, dest, args, block)
        return true
    end
    # For the operations that opt in, normalized finite values in this
    # wider interval have a nonthrowing scalar path and a compatible result.
    max_rejected = length(block) ÷ 8
    nrejected = 0
    rejected = UInt64(0)
    @inbounds for j in first_rejected:length(block)
        lane = x[block[j]]
        if j == first_rejected || !k.eligible(lane)
            nrejected += 1
            if nrejected > max_rejected || !_batch_bounded(lane, -128.0, 128.0)
                return false
            end
            rejected |= UInt64(1) << (j - 1)
        end
    end
    _batch_masked!(k, dest, x, block, rejected, repair.placeholder)
    @inbounds while !iszero(rejected)
        i = first(block) + trailing_zeros(rejected)
        dest[i] = f(x[i])
        rejected &= rejected - UInt64(1)
    end
    return true
end

@noinline function _batch_masked!(k::_BatchKernel, dest, x, block, rejected, placeholder)
    start = first(block)
    @inbounds @simd ivdep for i in block
        replace = isodd(rejected >> (i - start))
        h, l = HILO(x[i])
        lane = unsafe_double(Float64, ifelse(replace, HI(placeholder), h), ifelse(replace, LO(placeholder), l))
        dest[i] = k.evaluate(lane)
    end
    return dest
end

_batch_blocks!(::Nothing, f::F, dest, args, indices) where {F} = _batch_scalar!(f, dest, args, indices)

const _BatchReal = Union{Double64,Double32,Double16}
const _BatchComplex = Union{ComplexDF64,ComplexDF32,ComplexDF16}
const _BatchUnary = Union{
    typeof.((
        exp2,
        exp,
        exp10,
        expm1,
        log2,
        log,
        log10,
        log1p,
        sin,
        cos,
        tan,
        cot,
        sincos,
        cis,
        sinpi,
        cospi,
        tanpi,
        sincospi,
        cispi,
        atan,
        asin,
        acos,
        acsc,
        asec,
        acot,
        sinh,
        cosh,
        tanh,
        csch,
        sech,
        coth,
        asinh,
        acosh,
        atanh,
        acsch,
        asech,
        acoth,
        sqrt,
        square,
        abs2,
        csc,
        sec,
    ))...,
}

_batch_thread_min(f, types...) = typemax(Int)
_batch_thread_min(::_BatchUnary, ::Type{<:Union{_BatchReal,_BatchComplex}}) = 4096
_batch_thread_min(::Union{typeof(atan),typeof(atanxy)}, ::Type{T}, ::Type{T}) where {T<:_BatchReal} = 4096
_batch_thread_min(::typeof(^), ::Type{T}, ::Type{T}) where {T<:_BatchReal} = 4096
_batch_thread_min(::typeof(^), ::Type{<:_BatchReal}, ::Type{Int}) = 65536
_batch_thread_min(::typeof(inv), ::Type{Double64}) = 65536
_batch_thread_min(::Union{typeof(hypot),typeof(normalize)}, ::Type{Double64}, ::Type{Double64}) = 16384

@inline function _batch_dense!(f::F, dest, args, threaded) where {F}
    types = map(_batch_argtype, args)
    kernel = _batch_kernel(f, eltype(dest), map(x -> x isa Number ? x : eltype(x), args)...)
    n = length(dest)
    workers = Threads.nthreads()
    if threaded &&
       workers > 1 &&
       _batch_thread_output(eltype(dest), first(types)) &&
       n >= _batch_thread_min(f, types...)
        return _batch_threaded!(kernel, f, dest, args, n, workers)
    end
    return _batch_blocks!(kernel, f, dest, args, 1:n)
end

_batch_thread_output(R, X) = false
_batch_thread_output(R, ::Type{T}) where {T<:_BatchReal} = R === T || R === Complex{T} || R === Tuple{T,T}
_batch_thread_output(R, ::Type{Complex{T}}) where {T<:_BatchReal} = R === T || R === Complex{T}

@noinline function _batch_threaded!(kernel, f::F, dest, args, n, workers) where {F}
    chunks = min(workers, cld(n, _BATCH_BLOCK))
    width, extra = divrem(n, chunks)
    # :dynamic admits callers on worker threads. The chunk boundaries
    # are independent of which Julia task executes the chunk.
    Threads.@threads :dynamic for chunk in 1:chunks
        lo = (chunk - 1) * width + min(chunk - 1, extra) + 1
        hi = chunk * width + min(chunk, extra)
        _batch_blocks!(kernel, f, dest, args, lo:hi)
    end
    return dest
end

_batch_same_axis(axis, x::Number) = true
_batch_same_axis(axis, x::AbstractVector) = axes(x, 1) == axis

@inline function _simdmap!(f::F, dest, args, threaded) where {F}
    axis = axes(dest, 1)
    all(x -> _batch_same_axis(axis, x), args) || throw(DimensionMismatch("all vector axes must match the destination"))
    isempty(dest) && return dest
    if dest isa Vector &&
       isbitstype(eltype(dest)) &&
       all(x -> x isa Union{Vector,Number}, args) &&
       all(x -> !_batch_overlaps(dest, x), args)
        return _batch_dense!(f, dest, args, threaded)
    end
    sources = map(x -> _batch_source(dest, x), args)
    return _batch_scalar!(f, dest, sources, axis)
end
