# Checks on how the package is written, as opposed to what it computes.

using ExplicitImports

@testset "imports" begin
    # Every name used from another module is named in a `using` statement,
    # none is named without being used, and qualified names go through the
    # module that owns them.
    @test check_no_implicit_imports(DoubleFloats) === nothing
    @test check_no_stale_explicit_imports(DoubleFloats) === nothing
    @test check_all_qualified_accesses_via_owners(DoubleFloats) === nothing
    @test check_no_self_qualified_accesses(DoubleFloats) === nothing
end
