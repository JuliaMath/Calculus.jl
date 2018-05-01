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

for t in tests
    println(" * $(t)")
    include("$(t).jl")
end
