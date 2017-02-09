Compat.@compat function check_derivative(f::Function, g::Function, x::Number)
    auto_g = derivative(f)
    return maximum(abs.(g(x) - auto_g(x)))
end

Compat.@compat function check_gradient{T <: Number}(f::Function, g::Function, x::Vector{T})
    auto_g = gradient(f)
    return maximum(abs.(g(x) - auto_g(x)))
end

Compat.@compat function check_second_derivative(f::Function, h::Function, x::Number)
    auto_h = second_derivative(f)
    return maximum(abs.(h(x) - auto_h(x)))
end

Compat.@compat function check_hessian{T <: Number}(f::Function, h::Function, x::Vector{T})
    auto_h = hessian(f)
    return maximum(abs.(h(x) - auto_h(x)))
end
