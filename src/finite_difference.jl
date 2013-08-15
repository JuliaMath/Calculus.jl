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

macro forwardrule(x, T, e)
    x, T, e = esc(x), esc(T), esc(e)
    quote
        $e = sqrt(eps($T)) * max(one($T), abs($x))
    end
end

macro centralrule(x, T, e)
    x, T, e = esc(x), esc(T), esc(e)
    quote
        $e = cbrt(eps($T)) * max(one($T), abs($x))
    end
end

macro hessianrule(x, T, e)
    x, T, e = esc(x), esc(T), esc(e)
    quote
        $e = eps($T)^(1/4) * max(one($T), abs($x))
    end
end

macro complexrule(x, T, e)
    x, T, e = esc(x), esc(T), esc(e)
    quote
        $e = eps($x)
    end
end

function finite_difference{T <: Number}(f::Function,
                                        x::T,
                                        dtype::Symbol = :central)
    if dtype == :forward
        @forwardrule x T epsilon
        xplusdx = x + epsilon
        return (f(xplusdx) - f(x)) / epsilon
    elseif dtype == :central
        @centralrule x T epsilon
        xplusdx, xminusdx = x + epsilon, x - epsilon
        return (f(xplusdx) - f(xminusdx)) / (epsilon + epsilon)
    elseif dtype == :complex
        @complexrule x T epsilon
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

function complex_differentiable_abs{T <: Complex}(z::T)
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

function finite_difference!{S <: Number, T <: Number}(f::Function,
                                                      x::Vector{S},
                                                      g::Vector{T},
                                                      dtype::Symbol)
    # What is the dimension of x?
    n = length(x)

    # Iterate over each dimension of the gradient separately.
    # Use xplusdx to store x + dx instead of creating a new vector on each pass.
    # Use xminusdx to store x - dx instead of creating a new vector on each pass.
    if dtype == :forward
        # Establish a baseline value of f(x).
        f_x = f(x)
        for i = 1:n
            @forwardrule x[i] S epsilon
            oldx = x[i]
            x[i] = oldx + epsilon
            f_xplusdx = f(x)
            x[i] = oldx
            g[i] = (f_xplusdx - f_x) / epsilon
        end
    elseif dtype == :central
        for i = 1:n
            @centralrule x[i] S epsilon
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
function finite_difference{T <: Number}(f::Function,
                                        x::Vector{T},
                                        dtype::Symbol = :central)
    # Allocate memory for gradient
    g = Array(Float64, length(x))

    # Mutate allocated gradient
    finite_difference!(f, x, g, dtype)

    # Return mutated gradient
    return g
end

##############################################################################
##
## Jacobian derivative of f: R^n -> R^m
##
##############################################################################

function finite_difference_jacobian!{R <: Number,
                                     S <: Number,
                                     T <: Number}(f::Function,
                                                  x::Vector{R},
                                                  f_x::Vector{S},
                                                  J::Array{T},
                                                  dtype::Symbol = :central)
    # What is the dimension of x?
    m, n = size(J)

    # Iterate over each dimension of the gradient separately.
    if dtype == :forward
        for i = 1:n
            @forwardrule x[i] R epsilon
            oldx = x[i]
            x[i] = oldx + epsilon
            f_xplusdx = f(x)
            x[i] = oldx
            J[:, i] = (f_xplusdx - f_x) / epsilon
        end
    elseif dtype == :central
        for i = 1:n
            @centralrule x[i] R epsilon
            oldx = x[i]
            x[i] = oldx + epsilon
            f_xplusdx = f(x)
            x[i] = oldx - epsilon
            f_xminusdx = f(x)
            x[i] = oldx
            J[:, i] = (f_xplusdx - f_xminusdx) / (epsilon + epsilon)
        end
    else
        error("dtype must :forward or :central")
    end

    return
end
function finite_difference_jacobian{T <: Number}(f::Function,
                                                 x::Vector{T},
                                                 dtype::Symbol = :central)
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

function finite_difference_hessian{T <: Number}(f::Function,
                                                x::T)
    @hessianrule x T epsilon
    (f(x + epsilon) - 2*f(x) + f(x - epsilon))/epsilon^2
end
function finite_difference_hessian(f::Function,
                                   g::Function,
                                   x::Number,
                                   dtype::Symbol = :central)
    finite_difference(g, x, dtype)
end

##############################################################################
##
## Hessian of f: R^n -> R
##
##############################################################################

function finite_difference_hessian!{S <: Number,
                                    T <: Number}(f::Function,
                                                 x::Vector{S},
                                                 H::Array{T})
    # What is the dimension of x?
    n = length(x)

    epsilon = NaN
    # TODO: Remove all these copies
    xpp, xpm, xmp, xmm = copy(x), copy(x), copy(x), copy(x)
    fx = f(x)
    for i = 1:n
        xi = x[i]
        @hessianrule x[i] S epsilon
        xpp[i], xmm[i] = xi + epsilon, xi - epsilon
        H[i, i] = (f(xpp) - 2*fx + f(xmm)) / epsilon^2
        @centralrule x[i] S epsiloni
        xp = xi + epsiloni
        xm = xi - epsiloni
        xpp[i], xpm[i], xmp[i], xmm[i] = xp, xp, xm, xm
        for j = i+1:n
            xj = x[j]
            @centralrule x[j] S epsilonj
            xp = xj + epsilonj
            xm = xj - epsilonj
            xpp[j], xpm[j], xmp[j], xmm[j] = xp, xm, xp, xm
            H[i, j] = (f(xpp) - f(xpm) - f(xmp) + f(xmm))/(4*epsiloni*epsilonj)
            xpp[j], xpm[j], xmp[j], xmm[j] = xj, xj, xj, xj
        end
        xpp[i], xpm[i], xmp[i], xmm[i] = xi, xi, xi, xi
    end
    symmetrize!(H)
end
function finite_difference_hessian{T <: Number}(f::Function,
                                                x::Vector{T})
    # What is the dimension of x?
    n = length(x)

    # Allocate an empty Hessian
    H = Array(Float64, n, n)

    # Mutate the allocated Hessian
    finite_difference_hessian!(f, x, H)

    # Return the Hessian
    return H
end
function finite_difference_hessian{T <: Number}(f::Function,
                                                g::Function,
                                                x::Vector{T},
                                                dtype::Symbol = :central)
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
function taylor_finite_difference(f::Function,
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

function taylor_finite_difference_hessian(f::Function,
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
# The function supplied must have the form Vector{Float64} -> Float64
# function dirderivative(f::Function, v::Vector{Float64}, x0::Vector{Float64}, h::Float64, twoside::Bool)
#     derivative(t::Float64 -> f(x0 + v*t) / norm(v), 0.0, h, twoside)
# end
# function dirderivative(f::Function, v::Vector{Float64}, x0::Vector{Float64}, h::Float64)
#     dirderivative(f, v, x0, h, true)
# end
# function dirderivative(f::Function, v::Vector{Float64}, x0::Vector{Float64}, )
#     derivative(f, v, x0, 0.0001)
# end
# function dirderivative(f::Function, v::Vector{Float64})
#     x -> dirderivative(f, v, x)
# end
