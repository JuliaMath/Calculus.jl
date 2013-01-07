# TODO: Add pretty printing via deparse()

simplify(n::Number) = n

simplify(s::Symbol) = s

# Handles all lengths for ex.args
# Removes any 0's in a sum
function simplify_sum(ex::Expr)
    new_args = map(x -> simplify(x), filter(x -> x != 0, ex.args[2:end]))
    if length(new_args) == 0
        return 0
    # Special Case: simplify(:(+x)) == x
    elseif length(new_args) == 1
        return new_args[1]
    else
        unshift(new_args, :+)
        return Expr(:call, new_args, Any)
    end
end

# Assumes length(ex.args) == 3
# Removes any 0's in a subtraction
function simplify_subtraction(ex::Expr)
    new_args = map(x -> simplify(x), filter(x -> x != 0, ex.args[2:end]))
    if length(new_args) == 0
        return 0
    # Special Case: simplify(:(x - x)) == 0
    elseif length(new_args) == 2 && new_args[1] == new_args[2]
        return 0
    else
        unshift(new_args, :-)
        return Expr(:call, new_args, Any)
    end
end

# Handles all lengths for ex.args
# Removes any 1's in a product
function simplify_product(ex::Expr)
    new_args = map(x -> simplify(x), filter(x -> x != 1, ex.args[2:end]))
    if length(new_args) == 0
        return 1
    # Special Case: simplify(:(*x)) == x
    elseif length(new_args) == 1
        return new_args[1]
    # Special Case: simplify(:(x * y * z * 0)) == 0
    elseif any(new_args .== 0)
        return 0
    else
        unshift(new_args, :*)
        return Expr(:call, new_args, Any)
    end
end

# Assumes length(ex.args) == 3
function simplify_quotient(ex::Expr)
    new_args = map(x -> simplify(x), ex.args[2:end])
    # Special Case: simplify(:(x / 1)) == x
    if new_args[2] == 1
        return new_args[1]
    # Special Case: simplify(:(0 / x)) == 0
    elseif new_args[1] == 0
        return 0
    else
        unshift(new_args, :/)
        return Expr(:call, new_args, Any)
    end
end

# Assumes length(ex.args) == 3
function simplify_power(ex::Expr)
    new_args = map(x -> simplify(x), ex.args[2:end])
    # Special Case: simplify(:(x ^ 0)) == 1
    if new_args[2] == 0
        return 1
    # Special Case: simplify(:(x ^ 1)) == x
    elseif new_args[2] == 1
        return new_args[1]
    # Special Case: simplify(:(0 ^ x)) == 0
    elseif new_args[1] == 0
        return 0
    # Special Case: simplify(:(1 ^ x)) == 1
    elseif new_args[1] == 1
        return 1
    else
        unshift(new_args, :^)
        return Expr(:call, new_args, Any)
    end
end

simplify_lookup = {
                    :+ => simplify_sum,
                    :- => simplify_subtraction,
                    :* => simplify_product,
                    :/ => simplify_quotient,
                    :^ => simplify_power
                  }

function simplify(ex::Expr)
    if ex.head == :call
        if all(map(a -> isa(a, Number), ex.args[2:end]))
            return eval(ex)
        end
        if has(simplify_lookup, ex.args[1])
            new_ex = simplify_lookup[ex.args[1]](ex)
            while new_ex != ex
                new_ex, ex = simplify(new_ex), new_ex
            end
            return new_ex
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
# d/dx y = 0
function differentiate(s::Symbol, target::Symbol)
    if s == target
        return 1
    else
        return 0
    end
end

# The Sum Rule for Unary and Binary +
# d/dx +(f) = +(d/dx f)
# d/dx (f + g) = d/dx f + d/dx g
function differentiate_sum(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :+
        error("Not a valid sum call: $(ex)")
    end
    new_args = {:+}
    for i in 2:length(ex.args)
        push(new_args, differentiate(ex.args[i], target))
    end
    return Expr(:call, new_args, Any)
end

# The Subtraction Rule for Unary and Binary -
# d/dx -(f) = -(d/dx f)
# d/dx (f - g) = d/dx f - d/dx g
function differentiate_subtraction(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :-
        error("Not a valid subtraction call: $(ex)")
    end
    new_args = {:-}
    for i in 2:length(ex.args)
        push(new_args, differentiate(ex.args[i], target))
    end
    return Expr(:call, new_args, Any)
end

# The Product Rule
# d/dx (f * g) = (d/dx f) * g + f * (d/dx g)
function differentiate_product(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :*
        error("Not a valid product call: $(ex)")
    end
    return Expr(:call,
                {
                    :+,
                    Expr(:call,
                         {
                            :*,
                            differentiate(ex.args[2], target),
                            ex.args[3]
                         },
                         Any),
                    Expr(:call,
                         {
                           :*,
                           ex.args[2],
                           differentiate(ex.args[3], target)
                         },
                         Any)
                },
                Any)
end

# The Quotient Rule
# d/dx (f / g) = ((d/dx f) * g - f * (d/dx g)) / g^2
function differentiate_quotient(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :/
        error("Not a valid quotient call: $(ex)")
    end
    return Expr(:call,
                {
                    :/,
                    Expr(:call,
                         {
                            :-,
                            Expr(:call,
                                 {
                                    :*,
                                    differentiate(ex.args[2], target),
                                    ex.args[3]
                                 },
                                 Any),
                            Expr(:call,
                                 {
                                    :*,
                                    ex.args[2],
                                    differentiate(ex.args[3], target)
                                 },
                                 Any)
                         },
                         Any),
                    Expr(:call,
                         {
                            :^,
                            ex.args[3],
                            2
                         },
                         Any)
                },
                Any)
end

# The Power Rule:
# Case 1: x^n <=> /dx x^n = n * x^(n - 1)
# Case 2: x^x <=> d/dx x^x = x^x (log(x) + 1)
# Case 3: n^n <=> d/dx n^n = 0
# Case 4: n^x <=> n^x * log(n)
function differentiate_power(ex::Expr, target::Symbol)
    if ex.head != :call || ex.args[1] != :^
        error("Not a valid power call: $(ex)")
    end
    if ex.args[2] == target && ex.args[3] != target
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
    elseif ex.args[2] == target && ex.args[3] == target
        return Expr(:call,
                    {
                        :*,
                        Expr(:call,
                             {
                                :^,
                                target,
                                target
                             },
                             Any),
                        Expr(:call,
                             {
                                :+,
                                Expr(:call,
                                     {
                                        :log,
                                        target
                                     },
                                     Any),
                                1
                             },
                             Any)
                    },
                    Any)
    elseif ex.args[2] != target && ex.args[3] != target
        return ex
    else
        # Case 4: n^x <=> n^x * log(n)
        return Expr(:call,
                    {
                        :*,
                        Expr(:call,
                             {
                                :^,
                                ex.args[2],
                                ex.args[3]
                             },
                             Any),
                        Expr(:call,
                             {
                                :log,
                                ex.args[2]
                             },
                             Any)
                    },
                    Any)
    end
end

# The Sin Rule:
# d/dx sin(x) = cos(x)
function differentiate_sin(ex::Expr, target::Symbol)
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
                    differentiate(ex.args[2], target)
                },
                Any)
end

# The Cos Rule:
# d/dx cos(x) = -sin(x)
function differentiate_cos(ex::Expr, target::Symbol)
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
                    differentiate(ex.args[2], target)
                },
                Any)
end

# The Tan Rule:
# d/dx tan(x) = 1 + tan(x)^2
function differentiate_tan(ex::Expr, target::Symbol)
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
                    differentiate(ex.args[2], target)
                },
                Any)
end

# The Exp Rule:
# d/dx exp(x) = exp(x)
function differentiate_exp(ex::Expr, target::Symbol)
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
                    differentiate(ex.args[2], target)
                },
                Any)
end

# The Log Rule:
# d/dx log(x) = 1 / x
function differentiate_log(ex::Expr, target::Symbol)
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
                    differentiate(ex.args[2], target)
                },
                Any)
end

# Lookup Table of Rules
differentiate_lookup = {
                          :+ => differentiate_sum,
                          :- => differentiate_subtraction,
                          :* => differentiate_product,
                          :/ => differentiate_quotient,
                          :^ => differentiate_power,
                          :sin => differentiate_sin,
                          :cos => differentiate_cos,
                          :tan => differentiate_tan,
                          :exp => differentiate_exp,
                          :log => differentiate_log
                       }

function differentiate(ex::Expr, target::Symbol)
    if ex.head == :call
        if has(differentiate_lookup, ex.args[1])
            return simplify(differentiate_lookup[ex.args[1]](ex, target))
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

# Full out differentation returns an immediately evaluable Julia function

# function derivative(ex::Expr, target::Symbol)
#     function f(x)
#         d_ex = differentiate(ex, target)
#         return eval(d_ex)
#     end
#     return f
# end

# function derivative(ex::Expr, target::Symbol, x::Any)
#     d_ex = differentiate(ex, target)
#     return eval(d_ex)
# end
