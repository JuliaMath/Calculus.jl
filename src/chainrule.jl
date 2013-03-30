
export SymbolParameter, chainRule

#################################################################
#
# SymbolParameter
#   used to be able to dispatch on the symbol representing a
#   function
#   
#################################################################

type SymbolParameter{T}
end
SymbolParameter(s::Symbol) = SymbolParameter{s}()


#################################################################
#
# chainRule for differentiation
#   based on this code, I think by Miles Lubin:
#     https://github.com/IainNZ/NLTester/blob/master/julia/nlp.jl#L74
#   
#################################################################

chainRule(ex::SymbolicVariable, wrt::SymbolicVariable) = (ex == wrt) ? 1 : 0

chainRule(ex::Number, wrt::SymbolicVariable) = 0

function chainRule(ex::Expr,wrt)
    if ex.head != :call
        error("Unrecognized expression $ex")
    end
    chainRule(SymbolParameter(ex.args[1]), ex.args[2:end], wrt)
end

chainRule{T}(x::SymbolParameter{T}, args, wrt) = error("Derivative of function " * string(T) * " not supported")

# The Power Rule:
function chainRule(::SymbolParameter{:^}, args, wrt)
    x = args[1]
    y = args[2]
    xp = chainRule(x, wrt)
    yp = chainRule(y, wrt)
    if xp == 0 && yp == 0
        return 0
    elseif xp != 0 && yp == 0
        return :( $y * $xp * ($x ^ ($y - 1)) )
    else
        return :( $x ^ $y * ($xp * $y / $x + $yp * log($x)) ) 
    end
end

function chainRule(::SymbolParameter{:+}, args, wrt)
    termdiffs = {:+}
    for y in args
        x = chainRule(y, wrt)
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

function chainRule(::SymbolParameter{:-}, args, wrt)
    termdiffs = {:-}
    # first term is special, can't be dropped
    term1 = chainRule(args[1], wrt)
    push!(termdiffs, term1)
    for y in args[2:end]
        x = chainRule(y, wrt)
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
function chainRule(::SymbolParameter{:*}, args, wrt)
    n = length(args)
    res_args = Array(Any, n)
    for i in 1:n
       new_args = Array(Any, n)
       for j in 1:n
           if j == i
               new_args[j] = chainRule(args[j], wrt)
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
function chainRule(::SymbolParameter{:/}, args, wrt)
    x = args[1]
    y = args[2]
    xp = chainRule(x, wrt)
    yp = chainRule(y, wrt)
    if xp == 0 && yp == 0
        return 0
    elseif xp == 0
        return :( -$yp * $x )
    elseif yp == 0
        return :( $xp * $y )
    else
        return :( ($xp * $y - $x * $yp) / $y^2 )
    end
end

# The Cos Rule:
# d/dx cos(x) = -sin(x)
function chainRule(::SymbolParameter{:cos}, args, wrt)
    x = args[1]
    xp = chainRule(x, wrt)
    if x != 0
        return :( -$xp * sin($x) )
    else
        return 0
    end
end

# The Sin Rule:
# d/dx sin(x) = cos(x)
function chainRule(::SymbolParameter{:sin}, args, wrt)
    x = args[1]
    xp = chainRule(x, wrt)
    if x != 0
        return :( $xp * cos($x) )
    else
        return 0
    end
end

# The Tan Rule:
# d/dx tan(x) = 1 + tan(x)^2
function chainRule(::SymbolParameter{:tan}, args, wrt)
    x = args[1]
    xp = chainRule(x, wrt)
    if x != 0
        return :( $xp * (1 + tan($x)^2) )
    else
        return 0
    end
end

# The Exp Rule:
# d/dx exp(x) = exp(x)
function chainRule(::SymbolParameter{:exp}, args, wrt)
    x = args[1]
    xp = chainRule(x, wrt)
    if x != 0
        return :( $xp * exp($x) )
    else
        return 0
    end
end

# The Log Rule:
# d/dx log(x) = 1 / x
function chainRule(::SymbolParameter{:log}, args, wrt)
    x = args[1]
    xp = chainRule(x, wrt)
    if x != 0
        return :( $xp / $x )
    else
        return 0
    end
end
