
export Symbolic, AbstractVariable, SymbolicVariable, BasicVariable, processExpr, @sexpr
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
