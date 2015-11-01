#
# Derivatives of f: R -> R
#

@test norm(Calculus.finite_difference(x -> x^2, 1.0, :forward) - 2.0) < 10e-4
@test norm(Calculus.finite_difference(x -> x^2, 1.0, :central) - 2.0) < 10e-4
@test norm(Calculus.finite_difference(x -> x^2, 1.0) - 2.0) < 10e-4

@test norm(Calculus.finite_difference(x -> sin(x), 1.0, :forward) - cos(1.0)) < 10e-4
@test norm(Calculus.finite_difference(x -> sin(x), 1.0, :central) - cos(1.0)) < 10e-4
@test norm(Calculus.finite_difference(x -> sin(x), 1.0) - cos(1.0)) < 10e-4

@test norm(Calculus.finite_difference(x -> exp(-x), 1.0, :forward) - (-exp(-1.0))) < 10e-4
@test norm(Calculus.finite_difference(x -> exp(-x), 1.0, :central) - (-exp(-1.0))) < 10e-4
@test norm(Calculus.finite_difference(x -> exp(-x), 1.0) - (-exp(-1.0))) < 10e-4

#
# Gradients of f: R^n -> R
#

@test norm(Calculus.finite_difference(x -> x[1]^2, [1.0], :forward) - [2.0]) < 10e-4
@test norm(Calculus.finite_difference(x -> x[1]^2, [1.0], :central) - [2.0]) < 10e-4
@test norm(Calculus.finite_difference(x -> x[1]^2, [1.0]) - [2.0]) < 10e-4

@test norm(Calculus.finite_difference(x -> sin(x[1]), [1.0], :forward) - [cos(1.0)]) < 10e-4
@test norm(Calculus.finite_difference(x -> sin(x[1]), [1.0], :central) - [cos(1.0)]) < 10e-4
@test norm(Calculus.finite_difference(x -> sin(x[1]), [1.0]) - [cos(1.0)]) < 10e-4

@test norm(Calculus.finite_difference(x -> exp(-x[1]), [1.0], :forward) - [-exp(-1.0)]) < 10e-4
@test norm(Calculus.finite_difference(x -> exp(-x[1]), [1.0], :central) - [-exp(-1.0)]) < 10e-4
@test norm(Calculus.finite_difference(x -> exp(-x[1]), [1.0]) - [-exp(-1.0)]) < 10e-4

#
# Second derivatives of f: R -> R
#

@test norm(Calculus.finite_difference_hessian(x -> x^2, x -> 2 * x, 1.0) - 2.0) < 10e-4
@test norm(Calculus.finite_difference_hessian(x -> x^2, x -> 2 * x, 10.0) - 2.0) < 10e-4
@test norm(Calculus.finite_difference_hessian(x -> x^2, x -> 2 * x, 100.0) - 2.0) < 10e-4

@test norm(Calculus.finite_difference_hessian(x -> x^2, 1.0) - 2.0) < 10e-4
@test norm(Calculus.finite_difference_hessian(x -> x^2, 10.0) - 2.0) < 10e-4
@test norm(Calculus.finite_difference_hessian(x -> x^2, 100.0) - 2.0) < 10e-4

#
# Hessians of f: R^n -> R
#

fx(x) = sin(x[1]) + cos(x[2])
gx = Calculus.gradient(fx)
@test norm(gx([0.0, 0.0]) - [cos(0.0), -sin(0.0)]) < 10e-4
@test norm(Calculus.finite_difference_hessian(fx, gx, [0.0, 0.0], :central) - [-sin(0.0) 0.0; 0.0 -cos(0.0)]) < 10e-4
@test norm(Calculus.finite_difference_hessian(fx, [0.0, 0.0]) - [-sin(0.0) 0.0; 0.0 -cos(0.0)]) < 10e-4

#
# Taylor Series first derivatives
#

@test norm(Calculus.taylor_finite_difference(x -> x^2, 1.0, :forward) - 2.0) < 10e-4
@test norm(Calculus.taylor_finite_difference(x -> x^2, 1.0, :central) - 2.0) < 10e-4

#
# Taylor Series second derivatives
#

# TODO: Fill this in

#
# Speed comparisons
#

@elapsed Calculus.finite_difference(x -> x^2, 1.0, :forward)
@elapsed Calculus.finite_difference(x -> x^2, 1.0, :central)
@elapsed Calculus.finite_difference(x -> x^2, 1.0)
@elapsed Calculus.taylor_finite_difference(x -> x^2, 1.0, :forward, 10e-4)
@elapsed Calculus.taylor_finite_difference(x -> x^2, 1.0, :central, 10e-4)
