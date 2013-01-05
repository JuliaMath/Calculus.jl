# TODO: Add explicit simplification function that runs until fixed point
# TODO: Pretty printing of resulting expressions via deparse()

# Impose minimal simplification
#  (1) +(0, x) == +(x , 0) == x
#  (2) *(0, x) == *(x , 0) == 0
#  (3) *(1, x) == *(x, 1) == x
# simplify(n * n) = Numerical Value of n * n
# simplify(x - x) = 0 for all x

simplify(n::Number) = n
simplify(s::Symbol) = s
function simplify(ex::Expr)
    if ex.head == :call
        if contains([:+, :-, :*, :/, :^], ex.args[1]) && all(map(a -> isa(a, Number), ex.args[2:end]))
            return eval(ex)
        end
        if ex.args[1] == :+
            if length(ex.args) == 2
                return ex.args[2]
            else
                if ex.args[2] == 0
                    return ex.args[3]
                elseif ex.args[3] == 0
                    return ex.args[2]
                else
                    return ex # Should we call simplify() here?
                end
            end
        elseif ex.args[1] == :-
            if length(ex.args) == 2
                return ex
            else
                if ex.args[2] == 0
                    return ex
                elseif ex.args[3] == 0
                    return ex.args[2]
                elseif ex.args[2] == ex.args[3]
                    return 0
                else
                    return ex # Should we call simplify() here?
                end
            end
        elseif ex.args[1] == :*
            if ex.args[2] == 0 || ex.args[3] == 0
                return 0
            elseif ex.args[2] == 1
                return ex.args[3]
            elseif ex.args[3] == 1
                return ex.args[2]
            else
                return ex # Should we call simplify() here?
            end
        elseif ex.args[1] == :/
            if ex.args[3] == 0
                return ex # Is x / 0, which could be Inf or NaN depending on x
            elseif ex.args[3] == 1
                return ex.args[2]
            elseif ex.args[2] == 0
                return 0
            else
                return ex # Should we call simplify() here?
            end
        elseif ex.args[1] == :^
            if ex.args[3] == 0
                return 1
            elseif ex.args[3] == 1
                return ex.args[2]
            elseif ex.args[2] == 0
                return 0
            elseif ex.args[2] == 1
                return 1
            else
                return ex
            end
        # Log tricks here?
        else
            return ex
        end
    else
        return ex
    end
end

# The Constant Rule
# d/dx c = 0
differentiate(x::Number, target::Symbol) = 0

# The Symbol Rule
# d/dx x = 1
# d/dx y = y
function differentiate(s::Symbol, target::Symbol)
    if s == target
        return 1
    else
        return 0 # Used to be s
    end
end

# The Sum Rule for Unary and Binary +
# d/dx +(f) = +(d/dx f)
# d/dx (f + g) = d/dx f + d/dx g
function sum_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :+
        error("Not a valid sum call: $(ex)")
    end
    if length(ex.args) == 2
        return simplify(differentiate(ex.args[2], target))
    else
        new_args = {:+}
        for i in 2:length(ex.args)
            push(new_args, simplify(differentiate(ex.args[i], target)))
        end
        return simplify(Expr(:call,
                             new_args,
                             Any))
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
        return simplify(Expr(:call,
                             {
                                 :-,
                                 simplify(differentiate(ex.args[2], target))
                             },
                             Any))
    else
        return simplify(Expr(:call,
                             {
                                 :-,
                                 simplify(differentiate(ex.args[2], target)),
                                 simplify(differentiate(ex.args[3], target))
                             },
                             Any))
    end
end

# The Product Rule
# d/dx (f * g) = (d/dx f) * g + f * (d/dx g)
function product_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :*
        error("Not a valid product call: $(ex)")
    end
    return simplify(Expr(:call,
                         {
                             :+,
                             simplify(Expr(:call,
                                           {
                                              :*,
                                              simplify(differentiate(ex.args[2], target)),
                                              ex.args[3]
                                           },
                                           Any)),
                             simplify(Expr(:call,
                                           {
                                             :*,
                                             ex.args[2],
                                             simplify(differentiate(ex.args[3], target))
                                           },
                                           Any))
                         },
                         Any))
end

# The Quotient Rule
# d/dx (f / g) = ((d/dx f) * g - f * (d/dx g)) / g^2
function quotient_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :/
        error("Not a valid quotient call: $(ex)")
    end
    return simplify(Expr(:call,
                         {
                             :/,
                             simplify(Expr(:call,
                                           {
                                              :-,
                                              simplify(Expr(:call,
                                                            {
                                                               :*,
                                                               simplify(differentiate(ex.args[2], target)),
                                                               ex.args[3]
                                                            },
                                                            Any)),
                                              simplify(Expr(:call,
                                                            {
                                                               :*,
                                                               ex.args[2],
                                                               simplify(differentiate(ex.args[3], target))
                                                            },
                                                            Any))
                                           },
                                           Any)),
                             Expr(:call,
                                  {
                                     :^,
                                     ex.args[3],
                                     2
                                  },
                                  Any)
                         },
                         Any))
end

# The Power Rule:
# Case 1: x^n: DONE
# Case 2: n^x: TODO
# Case 3: x^x: TODO
function power_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :^
        error("Not a valid power call: $(ex)")
    end
    return simplify(Expr(:call,
                         {
                             :*,
                             ex.args[3],
                             simplify(Expr(:call,
                                           {
                                              :^,
                                              ex.args[2],
                                              simplify(Expr(:call,
                                                            {
                                                                :-,
                                                                ex.args[3],
                                                                1
                                                            },
                                                            Any))
                                           },
                                           Any))
                         },
                         Any))
end

# The Sin Rule:
# d/dx sin(x) = cos(x)
function sin_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :sin
        error("Not a valid sin call: $(ex)")
    end
    return simplify(Expr(:call,
                         {
                             :*,
                             Expr(:call,
                                  {
                                     :cos,
                                     ex.args[2]
                                  },
                                  Any),
                             simplify(differentiate(ex.args[2], target))
                         },
                         Any))
end

# The Cos Rule:
# d/dx cos(x) = -sin(x)
function cos_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :cos
        error("Not a valid cos call: $(ex)")
    end
    return simplify(Expr(:call,
                         {
                             :*,
                             simplify(Expr(:call,
                                           {
                                              :-,
                                              Expr(:call,
                                                   {
                                                      :sin,
                                                      ex.args[2]
                                                   },
                                                   Any)
                                           },
                                           Any)),
                             simplify(differentiate(ex.args[2], target))
                         },
                         Any))
end

# The Tan Rule:
# d/dx tan(x) = 1 + tan(x)^2
function tan_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :tan
        error("Not a valid tan call: $(ex)")
    end
    return simplify(Expr(:call,
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
                             differentiate(ex.args[2], target)
                         },
                         Any))
end

# The Exp Rule:
# d/dx exp(x) = exp(x)
function exp_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :exp
        error("Not a valid exp call: $(ex)")
    end
    return simplify(Expr(:call,
                         {
                             :*,
                             Expr(:call,
                                  {
                                     :exp,
                                     ex.args[2]
                                  },
                                  Any),
                             simplify(differentiate(ex.args[2], target))
                         },
                         Any))
end

# The Log Rule:
# d/dx log(x) = 1 / x
function log_rule(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :log
        error("Not a valid log call: $(ex)")
    end
    return simplify(Expr(:call,
                         {
                             :*,
                             Expr(:call,
                                  {
                                     :/,
                                     1,
                                     ex.args[2]
                                  },
                                  Any),
                             simplify(differentiate(ex.args[2], target))
                         },
                         Any))
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

function differentiate(ex::Expr, target::Symbol)
    if ex.head == :call
        if has(lookup, ex.args[1])
            return lookup[ex.args[1]](ex, target)
        else
            error("Unknown function called in AST: $(ex.args[1])")
        end
    else
        return simplify(differentiate(ex.head))
    end
end
differentiate(ex::Expr) = differentiate(ex, :x)

differentiate(s::String, target::Symbol) = differentiate(parse(s)[1], target)
differentiate(s::String, target::String) = differentiate(parse(s)[1], symbol(target))
differentiate(s::String) = differentiate(parse(s)[1], :x)

# begin x = 1; eval(differentiate(:(sin(x)), :x)) end
# Full out differentation
function derivative(ex::Expr, target::Symbol)
    function f(x)
        d_ex = differentiate(ex, target)
        return eval(d_ex)
    end
    return f
end

function derivative(ex::Expr, target::Symbol, x::Any)
    d_ex = differentiate(ex, target)
    return eval(d_ex)
end
