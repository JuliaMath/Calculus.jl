@assert norm(integrate(x -> 1 / x, 1.0, 2.0) - log(2)) < 10e-8
@assert norm(integrate(x -> -sin(x), 0.0, pi) - (cos(pi) - cos(0.0))) < 10e-8

r = integrate(x -> 1, 0, 1)
@assert norm(1 - r ) < 10e-8

r = integrate(x -> x, 0, 1)
@assert norm(1 / 2 - r) < 10e-8

r = integrate(x -> x * x, 0, 1)
@assert norm(1 / 3 - r) < 10e-8

r = integrate(sin, 0, pi)
@assert norm(2 - r) < 10e-8

r = integrate(cos, 0, pi)
@assert norm(0 - r) < 10e-8

r = integrate(x -> sin(x)^2 + sin(x)^2, 0, pi)
@assert norm(pi - r) < 10e-8

# Nice example, but requires Distributions
# require("Distributions")
# using Distributions
# r = integrate(x -> pdf(Normal(0.0, 1.0), x), -10, 10)
# @assert norm(1 - r) < 10e-8

r = integrate(x -> 1 / x, 0.01, 1)
@assert norm(4.60517 - r) < 10e-7

r = integrate(x -> cos(x)^8, 0, 2 * pi)
@assert norm(35 * pi / 64 - r) < 10e-7

r = integrate(x -> sin(x) - sin(x^2) + sin(x^3), pi, 2 * pi)
@assert norm(-1.830467 - r) < 10e-7  
