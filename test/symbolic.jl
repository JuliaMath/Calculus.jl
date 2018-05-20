#
# Univariate Calculus
#

macro test_simplified_isequal(lhs, rhs)
    quote
        @test isequal(simplify($(esc(lhs))), $(esc(rhs)))
    end
end

@test isequal(differentiate(:(2), :x), 0)
@test isequal(differentiate(:(x), :x), 1)
@test_simplified_isequal differentiate(:(x + x), :x) 2
@test_simplified_isequal differentiate(:(x - x), :x) 0
@test_simplified_isequal differentiate(:(2 * x), :x) 2
@test_simplified_isequal differentiate(:(2 / x), :x) :(-2 / x^2)
@test_simplified_isequal differentiate(:(x / 2), :x) 0.5
@test_simplified_isequal differentiate(:(sin(x) / x), :x) :((cos(x) * x - sin(x)) / x^2)
@test_simplified_isequal differentiate(:(x * 2), :x) 2
@test_simplified_isequal differentiate(:(a * x), :x) :a
@test_simplified_isequal differentiate(:(x * a), :x) :a
@test_simplified_isequal differentiate(:(x ^ 2), :x) :(2 * x)
@test_simplified_isequal differentiate(:(a * x ^ 2), :x) :(a * (2 * x))
@test_simplified_isequal differentiate(:(2 ^ x), :x) :(*(0.6931471805599453, ^(2, x)))
@test_simplified_isequal differentiate(:(sin(x)), :x) :(cos(x))
@test_simplified_isequal differentiate(:(cos(x)), :x) :(-sin(x))
@test_simplified_isequal differentiate(:(tan(x)), :x) :(1 + tan(x)^2)
@test_simplified_isequal differentiate(:(exp(x)), :x) :(exp(x))
@test_simplified_isequal differentiate(:(log(x)), :x) :(1 / x)
@test_simplified_isequal differentiate(:(sin(x) + sin(x)), :x) :(cos(x) + cos(x))
@test_simplified_isequal differentiate(:(sin(x) - cos(x)), :x) :(cos(x) + sin(x))
@test_simplified_isequal differentiate(:(x * sin(x)), :x) :(sin(x) + x * cos(x))
@test_simplified_isequal differentiate(:(x / sin(x)), :x) :((sin(x) - x * cos(x)) / (sin(x)^2))
@test_simplified_isequal differentiate(:(sin(sin(x))), :x) :(*(cos(x),cos(sin(x))))
@test_simplified_isequal differentiate(:(sin(cos(x) + sin(x))), :x) :(*(+(-sin(x),cos(x)),cos(+(cos(x),sin(x)))))
@test_simplified_isequal differentiate(:(exp(-x)), :x) :(-exp(-x))
@test_simplified_isequal differentiate(:(log(x^2)), :x) :((2x) * (1 / x^2))
@test_simplified_isequal differentiate(:(abs2(x)), :x) :(2x)
@test_simplified_isequal differentiate(:(inv(x)), :x) :(-abs2(inv(x)))
@test_simplified_isequal differentiate(:(x^n), :x) :(*(n, ^(x, -(n, 1))))
@test_simplified_isequal differentiate(:(n^x), :x) :(*(^(n, x), log(n)))
@test_simplified_isequal differentiate(:(n^n), :x) 0

#
# Multivariate Calculus
#

@test isequal(simplify.(differentiate(:(sin(x) + sin(y)), [:x, :y])), [:(cos(x)), :(cos(y))])
@test isequal(simplify.(differentiate(:(x^2), [:x, :y])), Any[:(2*x), 0])

# TODO: Get the generalized power rule right.
# @test isequal(differentiate(:(sin(x)^2), :x), :(2 * sin(x) * cos(x)))

#
# Strings instead of symbols
#

# @test isequal(differentiate("sin(x) + cos(x)^2"), :(+(cos(x),*(2,cos(x)))))
@test_simplified_isequal differentiate("x + exp(-x) + sin(exp(x))", :x) :(+(1,-exp(-x),*(exp(x),cos(exp(x)))))

# TODO: Make these work
# differentiate(:(sin(x)), :x)(0.0)
# differentiate(:(sin(x)), :x)(1.0)
# differentiate(:(sin(x)), :x)(pi)

#
# SymbolicVariable use
#

x = BasicVariable(:x)
y = BasicVariable(:y)

@test isequal(@sexpr(x + y), :($x + $y))
@test_simplified_isequal differentiate(@sexpr(3 * x), x) 3
@test_simplified_isequal differentiate(:(sin(sin(x))), :x) :(*(cos(x),cos(sin(x))))
@test_simplified_isequal differentiate(@sexpr(sin(sin(x))), x) :(*(cos($x),cos(sin($x))))

function testfun(x)
    z = BasicVariable(:z)
    simplify(differentiate(@sexpr(3*x + x^2*z), z))
end

@test isequal(testfun(x), :(^($(x),2)))
@test isequal(testfun(3), 9)
@test isequal(testfun(@sexpr(x+y)), :(^(+($x,$y),2)))

#
# Simplify tests
#

@test isequal(simplify(:(x-0)), :x)
@test isequal(simplify(:(0-x)), :(-x))

@test isequal(simplify(:(x+y)), :(+(x,y)))
@test isequal(simplify(:(x+3)), :(+(3,x)))
@test isequal(simplify(:(x+3+4)), :(+(7,x)))
@test isequal(simplify(:(2+y+x+3)), :(+(5,y,x)))

@test isequal(simplify(:(x*y)), :(*(x,y)))
@test isequal(simplify(:(x*3)), :(*(3,x)))
@test isequal(simplify(:(x*3*4)), :(*(12,x)))
@test isequal(simplify(:(2*y*x*3)), :(*(6,y,x)))

@test isequal(simplify(:(sin((1*(sin(0/0)))))), NaN)

#
# Tests with ifelse
#
@test_simplified_isequal differentiate(:(ifelse(x < 1, exp(x^2), 1/x)), :x) :(ifelse(x < 1,2x * exp(x^2), -1/x^2))
@test_simplified_isequal differentiate(:(ifelse(x <= 0, 0, ifelse(x > 1, 1, x))), :x) :(ifelse(x <= 0, 0, ifelse(x > 1, 0, 1)))
