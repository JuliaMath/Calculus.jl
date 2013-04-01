#
# Univariate Calculus
#

@assert isequal(differentiate(:(2), :x), 0)
@assert isequal(differentiate(:(x), :x), 1)
@assert isequal(differentiate(:(x + x), :x), 2)
@assert isequal(differentiate(:(x - x), :x), 0)
@assert isequal(differentiate(:(2 * x), :x), 2)
@assert isequal(differentiate(:(x * 2), :x), 2)
@assert isequal(differentiate(:(a * x), :x), :a)
@assert isequal(differentiate(:(x * a), :x), :a)
@assert isequal(differentiate(:(x ^ 2), :x), :(2 * x))
@assert isequal(differentiate(:(a * x ^ 2), :x), :(a * (2 * x)))
@assert isequal(differentiate(:(2 ^ x), :x), :(*(^(2, x), 0.6931471805599453)))
@assert isequal(differentiate(:(sin(x)), :x), :(cos(x)))
@assert isequal(differentiate(:(cos(x)), :x), :(*(-1,sin(x))))  # needs a better simplify
@assert isequal(differentiate(:(tan(x)), :x), :(1 + tan(x)^2))
@assert isequal(differentiate(:(exp(x)), :x), :(exp(x)))
@assert isequal(differentiate(:(log(x)), :x), :(1 / x))
@assert isequal(differentiate(:(sin(x) + sin(x)), :x), :(cos(x) + cos(x)))
@assert isequal(differentiate(:(sin(x) - cos(x)), :x), :(-(cos(x),*(-1,sin(x))))) # Simplify -(a, -(b)) => +(a, b)
@assert isequal(differentiate(:(x * sin(x)), :x), :(sin(x) + x * cos(x)))
@assert isequal(differentiate(:(x / sin(x)), :x), :((sin(x) - x * cos(x)) / (sin(x)^2)))
@assert isequal(differentiate(:(sin(sin(x))), :x), :(*(cos(x),cos(sin(x)))))
@assert isequal(differentiate(:(sin(cos(x) + sin(x))), :x), :(*(+(*(-1,sin(x)),cos(x)),cos(+(cos(x),sin(x)))))) # Clean this up
@assert isequal(differentiate(:(exp(-x)), :x), :(*(-1,exp(-(x))))) # Simplify this to -(exp(-x))
@assert isequal(differentiate(:(log(x^2)), :x), :(/(*(2,x),^(x,2))))
@assert isequal(differentiate(:(x^n), :x), :(*(n, ^(x, -(n, 1)))))
@assert isequal(differentiate(:(n^x), :x), :(*(^(n, x), log(n))))
@assert isequal(differentiate(:(n^n), :x), 0)

#
# Multivariate Calculus
#

@assert isequal(differentiate(:(sin(x) + sin(y)), [:x, :y]), [:(cos(x)), :(cos(y))])

# TODO: Get the generalized power rule right.
# @assert isequal(differentiate(:(sin(x)^2), :x), :(2 * sin(x) * cos(x)))

#
# Strings instead of symbols
#

# @assert isequal(differentiate("sin(x) + cos(x)^2"), :(+(cos(x),*(2,cos(x)))))
@assert isequal(differentiate("x + exp(-x) + sin(exp(x))", :x), :(+(1,*(-1,exp(-(x))),*(exp(x),cos(exp(x))))))

# TODO: Make these work
# differentiate(:(sin(x)), :x)(0.0)
# differentiate(:(sin(x)), :x)(1.0)
# differentiate(:(sin(x)), :x)(pi)

#
# SymbolicVariable use
#

x = BasicVariable(:x)
y = BasicVariable(:y)

@assert isequal(@sexpr(x + y), :($x + $y))
@assert isequal(differentiate(@sexpr(3 * x), x), 3)
@assert isequal(differentiate(:(sin(sin(x))), :x), :(*(cos(x),cos(sin(x)))))
@assert isequal(differentiate(@sexpr(sin(sin(x))), x), :(*(cos($x),cos(sin($x)))))

function testfun(x)
    z = BasicVariable(:z)
    differentiate(@sexpr(3*x + x^2*z), z)
end

@assert isequal(testfun(x), :(^($(x),2)))
@assert isequal(testfun(3), 9)
@assert isequal(testfun(@sexpr(x+y)), :(^(+($x,$y),2)))
