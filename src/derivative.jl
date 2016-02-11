"""
    derivative(f::Function, ftype::Symbol, dtype::Symbol)

### Arg:
* An object of type `Function`
* Input data of type `:scalar` or `:vector`
* Type of finite differencing, must be :forward, :central or :complex

Computes the derivative of the `Function` `f` for the data of type `ftype`. The finite difference method used by default is `:central`. 
"""
function derivative(f::Function, ftype::Symbol, dtype::Symbol)
  if ftype == :scalar
    g(x::Number) = finite_difference(f, float(x), dtype)
  elseif ftype == :vector
    g(x::Vector) = finite_difference(f, float(x), dtype)
  else
    error("ftype must :scalar or :vector")
  end
  return g
end
Compat.@compat derivative{T <: Number}(f::Function, x::Union{T, Vector{T}}, dtype::Symbol = :central) = finite_difference(f, float(x), dtype)
derivative(f::Function, dtype::Symbol = :central) = derivative(f, :scalar, dtype)

Compat.@compat gradient{T <: Number}(f::Function, x::Union{T, Vector{T}}, dtype::Symbol = :central) = finite_difference(f, float(x), dtype)
"""
```
gradient(f::Function, dtype::Symbol = :central)
```

### Args:
* The function for which gradient is required.
* Optional second parameter is the method for finite difference, default is `:central`.
"""
gradient(f::Function, dtype::Symbol = :central) = derivative(f, :vector, dtype)

ctranspose(f::Function) = derivative(f)

"""
```
jacobian{T <: Number}(f::Function, x::Vector{T}, dtype::Symbol)
```

### Args:
* Function `f` to compute the `jacobian` upon.
* Vector `x` with respect to which the jacobian of the function `f` is computed.
* The method of finite difference, `:central`, `:forward` or `:complex`.

`jacobian` computes the Jacobian matrix of function `f` with respect to vector `x`.
"""
function jacobian{T <: Number}(f::Function, x::Vector{T}, dtype::Symbol)
    finite_difference_jacobian(f, x, dtype)
end
function jacobian(f::Function, dtype::Symbol)
    g(x::Vector) = finite_difference_jacobian(f, x, dtype)
    return g
end
jacobian(f::Function) = jacobian(f, :central)

"""
```
second_derivative(f, x, dtype)
```

### Args:
* The function to find the second derivative.
* The data point with respect to which secon derivative is computed. This can either be a scalar or a vector.
* The method of finite difference, `:central`, `:forward` or `:complex`.
"""
second_derivative
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
Compat.@compat function second_derivative{T <: Number}(f::Function, g::Function, x::Union{T, Vector{T}}, dtype::Symbol)
  finite_difference_hessian(f, g, x, dtype)
end

"""
```
hessian(f, x, dtype)
```

### Args:
* Function to find the Hessian.
* `x` can either be type of `Number` or `Vector`.
* The method of finite difference, `:central`, `:forward` or `:complex`.

Computes the Hessian for the function `f` with respect to `x`.
"""
hessian
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
