function check_derivative(f, g, x::Number)
    auto_g = derivative(f)
    return maximum(abs.(g(x) - auto_g(x)))
end

function check_gradient(f, g, x::Vector{T}) where T <: Number
    auto_g = gradient(f)
    return maximum(abs.(g(x) - auto_g(x)))
end

function check_second_derivative(f, h, x::Number)
    auto_h = second_derivative(f)
    return maximum(abs.(h(x) - auto_h(x)))
end

function check_hessian(f, h, x::Vector{T}) where T <: Number
    auto_h = hessian(f)
    return maximum(abs.(h(x) - auto_h(x)))
end
