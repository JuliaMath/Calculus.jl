module Calculus
    import Base.ctranspose
    export check_derivative,
           check_gradient,
           check_hessian,
           check_second_derivative,
           derivative,
           gradient,
           hessian,
           integrate,
           jacobian,
           second_derivative

    # TODO: Debate type system more carefully
    # abstract BundledFunction
    # abstract ScalarFunction
    # abstract VectorFunction
    # abstract ForwardDifference
    # abstract CentralDifference
    # abstract ComplexDifference
    # abstract GradientEstimator
    # abstract HessianEstimator

    # typealias NonDifferentiableFunction Function
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

    # import Base.convert
    # convert(::Function, df::DifferentiableFunction) = df.f

    include(file_path(julia_pkgdir(), "Calculus", "src", "finite_difference.jl"))
    include(file_path(julia_pkgdir(), "Calculus", "src", "derivative.jl"))
    include(file_path(julia_pkgdir(), "Calculus", "src", "check_derivative.jl"))
    include(file_path(julia_pkgdir(), "Calculus", "src", "integrate.jl"))
end
