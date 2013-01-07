@assert isequal(deparse(:(cos(x) + sin(x))), "cos(x) + sin(x)")
@assert isequal(deparse(:(cos(x) + sin(x) + exp(-x))), "cos(x) + sin(x) + exp(-x)")
