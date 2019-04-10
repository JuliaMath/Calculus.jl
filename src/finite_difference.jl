##############################################################################
##
## Graveyard of Alternative Functions
##
## The proper setting of epsilon depends on whether we're doing central
##  differencing or forward differencing. See, for example, section 5.7 of
##  Numerical Recipes.
##
##############################################################################

##############################################################################
##
## Derivative of f: C -> R
##
##############################################################################

macro forwardrule(x, e)
    x, e = esc(x), esc(e)
    quote
        $e = sqrt(eps($x^2))
    end
end

macro centralrule(x, e)
    x, e = esc(x), esc(e)
    quote
        $e = cbrt(eps($x^3))
    end
end

macro hessianrule(x, e)
    x, e = esc(x), esc(e)
    quote
        $e = eps($x^4)^(1/4)
    end
end

macro complexrule(x, e)
    x, e = esc(x), esc(e)
    quote
        $e = eps($x)
    end
end

function finite_difference(f,
                           x::T,
                           dtype::Symbol = :central) where T <: Number
    if dtype == :forward
        @forwardrule x epsilon
        xplusdx = x + epsilon
        return (f(xplusdx) - f(x)) / epsilon
    elseif dtype == :central
        @centralrule x epsilon
        xplusdx, xminusdx = x + epsilon, x - epsilon
        return (f(xplusdx) - f(xminusdx)) / (epsilon + epsilon)
    elseif dtype == :complex
        @complexrule x epsilon
        xplusdx = x + epsilon * im
        return imag(f(xplusdx)) / epsilon
    else
        error("dtype must be :forward, :central or :complex")
    end
end

##############################################################################
##
## Complex Step Finite Differentiation Tools
##
## Martins, Sturdza, and Alonso (2003) suggest the only non-analytic
##  fuction of which complex step finite difference approximation
##  will fail and finite difference will not is abs().
##  They suggest redefining as follows for z = x + im*y
##
##  if x < 0
##      -x - im * y
##  else
##      x + im * y
##
## This is provided below as complex_differentiable_abs (renaming encouraged!)
##
## Also, if your fuctions has control flow using < or >, you must compare
## real(z) for your control flow.
##
##############################################################################

function complex_differentiable_abs(z::T) where T <: Complex
    if real(z) < 0
        return -real(z) - im * imag(z)
    else
        return real(z) + im * imag(z)
    end
end

##############################################################################
##
## Gradient of f: R^n -> R
##
##############################################################################

function finite_difference!(f,
                            x::AbstractVector{S},
                            g::AbstractVector{T},
                            dtype::Symbol) where {S <: Number, T <: Number}
    # What is the dimension of x?
    n = length(x)

    # Iterate over each dimension of the gradient separately.
    # Use xplusdx to store x + dx instead of creating a new AbstractVector on each pass.
    # Use xminusdx to store x - dx instead of creating a new AbstractVector on each pass.
    if dtype == :forward
        # Establish a baseline value of f(x).
        f_x = f(x)
        for i = 1:n
            @forwardrule x[i] epsilon
            oldx = x[i]
            x[i] = oldx + epsilon
            f_xplusdx = f(x)
            x[i] = oldx
            g[i] = (f_xplusdx - f_x) / epsilon
        end
    elseif dtype == :central
        for i = 1:n
            @centralrule x[i] epsilon
            oldx = x[i]
            x[i] = oldx + epsilon
            f_xplusdx = f(x)
            x[i] = oldx - epsilon
            f_xminusdx = f(x)
            x[i] = oldx
            g[i] = (f_xplusdx - f_xminusdx) / (epsilon + epsilon)
        end
    else
        error("dtype must be :forward or :central")
    end

    return
end
function finite_difference(f,
                           x::AbstractVector{T},
                           dtype::Symbol = :central) where T <: Number
    # Allocate memory for gradient
    g = Vector{Float64}(undef, length(x))

    # Mutate allocated gradient
    finite_difference!(f, float(x), g, dtype)

    # Return mutated gradient
    return g
end

##############################################################################
##
## Jacobian derivative of f: R^n -> R^m
##
##############################################################################

function finite_difference_jacobian!(f,
                                     x::AbstractVector{R},
                                     f_x::AbstractVector{S},
                                     J::Array{T},
                                     dtype::Symbol = :central) where {R <: Number,
                                                                    S <: Number,
                                                                    T <: Number}
    # What is the dimension of x?
    m, n = size(J)

    # Iterate over each dimension of the gradient separately.
    if dtype == :forward
        shifted_x = copy(x)
        for i = 1:n
            @forwardrule x[i] epsilon
            shifted_x[i] += epsilon
            J[:, i] = (f(shifted_x) - f_x) / epsilon
            shifted_x[i] = x[i]
        end
    elseif dtype == :central
        shifted_x_plus = copy(x)
        shifted_x_minus = copy(x)
        for i = 1:n
            @centralrule x[i] epsilon
            shifted_x_plus[i] += epsilon
            shifted_x_minus[i] -= epsilon
            J[:, i] = (f(shifted_x_plus) - f(shifted_x_minus)) / (epsilon + epsilon)
            shifted_x_plus[i] = x[i]
            shifted_x_minus[i] = x[i]
        end
    else
        error("dtype must :forward or :central")
    end

    return
end
function finite_difference_jacobian(f,
                                    x::AbstractVector{T},
                                    dtype::Symbol = :central) where T <: Number
    # Establish a baseline for f_x
    f_x = f(x)

    # Allocate space for the Jacobian matrix
    J = zeros(length(f_x), length(x))

    # Compute Jacobian inside allocated matrix
    finite_difference_jacobian!(f, x, f_x, J, dtype)

    # Return Jacobian
    return J
end

##############################################################################
##
## Second derivative of f: R -> R
##
##############################################################################

function finite_difference_hessian(f,
                                   x::T) where T <: Number
    @hessianrule x epsilon
    (f(x + epsilon) - 2*f(x) + f(x - epsilon))/epsilon^2
end
function finite_difference_hessian(f,
                                   g,
                                   x::Number,
                                   dtype::Symbol = :central)
    finite_difference(g, x, dtype)
end

##############################################################################
##
## Hessian of f: R^n -> R
##
##############################################################################

function finite_difference_hessian!(f,
                                    H::Array{T},
                                    x::AbstractVector{S}) where {S <: Number,
                                                        T <: Number}
    n = size(H)[1]
    e(j) = [i == j for i in 1:n]      # j-th basis vector
    hⱼ, hₖ = NaN, NaN
    f₀ = f(x)
    for j = 1:n 
        @hessianrule x[j] hⱼ # According to Numerical Recipes 5.7
        f₊  = f(x + hⱼ * e(j))
        f₋  = f(x - hⱼ * e(j))
        H[j,j] = (f₋ - 2f₀ + f₊) / hⱼ^2
        for k = j+1:n # Off-diagonal terms
            @hessianrule x[k] hₖ # According to Numerical Recipes 5.7
            f₊₊ = f(x + hⱼ * e(j) + hₖ * e(k))
            f₊₋ = f(x + hⱼ * e(j) - hₖ * e(k))
            f₋₊ = f(x - hⱼ * e(j) + hₖ * e(k))
            f₋₋ = f(x - hⱼ * e(j) - hₖ * e(k))
            H[j,k] = (f₊₊ - f₋₊ - f₊₋ + f₋₋) / (4 * hⱼ * hₖ)
            j ≠ k ? H[k,j] = H[j,k] : nothing
        end
    end
    return H
end

function finite_difference_hessian(f,
                                   x::AbstractVector{T}) where T <: Number
    # What is the dimension of x?
    n = length(x)

    # Allocate an empty Hessian
    H = Matrix{Float64}(undef, n, n)

    # Mutate the allocated Hessian
    finite_difference_hessian!(f, H, x)

    # Return the Hessian
    return H
end
function finite_difference_hessian(f,
                                   g,
                                   x::AbstractVector{T},
                                   dtype::Symbol = :central) where T <: Number
    finite_difference_jacobian(g, x, dtype)
end

##############################################################################
##
## Taylor Series based estimates of first and second derivatives
##
## TODO: Fill in multivariate equivalents
##
##############################################################################

# Higher precise finite difference method based on Taylor series approximation.
# h is the stepsize
function taylor_finite_difference(f,
                                  x::Real,
                                  dtype::Symbol = :central,
                                  h::Real = 10e-4)
    if dtype == :forward
        f_x = f(x)
        d = 2^3 * (2^2 * (f(x + h) - f_x) - (f(x + 2 * h) - f_x))
        d += - (2^2 * (f(x + 2 * h) - f_x) - (f(x + 4 * h) - f_x))
        d /= 3 * 2^2 * h
    elseif dtype == :central
        d = 4^5 * (2^3 * (f(x + h) - f(x - h)) - (f(x + 2 * h) - f(x - 2 * h)))
        d -= 2^3 * (f(x + 4 * h) - f(x - 4 * h)) - (f(x + 8 * h) - f(x - 8 * h))
        d /= (4^5 * (2^4 - 2^2) - (2^6 - 2^4)) * h
    else
        error("dtype must be :forward or :central")
    end
    return d
end

function taylor_finite_difference_hessian(f,
                                          x::Real,
                                          h::Real)
    f_x = f(x)
    d = 4^6 * (2^4 * (f(x + h) + f(x - h) - 2 * f_x) - (f(x + 2 * h) + f(x - 2 * h) - 2 * f_x))
    d += - (2^4 * (f(x + 4 * h) + f(x - 4 * h) - 2 * f_x) - (f(x + 8 * h) + f(x - 8 * h) - 2 * f_x))
    return d / (3 * 2^6 * (2^8 - 1) * h^2)
end

##############################################################################
##
## TODO: Implement directional_derivative()
##
##############################################################################

# The function "dirderivative" calculates directional derivatives in the direction v.
# function dirderivative(f, v::AbstractVector{Float64}, x0::AbstractVector{Float64}, h::Float64, twoside::Bool)
#     derivative(t::Float64 -> f(x0 + v*t) / norm(v), 0.0, h, twoside)
# end
# function dirderivative(f, v::AbstractVector{Float64}, x0::AbstractVector{Float64}, h::Float64)
#     dirderivative(f, v, x0, h, true)
# end
# function dirderivative(f, v::AbstractVector{Float64}, x0::AbstractVector{Float64}, )
#     derivative(f, v, x0, 0.0001)
# end
# function dirderivative(f, v::AbstractVector{Float64})
#     x -> dirderivative(f, v, x)
# end
