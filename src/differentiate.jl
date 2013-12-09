
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
    simplify(differentiate(SymbolParameter(ex.args[1]), ex.args[2:end], wrt))
end

differentiate{T}(x::SymbolParameter{T}, args, wrt) = error("Derivative of function " * string(T) * " not supported")

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
    termdiffs = {:+}
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
    termdiffs = {:-}
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
    res_args = Array(Any, n)
    for i in 1:n
       new_args = Array(Any, n)
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


derivative_rules = [
    ( :sqrt,        :(  xp / 2 / sqrt(x)                         ))
    ( :cbrt,        :(  xp / 3 / cbrt(x)^2                       ))
    ( :square,      :(  xp * 2 * x                               ))
    ( :log,         :(  xp / x                                   ))
    ( :log10,       :(  xp / x / log(10)                         ))
    ( :log2,        :(  xp / x / log(2)                          ))
    ( :log1p,       :(  xp / (x + 1)                             ))
    ( :exp,         :(  xp * exp(x)                              ))
    ( :exp2,        :(  xp * log(2) * exp2(x)                    ))
    ( :expm1,       :(  xp * exp(x)                              ))
    ( :sin,         :(  xp * cos(x)                              ))
    ( :cos,         :( -xp * sin(x)                              ))
    ( :tan,         :(  xp * (1 + tan(x)^2)                      ))
    ( :sec,         :(  xp * sec(x) * tan(x)                     ))
    ( :csc,         :( -xp * csc(x) * cot(x)                     ))
    ( :cot,         :( -xp * (1 + cot(x)^2)                      ))
    ( :sind,        :(  xp * pi / 180 * cosd(x)                  ))
    ( :cosd,        :( -xp * pi / 180 * sind(x)                  ))
    ( :tand,        :(  xp * pi / 180 * (1 + tand(x)^2)          ))
    ( :secd,        :(  xp * pi / 180 * secd(x) * tand(x)        ))
    ( :cscd,        :( -xp * pi / 180 * cscd(x) * cotd(x)        ))
    ( :cotd,        :( -xp * pi / 180 * (1 + cotd(x)^2)          ))
    ( :asin,        :(  xp / sqrt(1 - x^2)                       ))
    ( :acos,        :( -xp / sqrt(1 - x^2)                       ))
    ( :atan,        :(  xp / (1 + x^2)                           ))
    ( :asec,        :(  xp / abs(x) / sqrt(x^2 - 1)              ))
    ( :acsc,        :( -xp / abs(x) / sqrt(x^2 - 1)              ))
    ( :acot,        :( -xp / (1 + x^2)                           ))
    ( :asind,       :(  xp * 180 / pi / sqrt(1 - x^2)            ))
    ( :acosd,       :( -xp * 180 / pi / sqrt(1 - x^2)            ))
    ( :atand,       :(  xp * 180 / pi / (1 + x^2)                ))
    ( :asecd,       :(  xp * 180 / pi / abs(x) / sqrt(x^2 - 1)   ))
    ( :acscd,       :( -xp * 180 / pi / abs(x) / sqrt(x^2 - 1)   ))
    ( :acotd,       :( -xp * 180 / pi / (1 + x^2)                ))
    ( :sinh,        :(  xp * cosh(x)                             ))
    ( :cosh,        :(  xp * sinh(x)                             ))
    ( :tanh,        :(  xp * sech(x)^2                           ))
    ( :sech,        :( -xp * tanh(x) * sech(x)                   ))
    ( :csch,        :( -xp * coth(x) * csch(x)                   ))
    ( :coth,        :( -xp * csch(x)^2                           ))
    ( :asinh,       :(  xp / sqrt(x^2 + 1)                       ))
    ( :acosh,       :(  xp / sqrt(x^2 - 1)                       ))
    ( :atanh,       :(  xp / (1 - x^2)                           ))
    ( :asech,       :( -xp / x / sqrt(1 - x^2)                   ))
    ( :acsch,       :( -xp / abs(x) / sqrt(1 + x^2)              ))
    ( :acoth,       :(  xp / (1 - x^2)                           ))
    ( :erf,         :(  xp * 2 * exp(-square(x)) / sqrt(pi)      ))
    ( :erfc,        :( -xp * 2 * exp(-square(x)) / sqrt(pi)      ))
    ( :erfi,        :(  xp * 2 * exp(square(x)) / sqrt(pi)       ))
    ( :gamma,       :(  xp * digamma(x) * gamma(x)               ))
    ( :lgamma,      :(  xp * digamma(x)                          ))
    ( :airy,        :(  xp * airyprime(x)                        ))  # note: only covers the 1-arg version
    ( :airyprime,   :(  xp * airy(2, x)                          ))
    ( :airyai,      :(  xp * airyaiprime(x)                      ))
    ( :airybi,      :(  xp * airybiprime(x)                      ))
    ( :airyaiprime, :(  xp * x * airyai(x)                       ))
    ( :airybiprime, :(  xp * x * airybi(x)                       ))
    ( :besselj0,    :( -xp * besselj1(x)                         ))
    ( :besselj1,    :(  xp * (besselj0(x) - besselj(2, x)) / 2   ))
    ( :bessely0,    :( -xp * bessely1(x)                         ))
    ( :bessely1,    :(  xp * (bessely0(x) - bessely(2, x)) / 2   ))
    ## ( :erfcx,   :(  xp * (2 * x * erfcx(x) - 2 / sqrt(pi))   ))  # uncertain
    ## ( :dawson,  :(  xp * (1 - 2x * dawson(x))                ))  # uncertain

]

for (funsym, exp) in derivative_rules 
    @eval function differentiate(::SymbolParameter{$(Meta.quot(funsym))}, args, wrt)
        x = args[1]
        xp = differentiate(x, wrt)
        if xp != 0
            return @sexpr($exp)
        else
            return 0
        end
    end
end

derivative_rules_bessel = [
    ( :besselj,    :(  xp * (besselj(nu - 1, x) - besselj(nu + 1, x)) / 2   ))
    ( :besseli,    :(  xp * (besseli(nu - 1, x) + besseli(nu + 1, x)) / 2   ))
    ( :bessely,    :(  xp * (bessely(nu - 1, x) - bessely(nu + 1, x)) / 2   ))
    ( :besselk,    :( -xp * (besselk(nu - 1, x) + besselk(nu + 1, x)) / 2   ))
    ( :hankelh1,   :(  xp * (hankelh1(nu - 1, x) - hankelh1(nu + 1, x)) / 2 ))
    ( :hankelh2,   :(  xp * (hankelh2(nu - 1, x) - hankelh2(nu + 1, x)) / 2 ))
]

# 2-argument bessel functions
for (funsym, exp) in derivative_rules_bessel 
    @eval function differentiate(::SymbolParameter{$(Meta.quot(funsym))}, args, wrt)
        nu = args[1]
        x = args[2]
        xp = differentiate(x, wrt)
        if xp != 0
            return @sexpr($exp)
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

function differentiate(ex::Expr, targets::Vector{Symbol})
    n = length(targets)
    exprs = Array(Expr, n)
    for i in 1:n
        exprs[i] = differentiate(ex, targets[i])
    end
    return exprs
end


differentiate(ex::Expr) = differentiate(ex, :x)

function differentiate(s::String, target::Symbol)
    differentiate(parse(s), target)
end
function differentiate(s::String, targets::Vector{Symbol})
    differentiate(parse(s), targets)
end
function differentiate(s::String, target::String)
    differentiate(parse(s), symbol(target))
end
function differentiate{T <: String}(s::String, targets::Vector{T})
    differentiate(parse(s), map(target -> symbol(target), targets))
end
function differentiate(s::String)
    differentiate(parse(s), :x)
end

