# Run from the package root with julia --project perf/bench_matrix_functions.jl.
using DoubleFloats, LinearAlgebra, Random, Statistics, Printf

const DF = DoubleFloats
const MATRIX_SEED = 0x328
halfpower(A) = A ^ Double64(0.5)
quarterpower(A) = A ^ Double64(0.25)

function matrix_fixtures(n)
    rng = MersenneTwister(MATRIX_SEED)
    R = Double64.(randn(rng, n, n))
    n == 0 && return (general=R, symmetric=copy(R), diagonal=copy(R),
                      upper=copy(R), lower=copy(R), complex_upper=ComplexDF64.(R),
                      small=copy(R))
    A = R .* (Double64(0.35) / opnorm(R, 1)) + Double64(0.8) * I
    T = triu(A)
    H = (R + R') .* Double64(0.5)
    H = H .* (Double64(0.3) / opnorm(H, 1)) + Double64(0.5) * I
    imaginary = triu(Double64.(randn(rng, n, n))) .* Double64(0.02 / n)
    return (general=A, symmetric=H, diagonal=Matrix(Diagonal(diag(H))),
            upper=T, lower=Matrix(transpose(T)), complex_upper=complex.(T, imaginary),
            small=(A - I) .* Double64(0.01))
end

@noinline evaluate(f::F) where {F} = f()

function measure_case(label, f::F, repeats) where {F}
    first_call = try
        @timed Base.invokelatest(evaluate, f)
    catch e
        e isa InterruptException && rethrow()
        println(label, "  ", typeof(e), "  ", sprint(showerror, e))
        return
    end
    samples = map(1:repeats) do _
        stat = @timed evaluate(f)
        (time=stat.time * 1e3, bytes=stat.bytes, allocations=Base.gc_alloc_count(stat.gcstats))
    end
    times = getproperty.(samples, :time)
    @printf("%-31s %9.4f ms [%9.4f, %9.4f] %10.0f B %7.0f allocs %7.3f s first\n",
            label, median(times), extrema(times)..., median(getproperty.(samples, :bytes)),
            median(getproperty.(samples, :allocations)), first_call.time)
end

function main()
    sizes = parse.(Int, split(get(ENV, "MAT_SIZE", "16,32,64,128,256"), ','))
    repeats = parse(Int, get(ENV, "MAT_REPEATS", "7"))
    all(>=(0), sizes) && repeats > 0 || throw(ArgumentError("invalid MAT_SIZE or MAT_REPEATS"))
    filter = Regex(get(ENV, "MAT_FILTER", ""))
    stages = get(ENV, "MAT_STAGES", "0") == "1"
    operations = (exp=exp, log=log, sqrt=sqrt, sin=sin, cos=cos, sincos=sincos,
                  sinh=sinh, cosh=cosh, tan=tan, tanh=tanh, halfpower=halfpower,
                  quarterpower=quarterpower)
    previous_threads = BLAS.get_num_threads()
    BLAS.set_num_threads(1)
    try
        rev = get(ENV, "MAT_REVISION") do
            readchomp(`git rev-parse --short HEAD`)
        end
        println("Julia ", VERSION, " / ", Sys.CPU_NAME, " / ", first(Sys.cpu_info()).model,
                " / target ", unsafe_string(Base.JLOptions().cpu_target),
                " / Julia threads ", Threads.nthreads(), " / BLAS threads ", BLAS.get_num_threads(),
                " / seed ", MATRIX_SEED, " / revision ", rev)
        for n in sizes
            println("n=", n)
            fixtures = matrix_fixtures(n)
            for (shape, A) in pairs(fixtures), (name, f) in pairs(operations)
                label = "$shape/$name"
                occursin(filter, label) || continue
                measure_case(label, () -> f(A), repeats)
            end
            stages && n > 0 || continue
            T = fixtures.upper
            A = ComplexDF64.(fixtures.general)
            S = schur(A)
            U = DF._sqrt_uppertri(S.T)
            for (name, f) in (("stage/triangular solve", () -> UpperTriangular(T - I) / UpperTriangular(T + I)),
                              ("stage/product", () -> T * T),
                              ("stage/triangular sqrt", () -> DF._sqrt_uppertri(T)),
                              ("stage/triangular log", () -> DF._log_uppertri(T)),
                              ("stage/complex Schur", () -> schur(A)),
                              ("stage/lazy reconstruction", () -> S.Z * U * S.Z'),
                              ("stage/packed reconstruction", () -> (S.Z * U) * Matrix(adjoint(S.Z))))
                occursin(filter, name) && measure_case(name, f, repeats)
            end
            if isdefined(DF, :_mat_tri_mul) && occursin(filter, "stage/triangular product")
                measure_case("stage/triangular product", () -> DF._mat_tri_mul(T, T), repeats)
            end
            if isdefined(DF, :_sqrt_uppertri_point) && occursin(filter, "stage/point sqrt")
                measure_case("stage/point sqrt", () -> DF._sqrt_uppertri_point(T), repeats)
            end
        end
    finally
        BLAS.set_num_threads(previous_threads)
    end
end

abspath(PROGRAM_FILE) == (@__FILE__) && main()
