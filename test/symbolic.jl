@assert isequal(deriv(:(2), :x), 0)
@assert isequal(deriv(:(x), :x), 1)
@assert isequal(deriv(:(x + x), :x), 2)
@assert isequal(deriv(:(x - x), :x), 0)
@assert isequal(deriv(:(2 * x), :x), 2)
@assert isequal(deriv(:(x * 2), :x), 2)
@assert isequal(deriv(:(a * x), :x), :a)
@assert isequal(deriv(:(x * a), :x), :a)
@assert isequal(deriv(:(x ^ 2), :x), :(2 * x))
@assert isequal(deriv(:(a * x ^ 2), :x), :(a * (2 * x)))
# deriv(:(2 ^ x), :x) # TODO: Make this work
@assert isequal(deriv(:(sin(x)), :x), :(cos(x)))
@assert isequal(deriv(:(cos(x)), :x), :(-sin(x)))
@assert isequal(deriv(:(tan(x)), :x), :(1 + tan(x)^2))
@assert isequal(deriv(:(exp(x)), :x), :(exp(x)))
@assert isequal(deriv(:(log(x)), :x), :(1 / x))
@assert isequal(deriv(:(sin(x) + sin(x)), :x), :(cos(x) + cos(x)))
@assert isequal(deriv(:(sin(x) - cos(x)), :x), :(cos(x) - (-sin(x)))) # Simplify -(a, -(b)) => +(a, b)
@assert isequal(deriv(:(x * sin(x)), :x), :(sin(x) + x * cos(x)))
@assert isequal(deriv(:(x / sin(x)), :x), :((sin(x) - x * cos(x)) / (sin(x)^2)))
@assert isequal(deriv(:(sin(sin(x))), :x), :(*(cos(sin(x)),cos(x))))
@assert isequal(deriv(:(sin(cos(x) + sin(x))), :x), :(*(cos(+(cos(x),sin(x))),+(-(sin(x)),cos(x))))) # Clean this up
@assert isequal(deriv(:(exp(-x)), :x), :(exp(-x) * -1)) # Simplify this to -(exp(-x))
@assert isequal(deriv(:(log(x^2)), :x), :(*(/(1,^(x,2)),*(2,x)))) # Clean this up

@assert isequal(deriv("sin(x) + cos(x)^2"), :(+(cos(x),*(2,cos(x)))))

# TODO: Make these work
# derivative(:(sin(x)), :x)(0.0)
# derivative(:(sin(x)), :x)(1.0)
# derivative(:(sin(x)), :x)(pi)
