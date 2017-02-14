isdefined(Base, :__precompile__) && __precompile__()

module Calculus
    import Compat
    import Base.ctranspose
    export check_derivative,
           check_gradient,
           check_hessian,
           check_second_derivative,
           deparse,
           derivative,
           differentiate,
           hessian,
           jacobian,
           second_derivative

    # TODO: Debate type system more carefully
    # abstract type BundledFunction end
    # abstract type ScalarFunction end
    # abstract type VectorFunction end
    # abstract type ForwardDifference end
    # abstract type CentralDifference end
    # abstract type ComplexDifference end
    # abstract type GradientEstimator end
    # abstract type HessianEstimator end

    # const NonDifferentiableFunction = Function
    # type DifferentiableFunction
    #   f::Function
    #   g::Function
    # end
    # type TwiceDifferentiableFunction
    #   f::Function
    #   g::Function
    #   h::Function
    # end
    # type NonDifferentiableBundledFunction <: BundledFunction
    #   f::Function
    #   fstorage::Any
    # end
    # type DifferentiableBundledFunction <: BundledFunction
    #   f::Function
    #   g::Function
    #   fstorage::Any
    #   gstorage::Any
    # end
    # type TwiceDifferentiableBundledFunction <: BundledFunction
    #   f::Function
    #   g::Function
    #   h::Function
    #   fstorage::Any
    #   gstorage::Any
    #   hstorage::Any
    # end

    include("finite_difference.jl")
    include("derivative.jl")
    include("check_derivative.jl")
    @Base.deprecate integrate(f,a,b) quadgk(f,a,b)[1]
    @Base.deprecate integrate(f,a,b,method) quadgk(f,a,b)[1]
    include("symbolic.jl")
    include("differentiate.jl")
    include("deparse.jl")
end
