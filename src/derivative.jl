function derivative(f, ftype::Symbol, dtype::Symbol)
  if ftype == :scalar
    return x::Number -> finite_difference(f, float(x), dtype)
  elseif ftype == :vector
    return x::Vector -> finite_difference(f, float(x), dtype)
  else
    error("ftype must :scalar or :vector")
  end
end
derivative(f, x::Union{T, Vector{T}}, dtype::Symbol = :central) where {T <: Number} = finite_difference(f, float(x), dtype)
derivative(f, dtype::Symbol = :central) = derivative(f, :scalar, dtype)

gradient(f, x::Union{T, Vector{T}}, dtype::Symbol = :central) where {T <: Number} = finite_difference(f, float(x), dtype)
gradient(f, dtype::Symbol = :central) = derivative(f, :vector, dtype)

function jacobian(f, x::Vector{T}, dtype::Symbol) where T <: Number
    finite_difference_jacobian(f, x, dtype)
end
function jacobian(f, dtype::Symbol)
    g(x::Vector) = finite_difference_jacobian(f, x, dtype)
    return g
end
jacobian(f) = jacobian(f, :central)

function second_derivative(f, g, ftype::Symbol, dtype::Symbol)
  if ftype == :scalar
    return x::Number -> finite_difference_hessian(f, g, x, dtype)
  elseif ftype == :vector
    return x::Vector -> finite_difference_hessian(f, g, x, dtype)
  else
    error("ftype must :scalar or :vector")
  end
end
function second_derivative(f, g, x::Union{T, Vector{T}}, dtype::Symbol) where T <: Number
  finite_difference_hessian(f, g, x, dtype)
end
function hessian(f, g, x::Union{T, Vector{T}}, dtype::Symbol) where T <: Number
  finite_difference_hessian(f, g, x, dtype)
end
function second_derivative(f, g, x::Union{T, Vector{T}}) where T <: Number
  finite_difference_hessian(f, g, x, :central)
end
function hessian(f, g, x::Union{T, Vector{T}}) where T <: Number
  finite_difference_hessian(f, g, x, :central)
end
function second_derivative(f, x::Number, dtype::Symbol)
  finite_difference_hessian(f, derivative(f), x, dtype)
end
function hessian(f, x::Number, dtype::Symbol)
  finite_difference_hessian(f, derivative(f), x, dtype)
end
function second_derivative(f, x::Vector{T}, dtype::Symbol) where T <: Number
  finite_difference_hessian(f, gradient(f), x, dtype)
end
function hessian(f, x::Vector{T}, dtype::Symbol) where T <: Number
  finite_difference_hessian(f, gradient(f), x, dtype)
end
function second_derivative(f, x::Number)
  finite_difference_hessian(f, derivative(f), x, :central)
end
function hessian(f, x::Number)
  finite_difference_hessian(f, derivative(f), x, :central)
end
function second_derivative(f, x::Vector{T}) where T <: Number
  finite_difference_hessian(f, gradient(f), x, :central)
end
function hessian(f, x::Vector{T}) where T <: Number
  finite_difference_hessian(f, gradient(f), x, :central)
end
second_derivative(f, g, dtype::Symbol) = second_derivative(f, g, :scalar, dtype)
second_derivative(f, g) = second_derivative(f, g, :scalar, :central)
second_derivative(f) = second_derivative(f, derivative(f), :scalar, :central)
hessian(f, g, dtype::Symbol) = second_derivative(f, g, :vector, dtype)
hessian(f, g) = second_derivative(f, g, :vector, :central)
hessian(f) = second_derivative(f, gradient(f), :vector, :central)
