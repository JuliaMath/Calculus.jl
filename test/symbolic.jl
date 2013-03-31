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
@assert isequal(differentiate(:(cos(x)), :x), :(-sin(x)))
@assert isequal(differentiate(:(tan(x)), :x), :(1 + tan(x)^2))
@assert isequal(differentiate(:(exp(x)), :x), :(exp(x)))
@assert isequal(differentiate(:(log(x)), :x), :(1 / x))
@assert isequal(differentiate(:(sin(x) + sin(x)), :x), :(cos(x) + cos(x)))
@assert isequal(differentiate(:(sin(x) - cos(x)), :x), :(cos(x) - (-sin(x)))) # Simplify -(a, -(b)) => +(a, b)
@assert isequal(differentiate(:(x * sin(x)), :x), :(sin(x) + x * cos(x)))
@assert isequal(differentiate(:(x / sin(x)), :x), :((sin(x) - x * cos(x)) / (sin(x)^2)))
@assert isequal(differentiate(:(sin(sin(x))), :x), :(*(cos(sin(x)),cos(x))))
@assert isequal(differentiate(:(sin(cos(x) + sin(x))), :x), :(*(cos(+(cos(x),sin(x))),+(-(sin(x)),cos(x))))) # Clean this up
@assert isequal(differentiate(:(exp(-x)), :x), :(exp(-x) * -1)) # Simplify this to -(exp(-x))
@assert isequal(differentiate(:(log(x^2)), :x), :(*(/(1,^(x,2)),*(2,x)))) # Clean this up
@assert isequal(differentiate(:(x^n), :x), :(*(n, ^(x, -(n, 1)))))
@assert isequal(differentiate(:(n^x), :x), :(*(^(n, x), log(n))))
@assert isequal(differentiate(:(n^n), :x), :(^(n,n)))

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
@assert isequal(differentiate("x + exp(-x) + sin(exp(x))", :x), :(+(1, *(exp(-(x)), -1), *(cos(exp(x)), exp(x)))))

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
@assert isequal(differentiate(:(sin(sin(x))), :x), :(*(cos(sin(x)),cos(x))))
@assert isequal(differentiate(@sexpr(sin(sin(x))), x), :(*(cos(sin($x)),cos($x))))

#
# Chain rule
#

@assert isequal(chainRule(@sexpr(3 * x), x), :(1*3))
@assert isequal(chainRule(:(sin(sin(x))), :x), :(*(*(1,cos(x)),cos(sin(x)))))
@assert isequal(chainRule(@sexpr(sin(sin(x))), x), :(*(*(1,cos($(x))),cos(sin($(x))))))

function testfun(x)
    z = BasicVariable(:z)
    chainRule(@sexpr(3*x + x^2*z), z)
end

@assert isequal(testfun(x), :(*(1,^($(x),2))))
@assert isequal(testfun(3), :(*(1,^(3,2))))
@assert isequal(testfun(@sexpr(x+y)), :(*(1,^(+($(x),$(y)),2))))

@assert isequal(chainRule(:(2), :x), 0)
@assert isequal(chainRule(:(x), :x), 1)
@assert isequal(chainRule(:(x + x), :x), 2)
@assert isequal(chainRule(:(x - x), :x), 0)
@assert isequal(chainRule(:(2 * x), :x), 2)
@assert isequal(chainRule(:(x * 2), :x), 2)
@assert isequal(chainRule(:(a * x), :x), :a)
@assert isequal(chainRule(:(x * a), :x), :a)
@assert isequal(chainRule(:(x ^ 2), :x), :(2 * x))
@assert isequal(chainRule(:(a * x ^ 2), :x), :(a * (2 * x)))
@assert isequal(chainRule(:(2 ^ x), :x), :(*(^(2, x), 0.6931471805599453)))
@assert isequal(chainRule(:(sin(x)), :x), :(cos(x)))
@assert isequal(chainRule(:(cos(x)), :x), :(-sin(x)))
@assert isequal(chainRule(:(tan(x)), :x), :(1 + tan(x)^2))
@assert isequal(chainRule(:(exp(x)), :x), :(exp(x)))
@assert isequal(chainRule(:(log(x)), :x), :(1 / x))
@assert isequal(chainRule(:(sin(x) + sin(x)), :x), :(cos(x) + cos(x)))
@assert isequal(chainRule(:(sin(x) - cos(x)), :x), :(cos(x) - (-sin(x)))) # Simplify -(a, -(b)) => +(a, b)
@assert isequal(chainRule(:(x * sin(x)), :x), :(sin(x) + x * cos(x)))
@assert isequal(chainRule(:(x / sin(x)), :x), :((sin(x) - x * cos(x)) / (sin(x)^2)))
@assert isequal(chainRule(:(sin(sin(x))), :x), :(*(cos(sin(x)),cos(x))))
@assert isequal(chainRule(:(sin(cos(x) + sin(x))), :x), :(*(cos(+(cos(x),sin(x))),+(-(sin(x)),cos(x))))) # Clean this up
@assert isequal(chainRule(:(exp(-x)), :x), :(exp(-x) * -1)) # Simplify this to -(exp(-x))
@assert isequal(chainRule(:(log(x^2)), :x), :(*(/(1,^(x,2)),*(2,x)))) # Clean this up
@assert isequal(chainRule(:(x^n), :x), :(*(n, ^(x, -(n, 1)))))
@assert isequal(chainRule(:(n^x), :x), :(*(^(n, x), log(n))))
@assert isequal(chainRule(:(n^n), :x), 0)

chainRule(:(2), :x)
chainRule(:(x), :x)
chainRule(:(x + x), :x)
chainRule(:(x - x), :x)
chainRule(:(2 * x), :x)
chainRule(:(x * 2), :x)
chainRule(:(a * x), :x)
chainRule(:(x * a), :x)
chainRule(:(x ^ 2), :x)
chainRule(:(a * x ^ 2), :x)
chainRule(:(2 ^ x), :x)
chainRule(:(sin(x)), :x)
chainRule(:(cos(x)), :x)
chainRule(:(tan(x)), :x)
chainRule(:(exp(x)), :x)
chainRule(:(log(x)), :x)
chainRule(:(sin(x) + sin(x)), :x)
chainRule(:(sin(x) - cos(x)), :x)
chainRule(:(x * sin(x)), :x)
chainRule(:(x / sin(x)), :x)
chainRule(:(sin(sin(x))), :x)
chainRule(:(sin(cos(x) + sin(x))), :x)
chainRule(:(exp(-x)), :x)
chainRule(:(log(x^2)), :x)
chainRule(:(x^n), :x)
chainRule(:(n^x), :x)
chainRule(:(n^n), :x)
