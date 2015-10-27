#
# Correctness Tests
#

using Calculus
using Base.Test

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
