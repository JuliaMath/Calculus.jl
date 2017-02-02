"""
```
check_derivative(f::Function, g::Function, x::Number)
```

Function to check the correctness of the derivative `f` based on the actual function `g`, for data points `x`.
"""
function check_derivative(f::Function, g::Function, x::Number)
	auto_g = derivative(f)
	return maximum(abs(g(x) - auto_g(x)))
end

"""
```
check_gradient(f::Function, g::Function, x::Number)
```

Function to check the correctness of the gradient of `f` based on the actual known gradient function `g`,for data points `x`.
"""
function check_gradient{T <: Number}(f::Function, g::Function, x::Vector{T})
	auto_g = gradient(f)
	return maximum(abs(g(x) - auto_g(x)))
end

"""
```
check_second_derivative(f::Function, h::Function, x::Number)
```

Function to check the correctness of the second derivative of `f` based on the actual known second derivative function `h`,for data points `x`.
"""
function check_second_derivative(f::Function, h::Function, x::Number)
	auto_h = second_derivative(f)
	return maximum(abs(h(x) - auto_h(x)))
end

"""
```
check_hessian(f::Function, h::Function, x::Number)
```

Function to check the correctness of the hessian of `f` based on the actual known hessian function `h`,for data points `x`.
"""
function check_hessian{T <: Number}(f::Function, h::Function, x::Vector{T})
	auto_h = hessian(f)
	return maximum(abs(h(x) - auto_h(x)))
end
