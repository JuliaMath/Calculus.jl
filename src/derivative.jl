function derivative(f, ftype::Symbol, dtype::Symbol)
  if ftype == :scalar
    return x::Number -> finite_difference(f, float(x), dtype)
  elseif ftype == :vector
    return x::Vector -> finite_difference(f, float(x), dtype)
  else
    error("ftype must :scalar or :vector")
  end
end
Compat.@compat derivative{T <: Number}(f, x::Union{T, Vector{T}}, dtype::Symbol = :central) = finite_difference(f, float(x), dtype)
derivative(f, dtype::Symbol = :central) = derivative(f, :scalar, dtype)

Compat.@compat gradient{T <: Number}(f, x::Union{T, Vector{T}}, dtype::Symbol = :central) = finite_difference(f, float(x), dtype)
gradient(f, dtype::Symbol = :central) = derivative(f, :vector, dtype)

Compat.@compat function Base.gradient{T <: Number}(f, x::Union{T, Vector{T}}, dtype::Symbol = :central)
    Base.warn_once("The finite difference methods from Calculus.jl no longer extend Base.gradient and should be called as Calculus.gradient instead. This usage is deprecated.")
    Calculus.gradient(f,x,dtype)
end

function Base.gradient(f, dtype::Symbol = :central)
    Base.warn_once("The finite difference methods from Calculus.jl no longer extend Base.gradient and should be called as Calculus.gradient instead. This usage is deprecated.")
    Calculus.gradient(f,dtype)
end

if isdefined(Base, :adjoint)
    Base.adjoint(f::Function) = derivative(f)
else
    Base.ctranspose(f::Function) = derivative(f)
end

function jacobian{T <: Number}(f, x::Vector{T}, dtype::Symbol)
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
Compat.@compat function second_derivative{T <: Number}(f, g, x::Union{T, Vector{T}}, dtype::Symbol)
  finite_difference_hessian(f, g, x, dtype)
end
Compat.@compat function hessian{T <: Number}(f, g, x::Union{T, Vector{T}}, dtype::Symbol)
  finite_difference_hessian(f, g, x, dtype)
end
Compat.@compat function second_derivative{T <: Number}(f, g, x::Union{T, Vector{T}})
  finite_difference_hessian(f, g, x, :central)
end
Compat.@compat function hessian{T <: Number}(f, g, x::Union{T, Vector{T}})
  finite_difference_hessian(f, g, x, :central)
end
function second_derivative(f, x::Number, dtype::Symbol)
  finite_difference_hessian(f, derivative(f), x, dtype)
end
function hessian(f, x::Number, dtype::Symbol)
  finite_difference_hessian(f, derivative(f), x, dtype)
end
function second_derivative{T <: Number}(f, x::Vector{T}, dtype::Symbol)
  finite_difference_hessian(f, gradient(f), x, dtype)
end
function hessian{T <: Number}(f, x::Vector{T}, dtype::Symbol)
  finite_difference_hessian(f, gradient(f), x, dtype)
end
function second_derivative(f, x::Number)
  finite_difference_hessian(f, derivative(f), x, :central)
end
function hessian(f, x::Number)
  finite_difference_hessian(f, derivative(f), x, :central)
end
function second_derivative{T <: Number}(f, x::Vector{T})
  finite_difference_hessian(f, gradient(f), x, :central)
end
function hessian{T <: Number}(f, x::Vector{T})
  finite_difference_hessian(f, gradient(f), x, :central)
end
second_derivative(f, g, dtype::Symbol) = second_derivative(f, g, :scalar, dtype)
second_derivative(f, g) = second_derivative(f, g, :scalar, :central)
second_derivative(f) = second_derivative(f, derivative(f), :scalar, :central)
hessian(f, g, dtype::Symbol) = second_derivative(f, g, :vector, dtype)
hessian(f, g) = second_derivative(f, g, :vector, :central)
hessian(f) = second_derivative(f, gradient(f), :vector, :central)
