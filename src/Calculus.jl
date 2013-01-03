module Calculus
    export derivative_numer

    include(file_path(julia_pkgdir(), "Calculus", "src", "estimate_gradient.jl"))
    include(file_path(julia_pkgdir(), "Calculus", "src", "derivative.jl"))
end
