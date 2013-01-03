#
# derivative()
#

f1(x::Real) = sin(x)
@assert norm(derivative(f1, :scalar, :forward)(0.0) - cos(0.0)) < 10e-4
@assert norm(derivative(f1, :scalar, :central)(0.0) - cos(0.0)) < 10e-4
@assert norm(derivative(f1, :forward)(0.0) - cos(0.0)) < 10e-4
@assert norm(derivative(f1, :central)(0.0) - cos(0.0)) < 10e-4
@assert norm(derivative(f1)(0.0) - cos(0.0)) < 10e-4

f2(x::Vector) = sin(x[1])
@assert norm(derivative(f2, :vector, :forward)([0.0]) - cos(0.0)) < 10e-4
@assert norm(derivative(f2, :vector, :central)([0.0]) - cos(0.0)) < 10e-4

#
# ctranspose overloading
#

f3(x::Real) = sin(x)
for x in linspace(0.0, 0.1, 11) # seq()
	@assert norm(f3'(x) - cos(x)) < 10e-4
end

#
# gradient()
#

f4(x::Vector) = (100.0 - x[1])^2 + (50.0 - x[2])^2
@assert norm(gradient(f4, :forward)([100.0, 50.0]) - [0.0, 0.0]) < 10e-4
@assert norm(gradient(f4, :central)([100.0, 50.0]) - [0.0, 0.0]) < 10e-4
@assert norm(gradient(f4)([100.0, 50.0]) - [0.0, 0.0]) < 10e-4

#
# second_derivative()
#

@assert norm(second_derivative(x -> x^2)(0.0) - 2.0) < 10e-4
@assert norm(second_derivative(x -> x^2)(1.0) - 2.0) < 10e-4
@assert norm(second_derivative(x -> x^2)(10.0) - 2.0) < 10e-4
@assert norm(second_derivative(x -> x^2)(100.0) - 2.0) < 10e-4

#
# hessian()
#

f5(x) = sin(x[1]) + cos(x[2])
@assert norm(gradient(f5)([0.0, 0.0]) - [cos(0.0), -sin(0.0)]) < 10e-4
@assert norm(hessian(f5)([0.0, 0.0]) - [-sin(0.0) 0.0; 0.0 -cos(0.0)]) < 10e-4
