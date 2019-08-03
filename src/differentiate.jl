export differentiate

#################################################################
#
# differentiate()
#   based on John's differentiate and this code, I think by Miles Lubin:
#     https://github.com/IainNZ/NLTester/blob/master/julia/nlp.jl#L74
#
#################################################################

differentiate(ex::SymbolicVariable, wrt::SymbolicVariable) = (ex == wrt) ? 1 : 0

differentiate(ex::Number, wrt::SymbolicVariable) = 0

function differentiate(ex::Expr,wrt)
    if ex.head != :call
        error("Unrecognized expression $ex")
    end
    # TODO: When simplify no longer calls eval, simplify the result.
    differentiate(SymbolParameter(ex.args[1]), ex.args[2:end], wrt)
end

differentiate(x::SymbolParameter{T}, args, wrt) where {T} = error("Derivative of function " * string(T) * " not supported")

# The Power Rule:
function differentiate(::SymbolParameter{:^}, args, wrt)
    x = args[1]
    y = args[2]
    xp = differentiate(x, wrt)
    yp = differentiate(y, wrt)
    if xp == 0 && yp == 0
        return 0
    elseif yp == 0
        return :( $y * $xp * ($x ^ ($y - 1)) )
    else
        return :( $x ^ $y * ($xp * $y / $x + $yp * log($x)) )
    end
end

function differentiate(::SymbolParameter{:+}, args, wrt)
    termdiffs = Any[:+]
    for y in args
        x = differentiate(y, wrt)
        if x != 0
            push!(termdiffs, x)
        end
    end
    if (length(termdiffs) == 1)
        return 0
    elseif (length(termdiffs) == 2)
        return termdiffs[2]
    else
        return Expr(:call, termdiffs...)
    end
end

function differentiate(::SymbolParameter{:-}, args, wrt)
    termdiffs = Any[:-]
    # first term is special, can't be dropped
    term1 = differentiate(args[1], wrt)
    push!(termdiffs, term1)
    for y in args[2:end]
        x = differentiate(y, wrt)
        if x != 0
            push!(termdiffs, x)
        end
    end
    if term1 != 0 && length(termdiffs) == 2 && length(args) >= 2
        # if all of the terms but the first disappeared, we just return the first
        return term1
    elseif (term1 == 0 && length(termdiffs) == 2)
        return 0
    else
        return Expr(:call, termdiffs...)
    end
end

# The Product Rule
# d/dx (f * g) = (d/dx f) * g + f * (d/dx g)
# d/dx (f * g * h) = (d/dx f) * g * h + f * (d/dx g) * h + ...
function differentiate(::SymbolParameter{:*}, args, wrt)
    n = length(args)
    res_args = Vector{Any}(undef, n)
    for i in 1:n
       new_args = Vector{Any}(undef, n)
       for j in 1:n
           if j == i
               new_args[j] = differentiate(args[j], wrt)
           else
               new_args[j] = args[j]
           end
       end
       res_args[i] = Expr(:call, :*, new_args...)
    end
    return Expr(:call, :+, res_args...)
end

# The Quotient Rule
# d/dx (f / g) = ((d/dx f) * g - f * (d/dx g)) / g^2
function differentiate(::SymbolParameter{:/}, args, wrt)
    x = args[1]
    y = args[2]
    xp = differentiate(x, wrt)
    yp = differentiate(y, wrt)
    if xp == 0 && yp == 0
        return 0
    elseif xp == 0
        return :( -$yp * $x / $y^2 )
    elseif yp == 0
        return :( $xp / $y )
    else
        return :( ($xp * $y - $x * $yp) / $y^2 )
    end
end

symbolic_derivative_1arg_list = [
    ( :sqrt,        :(  1 / 2 / sqrt(x)                         ))
    ( :cbrt,        :(  1 / 3 / cbrt(x)^2                       ))
    ( :abs2,        :(  1 * 2 * x                               ))
    ( :inv,         :( -1 * abs2(inv(x))                        ))
    ( :log,         :(  1 / x                                   ))
    ( :log10,       :(  1 / x / log(10)                         ))
    ( :log2,        :(  1 / x / log(2)                          ))
    ( :log1p,       :(  1 / (x + 1)                             ))
    ( :exp,         :(  exp(x)                                  ))
    ( :exp2,        :(  log(2) * exp2(x)                        ))
    ( :expm1,       :(  exp(x)                                  ))
    ( :sin,         :(  cos(x)                                  ))
    ( :cos,         :( -sin(x)                                  ))
    ( :tan,         :(  (1 + tan(x)^2)                          ))
    ( :sec,         :(  sec(x) * tan(x)                         ))
    ( :csc,         :( -csc(x) * cot(x)                         ))
    ( :cot,         :( -(1 + cot(x)^2)                          ))
    ( :sind,        :(  pi / 180 * cosd(x)                      ))
    ( :cosd,        :( -pi / 180 * sind(x)                      ))
    ( :tand,        :(  pi / 180 * (1 + tand(x)^2)              ))
    ( :secd,        :(  pi / 180 * secd(x) * tand(x)            ))
    ( :cscd,        :( -pi / 180 * cscd(x) * cotd(x)            ))
    ( :cotd,        :( -pi / 180 * (1 + cotd(x)^2)              ))
    ( :asin,        :(  1 / sqrt(1 - x^2)                       ))
    ( :acos,        :( -1 / sqrt(1 - x^2)                       ))
    ( :atan,        :(  1 / (1 + x^2)                           ))
    ( :asec,        :(  1 / abs(x) / sqrt(x^2 - 1)              ))
    ( :acsc,        :( -1 / abs(x) / sqrt(x^2 - 1)              ))
    ( :acot,        :( -1 / (1 + x^2)                           ))
    ( :asind,       :(  180 / pi / sqrt(1 - x^2)                ))
    ( :acosd,       :( -180 / pi / sqrt(1 - x^2)                ))
    ( :atand,       :(  180 / pi / (1 + x^2)                    ))
    ( :asecd,       :(  180 / pi / abs(x) / sqrt(x^2 - 1)       ))
    ( :acscd,       :( -180 / pi / abs(x) / sqrt(x^2 - 1)       ))
    ( :acotd,       :( -180 / pi / (1 + x^2)                    ))
    ( :sinh,        :(  cosh(x)                                 ))
    ( :cosh,        :(  sinh(x)                                 ))
    ( :tanh,        :(  sech(x)^2                               ))
    ( :sech,        :( -tanh(x) * sech(x)                       ))
    ( :csch,        :( -coth(x) * csch(x)                       ))
    ( :coth,        :( -csch(x)^2                               ))
    ( :asinh,       :(  1 / sqrt(x^2 + 1)                       ))
    ( :acosh,       :(  1 / sqrt(x^2 - 1)                       ))
    ( :atanh,       :(  1 / (1 - x^2)                           ))
    ( :asech,       :( -1 / x / sqrt(1 - x^2)                   ))
    ( :acsch,       :( -1 / abs(x) / sqrt(1 + x^2)              ))
    ( :acoth,       :(  1 / (1 - x^2)                           ))
    ( :deg2rad,     :(  pi / 180                                ))
    ( :rad2deg,     :(  180 / pi                                ))
    ( :erf,         :(  2 * exp(-x*x) / sqrt(pi)                ))
    ( :erfinv,      :(  0.5 * sqrt(pi) * exp(erfinv(x) * erfinv(x))  ))
    ( :erfc,        :( -2 * exp(-x*x) / sqrt(pi)                ))
    ( :erfcinv,     :( -0.5 * sqrt(pi) * exp(erfcinv(x) * erfcinv(x))  ))
    ( :erfi,        :(  2 * exp(x*x) / sqrt(pi)                 ))
    ( :gamma,       :(  digamma(x) * gamma(x)                   ))
    ( :lgamma,      :(  digamma(x)                              ))
    ( :digamma,     :(  trigamma(x)                             ))
    ( :invdigamma,  :(  inv(trigamma(invdigamma(x)))            ))
    ( :trigamma,    :(  polygamma(2, x)                         ))
    ( :airyai,      :(  airyaiprime(x)                          ))
    ( :airybi,      :(  airybiprime(x)                          ))
    ( :airyaiprime, :(  x * airyai(x)                           ))
    ( :airybiprime, :(  x * airybi(x)                           ))
    ( :besselj0,    :( -besselj1(x)                             ))
    ( :besselj1,    :(  (besselj0(x) - besselj(2, x)) / 2       ))
    ( :bessely0,    :( -bessely1(x)                             ))
    ( :bessely1,    :(  (bessely0(x) - bessely(2, x)) / 2       ))
    ( :erfcx,       :(  (2 * x * erfcx(x) - 2 / sqrt(pi))       ))
    ( :dawson,      :(  (1 - 2x * dawson(x))                    ))
]

# This is the public interface for accessing the list of symbolic
# derivatives. The format is a list of (Symbol,Expr) tuples
# (:f, deriv_expr), where deriv_expr is a symbolic
# expression for the first derivative of the function f.
# The symbol :x is used within deriv_expr for the point at
# which the derivative should be evaluated.
symbolic_derivatives_1arg() = symbolic_derivative_1arg_list
export symbolic_derivatives_1arg


# deprecated: for backward compatibility with packages that used
# this unexported interface.
derivative_rules = Vector{Tuple{Symbol,Expr}}()
for (s,ex) in symbolic_derivative_1arg_list
    push!(derivative_rules, (s, :(xp*$ex)))
end


for (funsym, exp) in symbolic_derivative_1arg_list
    @eval function differentiate(::SymbolParameter{$(Meta.quot(funsym))}, args, wrt)
        x = args[1]
        xp = differentiate(x, wrt)
        if xp != 0
            return @sexpr(xp*$exp)
        else
            return 0
        end
    end
end

derivative_rules_bessel = [
    ( :besselj,    :(    (besselj(nu - 1, x) - besselj(nu + 1, x)) / 2   ))
    ( :besseli,    :(    (besseli(nu - 1, x) + besseli(nu + 1, x)) / 2   ))
    ( :bessely,    :(    (bessely(nu - 1, x) - bessely(nu + 1, x)) / 2   ))
    ( :besselk,    :( -1 * (besselk(nu - 1, x) + besselk(nu + 1, x)) / 2   ))
    ( :hankelh1,   :(    (hankelh1(nu - 1, x) - hankelh1(nu + 1, x)) / 2 ))
    ( :hankelh2,   :(    (hankelh2(nu - 1, x) - hankelh2(nu + 1, x)) / 2 ))
]


# This is the public interface for accessing the list of symbolic
# derivatives. The format is a list of (Symbol,Expr) tuples
# (:f, deriv_expr), where deriv_expr is a symbolic
# expression for the first derivative of the function f with respect to x.
# The symbol :nu and :x are used within deriv_expr
# :nu specifies the first parameter of the bessel
# function (usually written n or alpha)
# :x gives the point at which the derivative should be evaluated.
symbolic_derivative_bessel_list() = derivative_rules_bessel
export symbolic_derivative_bessel_list

# 2-argument bessel functions
for (funsym, exp) in derivative_rules_bessel
    @eval function differentiate(::SymbolParameter{$(Meta.quot(funsym))}, args, wrt)
        nu = args[1]
        x = args[2]
        xp = differentiate(x, wrt)
        if xp != 0
            return @sexpr(xp*$exp)
        else
            return 0
        end
    end
end

### Other functions from julia/base/math.jl we might want to define
### derivatives for. Some have two arguments.

## atan2
## hypot
## beta, lbeta, eta, zeta, digamma

## Differentiate for piecewise functions defined using ifelse
function differentiate(::SymbolParameter{:ifelse}, args, wrt)
    :(ifelse($(args[1]), $(differentiate(args[2],wrt)),$(differentiate(args[3],wrt))))
end

function differentiate(ex::Expr, targets::Vector{Symbol})
    n = length(targets)
    exprs = Vector{Any}(undef, n)
    for i in 1:n
        exprs[i] = differentiate(ex, targets[i])
    end
    return exprs
end

differentiate(ex::Expr) = differentiate(ex, :x)
differentiate(s::AbstractString, target...) = differentiate(Meta.parse(s), target...)
differentiate(s::AbstractString, target::AbstractString) =
    differentiate(Compat.Meta.parse(s), Symbol(target))
differentiate(s::AbstractString, targets::Vector{T}) where {T <: AbstractString} =
    differentiate(Compat.Meta.parse(s), map(Symbol, targets))
