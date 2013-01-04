@assert norm(integrate(x -> 1 / x, 1.0, 2.0) - log(2)) < 10e-8
@assert norm(integrate(x -> -sin(x), 0.0, pi) - (cos(pi) - cos(0.0))) < 10e-8
