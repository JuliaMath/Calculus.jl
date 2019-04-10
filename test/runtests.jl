#
# Correctness Tests
#

using Calculus
using Compat
using Compat.Test
using Compat.LinearAlgebra

tests = ["finite_difference",
         "derivative",
         "check_derivative",
         "symbolic",
         "deparse"]

println("Running tests:")

@testset "$t" for t in tests
    include("$t.jl")
end

println("Tests finished.")
