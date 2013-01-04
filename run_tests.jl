#
# Correctness Tests
#

require("Calculus")
using Calculus

my_tests = ["test/finite_difference.jl",
            "test/derivative.jl",
            "test/check_derivative.jl",
            "test/integrate.jl"]

println("Running tests:")

for my_test in my_tests
    println(" * $(my_test)")
    include(my_test)
end
