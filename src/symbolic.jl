
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

abstract Symbolic
abstract AbstractVariable <: Symbolic
typealias SymbolicVariable Union(Symbol, AbstractVariable)


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


# Numbers and symbols can't be simplified further
simplify(x) = x
simplify(n::Number) = n
simplify(s::SymbolicVariable) = s

# The default is just to simplify arguments.
simplify{T}(x::SymbolParameter{T}, args) = Expr(:call, T, map(x -> simplify(x), args)...)

function simplify(ex::Expr)
    if ex.head != :call
        return ex
    end
    if all(map(a -> isa(a, Number), ex.args[2:end]))
        return eval(ex)
    end
    new_ex = simplify(SymbolParameter(ex.args[1]), ex.args[2:end])
    while new_ex != ex
        new_ex, ex = simplify(new_ex), new_ex
    end
    return new_ex
end


# Handles all lengths for ex.args
# Removes any 0's in a sum
function simplify(::SymbolParameter{:+}, args)
    new_args = map(x -> simplify(x), filter(x -> x != 0, args))
    if length(new_args) == 0
        return 0
    # Special Case: simplify(:(+x)) == x
    elseif length(new_args) == 1
        return new_args[1]
    else
        return Expr(:call, :+, new_args...)
    end
end

# Assumes length(ex.args) == 3
# Removes any 0's in a subtraction
function simplify(::SymbolParameter{:-}, args)
    new_args = map(x -> simplify(x), filter(x -> x != 0, args))
    if length(new_args) == 0
        return 0
    # Special Case: simplify(:(x - x)) == 0
    elseif length(new_args) == 2 && new_args[1] == new_args[2]
        return 0
    else
        return Expr(:call, :-, new_args...)
    end
end

# Handles all lengths for ex.args
# Removes any 1's in a product
function simplify(::SymbolParameter{:*}, args)
    new_args = map(x -> simplify(x), filter(x -> x != 1, args))
    if length(new_args) == 0
        return 1
    # Special Case: simplify(:(*x)) == x
    elseif length(new_args) == 1
        return new_args[1]
    # Special Case: simplify(:(x * y * z * 0)) == 0
    elseif any(new_args .== 0)
        return 0
    else
        return Expr(:call, :*, new_args...)
    end
end

# Assumes length(ex.args) == 3
function simplify(::SymbolParameter{:/}, args)
    new_args = map(x -> simplify(x), args)
    # Special Case: simplify(:(x / 1)) == x
    if new_args[2] == 1
        return new_args[1]
    # Special Case: simplify(:(0 / x)) == 0
    elseif new_args[1] == 0
        return 0
    else
        return Expr(:call, :/, new_args...)
    end
end

# Assumes length(ex.args) == 3
function simplify(::SymbolParameter{:^}, args)
    new_args = map(x -> simplify(x), args)
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
        return Expr(:call, :^, new_args...)
    end
end
