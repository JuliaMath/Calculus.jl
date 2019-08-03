#
# Correctness Tests
#

using Calculus
using Test
using LinearAlgebra

tests = ["finite_difference",
         "derivative",
         "check_derivative",
         "symbolic",
         "deparse"]

for t in tests
    @testset "$t" begin
        include("$(t).jl")
    end
end
