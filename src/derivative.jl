function derivative(f::Function, ftype::Symbol, dtype::Symbol)
  if ftype == :scalar
    g(x::Number) = finite_difference(f, x, dtype)
  elseif ftype == :vector
    g(x::Vector) = finite_difference(f, x, dtype)
  else
    error("ftype must :scalar or :vector")
  end
  return g
end
derivative{T <: Number}(f::Function, x::Union(T, Vector{T}), dtype::Symbol) = finite_difference(f, x, dtype)
derivative{T <: Number}(f::Function, x::Union(T, Vector{T})) = finite_difference(f, x, :central)
derivative(f::Function, dtype::Symbol) = derivative(f, :scalar, dtype)
derivative(f::Function) = derivative(f, :scalar, :central)

gradient(f::Function, dtype::Symbol) = derivative(f, :vector, dtype)
gradient{T <: Number}(f::Function, x::Union(T, Vector{T}), dtype::Symbol) = finite_difference(f, x, dtype)
gradient(f::Function) = derivative(f, :vector, :central)
gradient{T <: Number}(f::Function, x::Union(T, Vector{T})) = finite_difference(f, x, :central)

ctranspose(f::Function) = derivative(f)

function jacobian{T <: Number}(f::Function, x::Vector{T}, dtype::Symbol)
    finite_difference_jacobian(f, x, dtype)
end
function jacobian(f::Function, dtype::Symbol)
    g(x::Vector) = finite_difference_jacobian(f, x, dtype)
    return g
end
jacobian(f::Function) = jacobian(f, :central)

function second_derivative(f::Function, g::Function, ftype::Symbol, dtype::Symbol)
  if ftype == :scalar
    h(x::Number) = finite_difference_hessian(f, g, x, dtype)
  elseif ftype == :vector
    h(x::Vector) = finite_difference_hessian(f, g, x, dtype)
  else
    error("ftype must :scalar or :vector")
  end
  return h
end
function second_derivative{T <: Number}(f::Function, g::Function, x::Union(T, Vector{T}), dtype::Symbol)
  finite_difference_hessian(f, g, x, dtype)
end
function hessian{T <: Number}(f::Function, g::Function, x::Union(T, Vector{T}), dtype::Symbol)
  finite_difference_hessian(f, g, x, dtype)
end
function second_derivative{T <: Number}(f::Function, g::Function, x::Union(T, Vector{T}))
  finite_difference_hessian(f, g, x, :central)
end
function hessian{T <: Number}(f::Function, g::Function, x::Union(T, Vector{T}))
  finite_difference_hessian(f, g, x, :central)
end
function second_derivative(f::Function, x::Number, dtype::Symbol)
  finite_difference_hessian(f, derivative(f), x, dtype)
end
function hessian(f::Function, x::Number, dtype::Symbol)
  finite_difference_hessian(f, derivative(f), x, dtype)
end
function second_derivative{T <: Number}(f::Function, x::Vector{T}, dtype::Symbol)
  finite_difference_hessian(f, gradient(f), x, dtype)
end
function hessian{T <: Number}(f::Function, x::Vector{T}, dtype::Symbol)
  finite_difference_hessian(f, gradient(f), x, dtype)
end
function second_derivative(f::Function, x::Number)
  finite_difference_hessian(f, derivative(f), x, :central)
end
function hessian(f::Function, x::Number)
  finite_difference_hessian(f, derivative(f), x, :central)
end
function second_derivative{T <: Number}(f::Function, x::Vector{T})
  finite_difference_hessian(f, gradient(f), x, :central)
end
function hessian{T <: Number}(f::Function, x::Vector{T})
  finite_difference_hessian(f, gradient(f), x, :central)
end
second_derivative(f::Function, g::Function, dtype::Symbol) = second_derivative(f, g, :scalar, dtype)
second_derivative(f::Function, g::Function) = second_derivative(f, g, :scalar, :central)
second_derivative(f::Function) = second_derivative(f, derivative(f), :scalar, :central)
hessian(f::Function, g::Function, dtype::Symbol) = second_derivative(f, g, :vector, dtype)
hessian(f::Function, g::Function) = second_derivative(f, g, :vector, :central)
hessian(f::Function) = second_derivative(f, gradient(f), :vector, :central)
