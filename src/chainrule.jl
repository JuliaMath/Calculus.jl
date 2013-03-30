
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

chainRule{T}(x::SymbolParameter{T}) = error("Function " * string(T) * " not supported")

function chainRule(::SymbolParameter{:^}, args, wrt)
    x = chainRule(args[1], wrt)
    if x != 0
        return :( $(args[2]) * $(x) * ($(args[1]) ^ ($(args[2] - 1))) )
    else
        return 0
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

function chainRule(::SymbolParameter{:*}, args, wrt)
    if length(args) != 2
        error("Only multiplication with two terms is currently supported")
    end
    d1 = chainRule(args[1], wrt)
    d2 = chainRule(args[2], wrt)
    # there's a nicer way
    if d1 == 0 && d2 == 0
        return 0
    elseif d1 == 0
        return :( $(d2)*$(args[1]) )
    elseif d2 == 0
        return :( $(d1)*$(args[2]) )
    else
        return :( $(d1)*$(args[2]) + $(args[1])*$(d2))
    end
end

function chainRule(::SymbolParameter{:cos}, args, wrt)
    x = chainRule(args[1], wrt)
    if x != 0
        return :(-$(x)*sin($(args[1])))
    else
        return 0
    end
end

function chainRule(::SymbolParameter{:sin}, args, wrt)
    x = chainRule(args[1], wrt)
    if x != 0
        return :($x*cos($(args[1])))
    else
        return 0
    end
end
