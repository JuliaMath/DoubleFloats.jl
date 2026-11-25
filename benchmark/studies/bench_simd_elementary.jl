# Run from the package root with julia --project -t4 benchmark/studies/bench_simd_elementary.jl.
using DoubleFloats, InteractiveUtils, Random, Printf, Statistics

const DF = DoubleFloats
const SEED = 0x5eed
const REAL_TRIG = (sin, cos, tan, cot, sincos, cis, sinpi, cospi, tanpi, sincospi, cispi)
const REAL_ATAN = (atan, asin, acos, acsc, asec, acot)
const HYP = (sinh, cosh, tanh, csch, sech, coth)
const INVHYP = (asinh, acosh, atanh, acsch, asech, acoth)
const EXPLOG = (exp2, exp, exp10, expm1, log2, log, log10, log1p)
const COMPLEX = (square, abs2, exp, sin, cos, sinh, cosh, tan, cot, DF.csc, DF.sec,
                 tanh, coth, csch, sech, sqrt, log, REAL_ATAN..., INVHYP...)

function sample(rng, interval, n, ::Type{D}=Double64) where {D}
    a, b = interval
    T = typeof(HI(one(D)))
    return map(rand(rng, n)) do t
        h = T(a + (b - a) * t)
        D(h, (rand(rng, T) - T(0.5)) * eps(h))
    end
end

function fixtures(n; bounded=true, mixture=0.0, clustered=false, filter=r"",
                  log_regimes="")
    rng = MersenneTwister(SEED)
    cases = NamedTuple[]
    function add(f, ranges...; scalar=nothing, label=string(f), wide=(0.25, 20.0),
                 rejected=wide, input_type=Double64)
        occursin(filter, label) || return
        args = if length(ranges) == 1
            x = sample(rng, bounded ? only(ranges) : wide, n, input_type)
            (x,)
        else
            map(r -> sample(rng, r, n), ranges)
        end
        if bounded && mixture > 0
            count = round(Int, n * mixture)
            indices = clustered ? (1:count) : randperm(rng, n)[1:count]
            if label == "^/Double64 vector"
                args[2][indices] = Double64.(rand(rng, 0:3, count))
            elseif input_type === Double32
                for i in indices
                    h, l = HILO(args[1][i])
                    args[1][i] = Double32(h, copysign(Float32(0x1p-90), l))
                end
            else
                args[1][indices] = sample(rng, rejected, count)
            end
        end
        observed_ranges = !bounded && length(ranges) == 1 ? (wide,) : ranges
        push!(cases, (; label, f, ranges=observed_ranges, args=scalar === nothing ? args : (args..., scalar)))
    end
    for f in REAL_TRIG
        add(f, (0.005, 0.09); wide=(-100.0, 100.0), rejected=(0.1, 100.0))
    end
    for f in (sin, cos, sincos, tan, cis)
        add(f, (-6.25, 6.25); label="$(f)/circle", wide=(-6.25, 6.25), rejected=(7.0, 8.0))
        if bounded
            add(f, (0.125, 0.18); label="$(f)/sector", rejected=(7.0, 8.0))
        end
    end
    for f in REAL_ATAN
        add(f, f in (acsc, asec) ? (1.1, 4.0) : (0.005, 0.19);
            wide=f in (asin, acos) ? (-0.99, 0.99) : f in (acsc, asec) ? (1.01, 100.0) : (-100.0, 100.0))
    end
    for f in (atan, DF.atanxy)
        add(f, (-100.0, 100.0), (-100.0, 100.0); label="$(f)/2", rejected=(30.0, 100.0))
    end
    for f in HYP
        add(f, (1.1, 5.0); wide=(-20.0, 20.0), rejected=(5.01, 20.0))
    end
    for (f, interval, wide) in zip(INVHYP,
            ((0.005, 0.045), (1.00002, 1.001), (0.005, 0.025), (30.0, 50.0),
             (0.999, 0.99998), (40.0, 100.0)),
            ((-100.0, 100.0), (1.0, 100.0), (-0.99, 0.99), (0.1, 100.0),
             (0.01, 1.0), (1.01, 100.0)))
        add(f, interval; wide)
    end
    add(expm1, (0.5, 1.0); label="expm1/central", wide=(-1.0, 1.0), rejected=(1.01, 2.0))
    for f in EXPLOG
        interval = f === expm1 ? (0.032, 0.06) : f === log1p ? (0.005, 0.05) :
                   f in (log, log2, log10) ? (0.95, 1.05) : (0.55, 16.0)
        rejected = f === expm1 ? (0.07, 0.4) : f === log1p ? (0.07, 1.0) :
                   f === exp2 ? (0.00005, 0.0005) :
                   f in (log, log2, log10) ? (0x1p-950, 0x1p-925) :
                   f === exp ? (701.0, 708.0) : (301.0, 307.0)
        add(f, interval; wide=f in (exp, exp2, exp10, expm1) ? (-100.0, 100.0) : (0.01, 100.0),
            rejected)
    end
    for f in (hypot, DF.normalize)
        add(f, (0.25, 8.0), (0.25, 8.0); rejected=(9.0, 12.0))
    end
    add(inv, (0.25, 8.0); wide=(-128.0, 128.0), rejected=(0x1p257, 0x1p260))
    add(^, (0.5, 1.5); scalar=5, label="^/fixed 5")
    if occursin(filter, "^/Int vector")
        push!(cases, (; label="^/Int vector", f=^, ranges=((0.5, 1.5), (-9, 9)),
                      args=(sample(rng, (0.5, 1.5), n), rand(rng, -9:9, n))))
    end
    if bounded
        add(^, (1.1, 1.5), (0.2, 0.9); label="^/Double64 vector")
    else
        add(^, (0.25, 10.0), (-4.0, 4.0); label="^/Double64 vector")
    end
    for f in COMPLEX
        label = "complex/$(f)"
        occursin(filter, label) || continue
        r, i = if f in (sin, cos)
            (0.005, 0.09), (1.1, 5.0)
        elseif f in (tan, cot, DF.csc, DF.sec)
            (0.005, 0.045), (1.1, 5.0)
        elseif f in (tanh, coth, csch, sech)
            (1.1, 5.0), (0.005, 0.045)
        else
            (1.1, 5.0), (0.005, 0.09)
        end
        wide = (-4.0, 4.0)
        x = complex.(sample(rng, bounded ? r : wide, n), sample(rng, bounded ? i : wide, n))
        if bounded && mixture > 0
            count = round(Int, n * mixture)
            indices = clustered ? (1:count) : randperm(rng, n)[1:count]
            x[indices] = complex.(sample(rng, (-4.0, -0.1), count), sample(rng, wide, count))
        end
        push!(cases, (; label, f, ranges=bounded ? (r, i) : (wide, wide), args=(x,)))
    end
    if bounded
        for f in (log, log2, log10)
            add(f, (1.1, 4.0); label="$(f)/table", rejected=(0x1p-950, 0x1p-925))
            if log_regimes == "1"
                add(f, (1.3001, 1.3002); label="$(f)/repeated-index", rejected=(0x1p-950, 0x1p-925))
                add(f, (0.95, 1.05); label="$(f)/mixed-regimes", rejected=(1.1, 4.0))
            end
        end
        add(expm1, (0.55, 16.0); label="expm1/ordinary", rejected=(0.07, 0.4))
        add(x -> x^5, (0.5, 1.5); label="^/literal closure")
    end
    for (f, a, b) in ((exp, 0.25, 2.25), (exp2, 0.25, 2.25), (expm1, -0.5, 0.5),
                      (log, 1.125, 2.25), (log2, 1.125, 2.25), (log1p, -0.0625, 0.0625),
                      (atan, -1.0, 1.0), (tan, -0.5, 0.5), (sinh, -1.0, 1.0),
                      (cosh, -1.0, 1.0), (tanh, -1.0, 1.0))
        add(f, (a, b); label="$(f)/Double32", input_type=Double32)
    end
    return cases
end

function exceptional_fixtures(n)
    near_pole = df64"1.57079632679489661923132169164"
    function build(label, f, inputs)
        x = [inputs[mod1(i, length(inputs))] for i in 1:n]
        return (; label, f, ranges=inputs, args=(x,))
    end
    midpoint = setprecision(BigFloat, 256) do
        m = log2(BigFloat(1.5) * BigFloat(nextfloat(0.0)))
        h = Float64(m)
        Double64(h, Float64(m - h))
    end
    return (
        build("tan/pole", tan, (near_pole - 1e-20, near_pole, near_pole + 1e-20)),
        build("exp2/subnormal", exp2, (Double64(-1070.1), Double64(-1070.4))),
        build("exp2/MPFR", exp2, (midpoint, Double64(HI(midpoint), nextfloat(LO(midpoint))))),
        build("exp2/zero", exp2, (Double64(0.0), Double64(-0.0))),
    )
end

function scalar_loop!(f::F, dest, args, indices) where {F}
    for i in indices
        @inbounds dest[i] = f(map(x -> x isa AbstractVector ? x[i] : x, args)...)
    end
    return dest
end

function threaded_loop!(f, dest, args)
    n = length(dest)
    workers = Threads.nthreads()
    Threads.@threads :dynamic for worker in 1:workers
        scalar_loop!(f, dest, args, (fld((worker - 1) * n, workers) + 1):fld(worker * n, workers))
    end
    return dest
end

@noinline function measure(method::F) where {F}
    method()
    return nothing
end

function measure_time(method::F) where {F}
    return @elapsed measure(method)
end

measure_first(method) = @elapsed Base.invokelatest(measure, method)

function measure_allocations(method::F) where {F}
    return @timed measure(method)
end

function compare_block_sizes!(k, f::F, dest, args, width) where {F}
    for start in 1:width:length(dest)
        DF._batch_block!(k, f, dest, args, start:min(start + width - 1, length(dest)))
    end
    return dest
end

batch_specs(args) = map(x -> x isa Number ? x : eltype(x), args)

function batch_regimes(k)
    if isdefined(DF, :_BatchAlternatives) && k isa DF._BatchAlternatives
        return (batch_regimes(k.preferred)..., batch_regimes(k.secondary)...)
    end
    return k isa Tuple ? k : (k,)
end

unmasked(k) = k isa DF._BatchRepair ? k.kernel : k

function report_llvm(path, label, k, dest, args)
    isnothing(k) && return
    for (i, regime) in enumerate(batch_regimes(k))
        kernel = unmasked(regime)
        file = joinpath(path, replace(label, '/' => '_') * "_$i.ll")
        open(file, "w") do io
            code_llvm(io, DF._batch_native!, Tuple{typeof(kernel),typeof(dest),typeof(args),UnitRange{Int}})
            if regime isa DF._BatchRepair
                code_llvm(io, DF._batch_masked!,
                          Tuple{typeof(kernel),typeof(dest),typeof(first(args)),UnitRange{Int},UInt64,Double64})
            end
        end
    end
end

function run_case(f::F, args, n, label, ranges, repeats, storage; baseline) where {F}
    sampleargs = map(x -> x isa AbstractVector ? (isempty(x) ? one(eltype(x)) : first(x)) : x, args)
    result = if n == 0
        Base.promote_op(f, map(typeof, sampleargs)...)
    else
        typeof(f(sampleargs...))
    end
    dest = Vector{result}(undef, n)
    if storage == "strided"
        args = map(args) do x
            x isa AbstractVector || return x
            data = similar(x, 2n)
            view(data, 1:2:2n) .= x
            view(data, 1:2:2n)
        end
        dest = view(similar(dest, 2n), 1:2:2n)
    elseif storage == "narrow"
        result <: Double64 || return
        dest = Vector{Double32}(undef, n)
    elseif storage == "alias"
        first(args) isa Vector{result} || return
        dest = first(args)
    end
    # Capture the final storage and operands without boxing reassignable
    # variables in the timed closures.
    out, inputs = dest, args
    broadcast_args = map(x -> x isa Number ? Ref(x) : x, inputs)
    methods = (
        broadcast=() -> broadcast!(f, out, broadcast_args...),
        scalar=() -> scalar_loop!(f, out, inputs, eachindex(out)),
        caller_threads=() -> threaded_loop!(f, out, inputs),
    )
    coverage = nothing
    if baseline == false
        methods = merge(methods, (batch=() -> DF.simdmap!(f, out, inputs...),
                                  batch_threads=() -> DF.simdmap!(f, out, inputs...; threaded=true)))
        if storage == "dense" && n > 0
            kernel = DF._batch_kernel(f, eltype(dest), batch_specs(args)...)
            regimes = batch_regimes(kernel)
            if any(k -> k isa DF._BatchRepair, regimes)
                whole_kernel = unmasked(last(regimes))
                methods = merge(methods, (whole_block=() -> compare_block_sizes!(whole_kernel, f, out, inputs, 64),))
            end
            blocks = get(ENV, "SIMD_BLOCK_SIZES", "")
            if kernel !== nothing && !isempty(blocks)
                whole = kernel isa Tuple ? kernel : unmasked(last(regimes))
                for width in parse.(Int, split(blocks, ','))
                    width > 0 || throw(ArgumentError("SIMD_BLOCK_SIZES must be positive"))
                    key = Symbol("block_", width)
                    methods = merge(methods, NamedTuple{(key,)}((() -> compare_block_sizes!(whole, f, out, inputs, width),)))
                end
            end
            if kernel !== nothing
                probes = map(unmasked, regimes)
                counts = map(k -> count(i -> DF._batch_eligible(k, args, i), 1:n), probes)
                rejected = count(i -> !any(k -> DF._batch_eligible(k, args, i), probes), 1:n)
                coverage = (rejected, counts)
            end
        end
    end
    if storage == "alias"
        original = copy(out)
        methods = map(methods) do method
            () -> (copyto!(out, original); method())
        end
    end
    active = keys(methods)
    med = Dict{Symbol,Float64}()
    @printf("%-21s %-17s %s\n", label, string(eltype(dest)), string(ranges))
    if coverage !== nothing
        rejected, counts = coverage
        println("  rejected lanes ", rejected, "/", n, " / eligible per regime ", counts)
    end
    samples = Dict(k => Float64[] for k in active)
    first_call = map(measure_first, methods)
    allocation = map(measure_allocations, methods)
    for j in 1:repeats, offset in eachindex(active)
        name = active[mod1(j + offset - 1, length(active))]
        method = methods[name]
        t = measure_time(method)
        push!(samples[name], 1e6t)
    end
    for name in active
        t = samples[name]
        med[name] = median(t)
        stats = allocation[name]
        @printf("  %-14s %9.2f μs [%9.2f, %9.2f]  %8d B  %6d allocs  %8.3f s first  %5.2fx\n",
                name, med[name], minimum(t), maximum(t), stats.bytes, Base.gc_alloc_count(stats.gcstats),
                first_call[name], med[:broadcast] / med[name])
    end
    llvm_path = get(ENV, "SIMD_LLVM", "")
    if !baseline && storage == "dense" && n > 0 && !isempty(llvm_path)
        kernel = DF._batch_kernel(f, eltype(dest), batch_specs(args)...)
        report_llvm(mkpath(llvm_path), label, kernel, dest, args)
    end
    return nothing
end

function main()
    sizes = parse.(Int, split(get(ENV, "SIMD_SIZE", "4096"), ','))
    all(>=(0), sizes) || throw(ArgumentError("SIMD_SIZE must be nonnegative"))
    repeats = parse(Int, get(ENV, "SIMD_REPEATS", "15"))
    repeats > 0 || throw(ArgumentError("SIMD_REPEATS must be positive"))
    range = get(ENV, "SIMD_RANGE", "bounded")
    range in ("bounded", "general", "special") ||
        throw(ArgumentError("SIMD_RANGE must be bounded, general, or special"))
    bounded = range == "bounded"
    mixtures = parse.(Float64, split(get(ENV, "SIMD_MIXTURE", "0"), ','))
    all(x -> 0 <= x <= 1, mixtures) || throw(ArgumentError("SIMD_MIXTURE must be in [0, 1]"))
    clustered = get(ENV, "SIMD_CLUSTERED", "0") == "1"
    storage = get(ENV, "SIMD_STORAGE", "dense")
    storage in ("dense", "strided", "narrow", "alias") ||
        throw(ArgumentError("SIMD_STORAGE must be dense, strided, narrow, or alias"))
    filter = Regex(get(ENV, "SIMD_FILTER", ""))
    baseline = "--baseline" in ARGS
    log_regimes = get(ENV, "SIMD_LOG_REGIMES", "")
    println("Julia ", VERSION, " / ", Sys.CPU_NAME, " / ", first(Sys.cpu_info()).model,
            " / target ", unsafe_string(Base.JLOptions().cpu_target),
            " / ", Threads.nthreads(), " threads / seed ", SEED)
    revision = get(ENV, "SIMD_REVISION") do
        readchomp(`git rev-parse --short HEAD`)
    end
    for n in sizes, mixture in mixtures
        println("Commit ", revision, " / n=", n, " / range=", range,
                " / mixture=", mixture, " / clustered=", clustered, " / storage=", storage)
        cases = range == "special" ? exceptional_fixtures(n) :
                fixtures(n; bounded, mixture, clustered, filter, log_regimes)
        for case in cases
            occursin(filter, case.label) || continue
            run_case(case.f, case.args, n, case.label, case.ranges, repeats, storage; baseline)
        end
    end
end

abspath(PROGRAM_FILE) == (@__FILE__) && main()
