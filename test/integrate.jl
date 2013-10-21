@test norm(integrate(x -> 1 / x, 1.0, 2.0) - log(2)) < 10e-8
@test norm(integrate(x -> -sin(x), 0.0, pi) - (cos(pi) - cos(0.0))) < 10e-8

r = integrate(x -> 1, 0, 1)
@test norm(r - 1) < 10e-8

r = integrate(x -> x, 0, 1)
@test norm(r - 0.5) < 10e-8

r = integrate(x -> x * x, 0, 1)
@test norm(r - 1 / 3) < 10e-8

r = integrate(sin, 0, pi)
@test norm(r - 2) < 10e-8

r = integrate(cos, 0, pi)
@test norm(r - 0) < 10e-8

r = integrate(x -> sin(x)^2 + sin(x)^2, 0, pi)
@test norm(r - pi) < 10e-8

# Nice example, but requires Distributions
# require("Distributions")
# using Distributions
# r = integrate(x -> pdf(Normal(0.0, 1.0), x), -10, 10)
# @test norm(1 - r) < 10e-8

r = integrate(x -> 1 / x, 0.01, 1)
@test norm(r - 4.60517) < 10e-7

r = integrate(x -> cos(x)^8, 0, 2 * pi)
@test norm(r - 35 * pi / 64) < 10e-7

r = integrate(x -> sin(x) - sin(x^2) + sin(x^3), pi, 2 * pi)
@test norm(r - (-1.830467)) < 10e-7

# Monte Carlo integration tests
r = integrate(x -> sin(x), 0, pi, :monte_carlo)
@test norm(r - 2) < 10e-1
