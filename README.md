Calculus.jl
===========

# Introduction

The Calculus package provides tools for working with the basic calculus
operations of differentiation and integration. Right now, only
differentation is supported. You can use the Calculus package to produce
approximate derivatives by several forms of finite differencing.

# API

Most users will want to work with four functions:

* `derivative()`: Use this for functions from R to R
* `second_derivative()`: Use this for functions from R to R
* `gradient()`: Use this for functions from R^n to R
* `hessian()`: Use this for functions from R^n to R

# Usage Examples

There are two basic approaches to using the Calculus package:

* Use finite-differencing to evaluate the derivative at a specific point
* Use higher-order functions to create new functions that evaluate derivatives

## Direct Finite Differencing

	require("Calculus")
	using Calculus

	# Compare with cos(0.0)
	derivative(x -> sin(x), 0.0)
	# Compare with cos(1.0)
	derivative(x -> sin(x), 1.0)
	# Compare with cos(pi)
	derivative(x -> sin(x), pi)

	# Compare with [cos(0.0), -sin(0.0)]
	gradient(x -> sin(x[1]) + cos(x[2]), [0.0, 0.0])
	# Compare with [cos(1.0), -sin(1.0)]
	gradient(x -> sin(x[1]) + cos(x[2]), [1.0, 1.0])
	# Compare with [cos(pi), -sin(pi)]
	gradient(x -> sin(x[1]) + cos(x[2]), [pi, pi])

	# Compare with -sin(0.0)
	second_derivative(x -> sin(x), 0.0)
	# Compare with -sin(1.0)
	second_derivative(x -> sin(x), 1.0)
	# Compare with -sin(pi)
	second_derivative(x -> sin(x), pi)

	# Compare with [-sin(0.0) 0.0; 0.0 -cos(0.0)]
	hessian(x -> sin(x[1]) + cos(x[2]), [0.0, 0.0])
	# Compare with [-sin(1.0) 0.0; 0.0 -cos(1.0)]
	hessian(x -> sin(x[1]) + cos(x[2]), [1.0, 1.0])
	# Compare with [-sin(pi) 0.0; 0.0 -cos(pi)]
	hessian(x -> sin(x[1]) + cos(x[2]), [pi, pi])

## Higher-Order Functions

	require("Calculus")
	using Calculus

	g1 = derivative(x -> sin(x))
	g1(0.0)
	g1(1.0)
	g1(pi)

	g2 = gradient(x -> sin(x[1]) + cos(x[2]))
	g2([0.0, 0.0])
	g2([1.0, 1.0])
	g2([pi, pi])

	h1 = second_derivative(x -> sin(x))
	h1(0.0)
	h1(1.0)
	h1(pi)

	h2 = hessian(x -> sin(x[1]) + cos(x[2]))
	h2([0.0, 0.0])
	h2([1.0, 1.0])
	h2([pi, pi])

## Prime Notation

For scalar functions that map R to R, you can use the `'` operator to calculate
derivatives as well. This operator can be used abritratily many times, but you
should keep in mind that the approximation degrades with each approximate
derivative you calculate:

	require("Calculus")
	using Calculus

	f(x) = sin(x)
	f'(1.0) - cos(1.0)
	f''(1.0) - (-sin(1.0))
	f'''(1.0) - (-cos(1.0))

# Coming Soon

* `check_derivative()`
* Finite differencing based on complex numbers

# Credits

Calculus.jl is built on contributions from:

* John Myles White
* Tim Holy
* Andreas Noack Jensen
* Nathaniel Daw
* Blake Johnson

And draws inspiration and ideas from minFunc by:

* Mark Schmidt
