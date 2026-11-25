# The source is loaded in layers (see the include list in src/DoubleFloats.jl),
# and a file may use only what is loaded above it.
#
# Julia already enforces this for types, constants, and macros: the package
# would not load otherwise. It does not enforce it for functions, which are
# resolved when called. This lint does: it reports every use, in one layer, of
# a name the package first defines in a later layer.
#
# It is a lint, not a proof. It works on names, so a local variable that
# shares the name of a later function is reported too; such cases, and upward
# calls that exist today and are yet to be removed, are listed in ALLOWED.
# The test fails when a use appears that is not listed, and when a listed
# entry no longer occurs, so the list can only shrink.

module Layering

const SOURCE = joinpath(@__DIR__, "..", "src")

# Layer number and files, read from the include list.
function layers()
    result = Pair{Int,String}[]
    layer = 0
    for line in eachline(joinpath(SOURCE, "DoubleFloats.jl"))
        m = match(r"^# (\d+)\. ", line)
        m === nothing || (layer = parse(Int, m[1]))
        m = match(r"^include\(\"([^\"]+)\"\)", line)
        (m === nothing || layer == 0) && continue
        push!(result, layer => m[1])
    end
    return result
end

# Files a file includes itself, which belong to the same layer.
function nested(file)
    found = String[file]
    for line in eachline(joinpath(SOURCE, file))
        m = match(r"^include\(\"([^\"]+)\"\)", line)
        m === nothing || append!(found, nested(joinpath(dirname(file), m[1])))
    end
    return found
end

function parseall(file)
    text = read(joinpath(SOURCE, file), String)
    return Meta.parseall(text; filename = file)
end

# The name a definition introduces, or nothing when it extends a function of
# another module (`Base.exp(...) = ...`).
function signaturename(ex)
    while ex isa Expr && ex.head in (:where, :(::), :call, :curly)
        # `(k::Kernel)(x) = ...` makes a type callable and names nothing.
        ex.head == :call && ex.args[1] isa Expr && ex.args[1].head == :(::) && return nothing
        ex = ex.args[1]
    end
    return ex isa Symbol ? ex : nothing
end

function definitions!(names, ex)
    ex isa Expr || return names
    if ex.head in (:function, :macro) || (ex.head == :(=) && ex.args[1] isa Expr && ex.args[1].head in (:call, :where))
        name = signaturename(ex.args[1])
        name === nothing || push!(names, name)
    elseif ex.head == :const && ex.args[1] isa Expr && ex.args[1].head == :(=)
        name = ex.args[1].args[1]
        name isa Symbol && push!(names, name)
    elseif ex.head == :struct
        name = signaturename(ex.args[2] isa Expr && ex.args[2].head == :<: ? ex.args[2].args[1] : ex.args[2])
        name === nothing || push!(names, name)
    elseif ex.head in (:toplevel, :block, :macrocall, :for, :let, :if)
        foreach(arg -> definitions!(names, arg), ex.args)
    end
    return names
end

function symbols!(names, ex)
    if ex isa Symbol
        push!(names, ex)
    elseif ex isa Expr
        # `Base.exp`, `x.hi`: the field name is not a use of a package name.
        if ex.head == :. && length(ex.args) == 2 && ex.args[2] isa QuoteNode
            symbols!(names, ex.args[1])
        else
            foreach(arg -> symbols!(names, arg), ex.args)
        end
    end
    return names
end

# Names the module file imports from other modules. A method added to one of
# these is not a definition of a package-owned name.
function imported()
    names = Set{Symbol}()
    tree = parseall("DoubleFloats.jl")
    walk(ex) = begin
        ex isa Expr || return
        if ex.head in (:import, :using)
            for arg in ex.args
                arg isa Expr && arg.head == :(:) || continue
                for item in arg.args[2:end]
                    item isa Expr && item.head == :. && push!(names, item.args[end])
                end
            end
        else
            foreach(walk, ex.args)
        end
    end
    walk(tree)
    return names
end

"""
    upwarduses() -> Vector{String}

Each entry is `"file: name (layer of file < layer where name is defined)"`.
"""
function upwarduses()
    foreign = imported()
    files = [(layer, file) for (layer, top) in layers() for file in nested(top)]
    firstlayer = Dict{Symbol,Int}()
    for (layer, file) in files
        for name in definitions!(Set{Symbol}(), parseall(file))
            name in foreign && continue
            isdefined(Base, name) && continue
            firstlayer[name] = min(get(firstlayer, name, typemax(Int)), layer)
        end
    end
    found = String[]
    for (layer, file) in files
        for name in sort!(collect(symbols!(Set{Symbol}(), parseall(file))))
            defined = get(firstlayer, name, 0)
            defined > layer && push!(found, string(file, ": ", name, " (", layer, " < ", defined, ")"))
        end
    end
    return sort!(found)
end

end # module Layering

const ALLOWED = readlines(joinpath(@__DIR__, "layering_allowed.txt"))

@testset "layering" begin
    found = Layering.upwarduses()
    new = setdiff(found, ALLOWED)
    gone = setdiff(ALLOWED, found)
    isempty(new) || println("uses of a name from a later layer, not in layering_allowed.txt:\n  ", join(new, "\n  "))
    isempty(gone) ||
        println("entries of layering_allowed.txt that no longer occur; remove them:\n  ", join(gone, "\n  "))
    @test isempty(new)
    @test isempty(gone)
end
