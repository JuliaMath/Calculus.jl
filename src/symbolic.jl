# TODO: Add explicit simplification function that runs until fixed point
# TODO: Impose minimal simplifications
#        (1) +(0, x) == +(x , 0) == x
#        (2) *(0, x) == *(x , 0) == 0
#        (3) *(1, x) == *(x, 1) == x
# TODO: Pretty printing of resulting expressions via deparse()

# The Symbol Rule
# d/dx x = 1
# d/dx y = y
function deriv(s::Symbol, target::Symbol)
    if s == target
        return 1
    else
        return s
    end
end

# The Constant Rule
# d/dx c = 0
deriv(x::Number, target::Symbol) = 0

# The Sum Rule for Unary and Binary +
# d/dx +(f) = +(d/dx f)
# d/dx (f + g) = d/dx f + d/dx g
function sum_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :+
        error("Not a valid sum call: $(ex)")
    end
    if length(ex.args) == 2
        return deriv(ex.args[2], target)
    else
        return Expr(:call,
                    {
                        :+,
                        deriv(ex.args[2], target),
                        deriv(ex.args[3], target)
                    },
                    Any)
    end
end

# The Subtraction Rule for Unary and Binary -
# d/dx -(f) = -(d/dx f)
# d/dx (f - g) = d/dx f - d/dx g
function subtraction_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :-
        error("Not a valid subtraction call: $(ex)")
    end
    if length(ex.args) == 2
        return Expr(:call,
                    {
                        :-,
                        deriv(ex.args[2], target)
                    },
                    Any)
    else
        return Expr(:call,
                    {
                        :-,
                        deriv(ex.args[2], target),
                        deriv(ex.args[3], target)
                    },
                    Any)
    end
end

# The Product Rule: (f * g)' = f' * g + f * g'
function product_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :*
        error("Not a valid product call: $(ex)")
    end
    return Expr(:call,
                {:+,
                 Expr(:call,
                      {:*, deriv(ex.args[2], target), ex.args[3]},
                      Any),
                 Expr(:call,
                      {:*, ex.args[2], deriv(ex.args[3], target)},
                       Any)},
                Any)
end

# The Quotient Rule: (f / g)' = (f' * g - f * g') / g^2
function quotient_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :/
        error("Not a valid quotient call: $(ex)")
    end
    return Expr(:call,
                {:/,
                 Expr(:call,
                      {:-,
                       Expr(:call,
                            {:*, deriv(ex.args[2], target), ex.args[3]},
                            Any),
                       Expr(:call,
                            {:*, ex.args[2], deriv(ex.args[3], target)},
                            Any)},
                       Any),
                 Expr(:call,
                      {:^,
                       ex.args[3],
                       2},
                      Any)},
                Any)
end

# The Power Rule:
# Case 1: x^n: DONE
# Case 2: n^x: TODO
# Case 3: x^x: TODO
function power_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :^
        error("Not a valid power call: $(ex)")
    end
    return Expr(:call,
                {
                    :*,
                    ex.args[3],
                    Expr(:call,
                         {
                            :^,
                            ex.args[2],
                            Expr(:call,
                                 {
                                     :-,
                                     ex.args[3],
                                     1
                                 },
                                 Any)
                         },
                         Any)
                },
                Any)
end

# The Sin Rule:
# d/dx sin(x) = cos(x)
function sin_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :sin
        error("Not a valid sin call: $(ex)")
    end
    return Expr(:call,
                {
                    :*,
                    Expr(:call,
                         {
                            :cos,
                            ex.args[2]
                         },
                         Any),
                    deriv(ex.args[2], target)
                },
                Any)
end

# The Cos Rule:
# d/dx cos(x) = -sin(x)
function cos_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :cos
        error("Not a valid cos call: $(ex)")
    end
    return Expr(:call,
                {
                    :*,
                    Expr(:call,
                         {
                            :-,
                            Expr(:call,
                                 {
                                    :sin,
                                    ex.args[2]
                                 },
                                 Any)
                         },
                         Any),
                    deriv(ex.args[2], target)
                },
                Any)
end

# The Tan Rule:
# d/dx tan(x) = 1 + tan(x)^2
function tan_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :tan
        error("Not a valid tan call: $(ex)")
    end
    return Expr(:call,
                {
                    :*,
                    Expr(:call,
                         {
                            :+,
                            1,
                            Expr(:call,
                                 {
                                    :^,
                                    Expr(:call,
                                         {
                                            :tan,
                                            ex.args[2]
                                         },
                                         Any),
                                    2
                                 },
                                 Any)
                         },
                         Any),
                    deriv(ex.args[2], target)
                },
                Any)
end

# The Exp Rule:
# d/dx exp(x) = exp(x)
function exp_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :exp
        error("Not a valid exp call: $(ex)")
    end
    return Expr(:call,
                {
                    :*,
                    Expr(:call,
                         {
                            :exp,
                            ex.args[2]
                         },
                         Any),
                    deriv(ex.args[2], target)
                },
                Any)
end

# The Log Rule:
# d/dx log(x) = 1 / x
function log_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :log
        error("Not a valid log call: $(ex)")
    end
    return Expr(:call,
                {
                    :*,
                    Expr(:call,
                         {
                            :/,
                            1,
                            ex.args[2]
                         },
                         Any),
                    deriv(ex.args[2], target)
                },
                Any)
end

# Lookup Table of Rules
lookup = {:+ => sum_rule,
          :- => subtraction_rule,
          :* => product_rule,
          :/ => quotient_rule,
          :^ => power_rule,
          :sin => sin_rule,
          :cos => cos_rule,
          :tan => tan_rule,
          :exp => exp_rule,
          :log => log_rule}

function deriv(ex::Expr, target::Symbol)
    if ex.head == :call
        if has(lookup, ex.args[1])
            return lookup[ex.args[1]](ex, target)
        else
            error("Unknown function called in AST: $(ex.args[1])")
        end
    else
        return deriv(ex.head)
    end
end

# begin x = 1; eval(deriv(:(sin(x)), :x)) end
function derivative(ex::Expr, target::Symbol)
    function f(x)
        d_ex = deriv(ex, target)
        return eval(d_ex)
    end
    return f
end

function derivative(ex::Expr, target::Symbol, x::Any)
    d_ex = deriv(ex, target)
    return eval(d_ex)
end
