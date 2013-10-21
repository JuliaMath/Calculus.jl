#
# Correctness Tests
#

using Calculus
using Base.Test

tests = ["finite_difference",
         "derivative",
         "check_derivative",
         "integrate",
         "symbolic",
         "deparse"]

println("Running tests:")

for t in tests
    println(" * $(t)")
    include("test/$(t).jl")
end
