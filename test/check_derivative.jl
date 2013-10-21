@test check_derivative(x -> sin(x), x -> cos(x), 0.0) < 10e-4
@test check_derivative(x -> sin(x), x -> cos(x), 1.0) < 10e-4
@test check_derivative(x -> sin(x), x -> cos(x), 10.0) < 10e-4
@test check_derivative(x -> sin(x), x -> cos(x), 100.0) < 10e-4
@test check_derivative(x -> sin(x), x -> cos(x), 1000.0) < 10e-4

@test check_gradient(x -> sin(x[1]) + cos(x[2]), x -> [cos(x[1]), -sin(x[2])], [0.0, 0.0]) < 10e-4
@test check_gradient(x -> sin(x[1]) + cos(x[2]), x -> [cos(x[1]), -sin(x[2])], [1.0, 1.0]) < 10e-4
@test check_gradient(x -> sin(x[1]) + cos(x[2]), x -> [cos(x[1]), -sin(x[2])], [10.0, 10.0]) < 10e-4
@test check_gradient(x -> sin(x[1]) + cos(x[2]), x -> [cos(x[1]), -sin(x[2])], [100.0, 100.0]) < 10e-4
@test check_gradient(x -> sin(x[1]) + cos(x[2]), x -> [cos(x[1]), -sin(x[2])], [1000.0, 1000.0]) < 10e-4

@test check_second_derivative(x -> sin(x), x -> -sin(x), 0.0) < 10e-4
@test check_second_derivative(x -> sin(x), x -> -sin(x), 1.0) < 10e-4
@test check_second_derivative(x -> sin(x), x -> -sin(x), 10.0) < 10e-4
@test check_second_derivative(x -> sin(x), x -> -sin(x), 100.0) < 10e-4
@test check_second_derivative(x -> sin(x), x -> -sin(x), 1000.0) < 10e-4

@test check_hessian(x -> sin(x[1]) + cos(x[2]), x -> [-sin(x[1]) 0.0; 0.0 -cos(x[2])], [0.0, 0.0]) < 10e-4
@test check_hessian(x -> sin(x[1]) + cos(x[2]), x -> [-sin(x[1]) 0.0; 0.0 -cos(x[2])], [1.0, 1.0]) < 10e-4
@test check_hessian(x -> sin(x[1]) + cos(x[2]), x -> [-sin(x[1]) 0.0; 0.0 -cos(x[2])], [10.0, 10.0]) < 10e-4
@test check_hessian(x -> sin(x[1]) + cos(x[2]), x -> [-sin(x[1]) 0.0; 0.0 -cos(x[2])], [100.0, 100.0]) < 10e-4
@test check_hessian(x -> sin(x[1]) + cos(x[2]), x -> [-sin(x[1]) 0.0; 0.0 -cos(x[2])], [1000.0, 1000.0]) < 10e-4
