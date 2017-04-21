export Symbolic, AbstractVariable, SymbolicVariable, BasicVariable, processExpr, @sexpr
export SymbolParameter, simplify
import Base.show, Base.(==)

#################################################################
#
# Symbolic types
#   Symbolic - top of the tree
#   AbstractVariable - inherit from this for custom symbolic
#                      variable types
#   SymbolicVariable - use this in method argument typing
#
#################################################################

Compat.@compat abstract type Symbolic end
Compat.@compat abstract type AbstractVariable <: Symbolic end
const SymbolicVariable = Union{Symbol, AbstractVariable}


#################################################################
#
# BasicVariable - an example to use during testing
#
#################################################################

type BasicVariable <: AbstractVariable
    sym::Symbol
end
# The following is probably too plain.
show(io::IO, x::BasicVariable) = print(io, x.sym)
(==)(x::BasicVariable, y::BasicVariable) = x.sym == y.sym


#################################################################
#
# @sexpr - return an Expr with variables spliced in
# processExpr - do the Expr splicing
#
#################################################################

function processExpr(x::Expr)
    if x.head == :call
        quoted = Expr(:quote,x.args[1])
        code = :(Expr(:call,$quoted))
        for y in x.args[2:end]
            push!(code.args,processExpr(y))
        end
        return code
    else
        return x
    end
end

processExpr(x::Any) = x

macro sexpr(x)
    esc(processExpr(x))
end


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
# simplify()
#
#################################################################

isnumber(a) = isa(a, Number)

# Numbers and symbols can't be simplified further
simplify(x) = x
simplify(n::Number) = n
simplify(s::SymbolicVariable) = s

# The default is just to simplify arguments.
simplify{T}(x::SymbolParameter{T}, args) = Expr(:call, T, map(simplify, args)...)

function simplify(ex::Expr)
    if ex.head != :call
        return ex
    end
    if all(isnumber, ex.args[2:end]) && length(ex.args) > 1
        return eval(current_module(), ex)
    end
    new_ex = simplify(SymbolParameter(ex.args[1]), ex.args[2:end])
    while !(isequal(new_ex, ex))
        new_ex, ex = simplify(new_ex), new_ex
    end
    return new_ex
end

function sum_numeric_args(args)
    sum = 0
    sym_args = Any[]
    for arg in args
        if isnumber(arg)
            sum += arg
        else
            push!(sym_args, arg)
        end
    end
    (sum, sym_args)
end

function mul_numeric_args(args)
    prod = 1
    sym_args = Any[]
    for arg in args
        if isnumber(arg)
            prod *= arg
        else
            push!(sym_args, arg)
        end
    end
    (prod, sym_args)
end

# Handle `args` of all lengths
function simplify(::SymbolParameter{:+}, args)
    # Remove any 0's in a sum
    args = map(simplify, filter(x -> x != 0, args))
    if length(args) == 0
        return 0
    # Special Case: simplify(:(+x)) == x
    elseif length(args) == 1
        return args[1]
    else
        (sum, sym_args) = sum_numeric_args(args)
        args = sum==0 ? sym_args : [sum; sym_args]
        return Expr(:call, :+, args...)
    end
end

isminus(ex::Expr) = ex.head == :call && ex.args[1] == :- && length(ex.args) == 2
isminus(ex) = false

# Assume length(args) == 3
function simplify(::SymbolParameter{:-}, args)
    # Remove any 0's in a subtraction
    args = map(simplify, filter(x -> x != 0, args))
    if length(args) == 0
        return 0
    # Special Case: simplify(:(x - x)) == 0
    elseif length(args) == 2 && args[1] == args[2]
        return 0
    # Special Case: simplify(:(x - (-y))) == x + y
    elseif length(args) == 2 && isminus(args[2])
        return Expr(:call, :+, args[1], args[2].args[2])
    else
        return Expr(:call, :-, args...)
    end
end

# Handle `args` of all lengths
function simplify(::SymbolParameter{:*}, args)
    # Remove any 1's in a product
    args = map(simplify, filter(x -> x != 1, args))
    if length(args) == 0
        return 1
    # Special Case: simplify(:(*(x))) == x
    elseif length(args) == 1
        return args[1]
    # Special Case: simplify(:(x * y * z * 0)) == 0
    elseif any(args .== 0)
        return 0
    # Special Case: simplify(:(*(-1,x))) == -x
    elseif length(args) == 2 && args[1] == -1
        return Expr(:call, :-, args[2])
    else
        (prod, sym_args) = mul_numeric_args(args)
        args = prod==1 ? sym_args : [prod; sym_args]
        return Expr(:call, :*, args...)
    end
end

# Assume length(args) == 3
function simplify(::SymbolParameter{:/}, args)
    args = map(simplify, args)
    # Special Case: simplify(:(x / 1)) == x
    if args[2] == 1
        return args[1]
    # Special Case: simplify(:(0 / x)) == 0
    elseif args[1] == 0
        return 0
    else
        return Expr(:call, :/, args...)
    end
end

# Assume length(args) == 3
function simplify(::SymbolParameter{:^}, args)
    args = map(simplify, args)
    # Special Case: simplify(:(x ^ 0)) == 1
    if args[2] == 0
        return 1
    # Special Case: simplify(:(x ^ 1)) == x
    elseif args[2] == 1
        return args[1]
    # Special Case: simplify(:(0 ^ x)) == 0
    elseif args[1] == 0
        return 0
    # Special Case: simplify(:(1 ^ x)) == 1
    elseif args[1] == 1
        return 1
    else
        return Expr(:call, :^, args...)
    end
end
