function derivative(f::Function, ftype::Symbol, dtype::Symbol)
  if ftype == :scalar
    return x::Number -> finite_difference(f, float(x), dtype)
  elseif ftype == :vector
    return x::Vector -> finite_difference(f, float(x), dtype)
  else
    error("ftype must :scalar or :vector")
  end
end
Compat.@compat derivative{T <: Number}(f::Function, x::Union{T, Vector{T}}, dtype::Symbol = :central) = finite_difference(f, float(x), dtype)
derivative(f::Function, dtype::Symbol = :central) = derivative(f, :scalar, dtype)

Compat.@compat gradient{T <: Number}(f::Function, x::Union{T, Vector{T}}, dtype::Symbol = :central) = finite_difference(f, float(x), dtype)
gradient(f::Function, dtype::Symbol = :central) = derivative(f, :vector, dtype)

Compat.@compat function Base.gradient{T <: Number}(f::Function, x::Union{T, Vector{T}}, dtype::Symbol = :central)
    Base.warn_once("The finite difference methods from Calculus.jl no longer extend Base.gradient and should be called as Calculus.gradient instead. This usage is deprecated.")
    Calculus.gradient(f,x,dtype)
end

function Base.gradient(f::Function, dtype::Symbol = :central)
    Base.warn_once("The finite difference methods from Calculus.jl no longer extend Base.gradient and should be called as Calculus.gradient instead. This usage is deprecated.")
    Calculus.gradient(f,dtype)
end

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
    return x::Number -> finite_difference_hessian(f, g, x, dtype)
  elseif ftype == :vector
    return x::Vector -> finite_difference_hessian(f, g, x, dtype)
  else
    error("ftype must :scalar or :vector")
  end
end
Compat.@compat function second_derivative{T <: Number}(f::Function, g::Function, x::Union{T, Vector{T}}, dtype::Symbol)
  finite_difference_hessian(f, g, x, dtype)
end
Compat.@compat function hessian{T <: Number}(f::Function, g::Function, x::Union{T, Vector{T}}, dtype::Symbol)
  finite_difference_hessian(f, g, x, dtype)
end
Compat.@compat function second_derivative{T <: Number}(f::Function, g::Function, x::Union{T, Vector{T}})
  finite_difference_hessian(f, g, x, :central)
end
Compat.@compat function hessian{T <: Number}(f::Function, g::Function, x::Union{T, Vector{T}})
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
