module Calculus
    export derivative_numer

    require(file_path(julia_pkgdir(), "Calculus", "src", "estimate_gradient.jl"))
    require(file_path(julia_pkgdir(), "Calculus", "src", "derivative.jl"))
end
