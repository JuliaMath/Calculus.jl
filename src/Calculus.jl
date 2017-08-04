isdefined(Base, :__precompile__) && __precompile__()

module Calculus
    using Compat
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
    # struct DifferentiableFunction
    #   f
    #   g
    # end
    # struct TwiceDifferentiableFunction
    #   f
    #   g
    #   h
    # end
    # struct NonDifferentiableBundledFunction <: BundledFunction
    #   f
    #   fstorage::Any
    # end
    # struct DifferentiableBundledFunction <: BundledFunction
    #   f
    #   g
    #   fstorage::Any
    #   gstorage::Any
    # end
    # struct TwiceDifferentiableBundledFunction <: BundledFunction
    #   f
    #   g
    #   h
    #   fstorage::Any
    #   gstorage::Any
    #   hstorage::Any
    # end

    include("finite_difference.jl")
    include("derivative.jl")
    include("check_derivative.jl")
    include("symbolic.jl")
    include("differentiate.jl")
    include("deparse.jl")
end
