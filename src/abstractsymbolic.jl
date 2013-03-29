
export Symbolic, AbstractVariable, SymbolicVariable, BasicVariable, SymbolicExpression
import Base.show, Base.(==), Base.(!=), Base.convert, Base.isequal

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
# SymbolicExpression
#   Operations between SymbolicExpressions and other types
#   normally return SymbolicExpressions
#
#################################################################

type SymbolicExpression <: Symbolic
    ex::Expr
end
sexpr(hd::Symbol, args::ANY...) = SymbolicExpression(Expr(hd, args...))
show(io::IO, x::SymbolicExpression) = print(io, "SymbolicExpression ", x.ex)
isequal(x::SymbolicExpression, y::SymbolicExpression) = x.ex == y.ex
isequal(x::SymbolicExpression, y::Number) = false
isequal(x::Number, y::SymbolicExpression) = false
convert(::Type{Bool},::SymbolicExpression) = false


#################################################################
#
# Methods defined on SymbolicExpressions
# 
#   Set up defaults for operations on Symbolic variables for many
#   common methods.
#
#################################################################


unary_functions = [:(+), :(-), :(!),
                   :abs, :sign, :acos, :acosh, :asin,
                   :asinh, :atan, :atanh, :sin, :sinh,
                   :cos, :cosh, :tan, :tanh, :ceil, :floor,
                   :round, :trunc, :exp, :exp2, :expm1, :log, :log10, :log1p,
                   :log2, :logb, :sqrt, :gamma, :lgamma, :digamma,
                   :erf, :erfc, :square,
                   :min, :max, :prod, :sum, :mean, :median, :std,
                   :var, :norm,
                   :diff, 
                   :cumprod, :cumsum, :cumsum_kbn, :cummin, :cummax,
                   :fft,
                   :any, :all,
                   :iceil,  :ifloor, :itrunc, :iround,
                   :angle,
                   :sin,    :cos,    :tan,    :cot,    :sec,   :csc,
                   :sinh,   :cosh,   :tanh,   :coth,   :sech,  :csch,
                   :asin,   :acos,   :atan,   :acot,   :asec,  :acsc,
                   :acoth,  :asech,  :acsch,  :sinc,   :cosc,
                   :transpose, :ctranspose]

binary_functions = [:(==), :(.==), :(!=), :(.!=), :isless,
                    :(>), :(.>), :(>=), :(.>=), :(<), :(.<),
                    :(<=), :(.<=),
                    :(==), :(!=), :isless, :(>), :(>=),
                    :(<), :(<=),
                    :(+), :(.+), :(-), :(.-), :(*), :(.*), :(/), :(./),
                    :(.^), :(^), :(div), :(mod), :(fld), :(rem),
                    :(&), :(|), :($),
                    :atan2,
                    :dot, :cor, :cov]

expr(x) = x
expr(x::SymbolicExpression) = x.ex

# special case to avoid a warning:
import Base.(^)
(^)(x::Symbolic, y::Integer) = sexpr(:call, :^, expr(x), y)

for f in binary_functions
    # use :toplevel to import from Base
    eval(Expr(:toplevel, Expr(:import, :Base, f)))
    @eval ($f)(x::Symbolic, y::Symbolic) = sexpr(:call, $(Meta.quot(f)), expr(x), expr(y))
    @eval ($f)(x::Symbolic, y::Number) = sexpr(:call, $(Meta.quot(f)), expr(x), y)
    @eval ($f)(x::Symbolic, y::AbstractArray) = sexpr(:call, $(Meta.quot(f)), expr(x), y)
    @eval ($f)(x::Number, y::Symbolic) = sexpr(:call, $(Meta.quot(f)), x, expr(y))
    @eval ($f)(x::AbstractArray, y::Symbolic) = sexpr(:call, $(Meta.quot(f)), x, expr(y))
end 

for f in unary_functions
    eval(Expr(:toplevel, Expr(:import, :Base, f)))
    @eval ($f)(x::Symbolic, args...) = sexpr(:call, $(Meta.quot(f)), expr(x), map(expr, args)...)
end
