#
# Derivatives of f: R -> R
#

@testset "Derivatives of f: R -> R" begin
    @testset "f(x) = x²" begin
        @testset "x = $x" for x in 10.0.^collect(-10:10)
            @test Calculus.finite_difference(x -> x^2, x, :forward) ≈ 2x rtol = 1e-4
            @test Calculus.finite_difference(x -> x^2, x, :central) ≈ 2x rtol = 1e-4
            @test Calculus.finite_difference(x -> x^2, x)           ≈ 2x rtol = 1e-4
        end
    end

    @testset "f(x) = sin(x)" begin
        @testset "x = $x" for x in 10.0.^collect(-10:1)
            @test Calculus.finite_difference(x -> sin(x), x, :forward) ≈ cos(x) rtol = 1e-4
            @test Calculus.finite_difference(x -> sin(x), x, :central) ≈ cos(x) rtol = 1e-4
            @test Calculus.finite_difference(x -> sin(x), x)           ≈ cos(x) rtol = 1e-4
        end
    end

    @testset "f(x) = exp(-x)" begin
        @testset "x = $x" for x in 10.0.^collect(-1:10)
            @test Calculus.finite_difference(x -> exp(-x), x, :forward) ≈ -exp(-x) rtol = 1e-4
            @test Calculus.finite_difference(x -> exp(-x), x, :central) ≈ -exp(-x) rtol = 1e-4
            @test Calculus.finite_difference(x -> exp(-x), x)           ≈ -exp(-x) rtol = 1e-4
        end
    end

    @testset "f(x) = log(x)" begin
        @testset "x = $x" for x in 10.0.^collect(-10:10)
            @test Calculus.finite_difference(x -> log(x), x, :forward) ≈ 1/x rtol = 1e-4
            @test Calculus.finite_difference(x -> log(x), x, :central) ≈ 1/x rtol = 1e-4
            @test Calculus.finite_difference(x -> log(x), x, :complex) ≈ 1/x rtol = 1e-4
        end
    end
end


#
# Gradients of f: R^n -> R
#

@testset "Gradients of f: R^n -> R" begin
    @test norm(Calculus.finite_difference(x -> x[1]^2, [1.0], :forward) - [2.0]) < 10e-4
    @test norm(Calculus.finite_difference(x -> x[1]^2, [1.0], :central) - [2.0]) < 10e-4
    @test norm(Calculus.finite_difference(x -> x[1]^2, [1.0]) - [2.0]) < 10e-4

    @test norm(Calculus.finite_difference(x -> sin(x[1]), [1.0], :forward) - [cos(1.0)]) < 10e-4
    @test norm(Calculus.finite_difference(x -> sin(x[1]), [1.0], :central) - [cos(1.0)]) < 10e-4
    @test norm(Calculus.finite_difference(x -> sin(x[1]), [1.0]) - [cos(1.0)]) < 10e-4

    @test norm(Calculus.finite_difference(x -> exp(-x[1]), [1.0], :forward) - [-exp(-1.0)]) < 10e-4
    @test norm(Calculus.finite_difference(x -> exp(-x[1]), [1.0], :central) - [-exp(-1.0)]) < 10e-4
    @test norm(Calculus.finite_difference(x -> exp(-x[1]), [1.0]) - [-exp(-1.0)]) < 10e-4
end

#
# Second derivatives of f: R -> R
#

@testset "Second derivatives of f: R -> R" begin
    @test norm(Calculus.finite_difference_hessian(x -> x^2, x -> 2 * x, 1.0) - 2.0) < 10e-4
    @test norm(Calculus.finite_difference_hessian(x -> x^2, x -> 2 * x, 10.0) - 2.0) < 10e-4
    @test norm(Calculus.finite_difference_hessian(x -> x^2, x -> 2 * x, 100.0) - 2.0) < 10e-4

    @test norm(Calculus.finite_difference_hessian(x -> x^2, 1.0) - 2.0) < 10e-4
    @test norm(Calculus.finite_difference_hessian(x -> x^2, 10.0) - 2.0) < 10e-4
    @test norm(Calculus.finite_difference_hessian(x -> x^2, 100.0) - 2.0) < 10e-4
end

#
# Hessians of f: R^n -> R
#

@testset "Hessians of f: R^n -> R" begin
    fx(x) = sin(x[1]) + cos(x[2])
    gx = Calculus.gradient(fx)
    x₁, x₂ = 1.0, 1.0
    x = [x₁, x₂]
    @test norm(gx(x) - [cos(x₁), -sin(x₂)]) < 10e-4
    @test norm(Calculus.finite_difference_hessian(fx, gx, x, :central) - [-sin(x₁) 0.0; 0.0 -cos(x₂)]) < 10e-4
    @test norm(Calculus.finite_difference_hessian(fx, x) - [-sin(x₁) 0.0; 0.0 -cos(x₂)]) < 10e-4
end

#
# Taylor Series first derivatives
#

@testset "Taylor Series first derivatives" begin
    @test norm(Calculus.taylor_finite_difference(x -> x^2, 1.0, :forward) - 2.0) < 10e-4
    @test norm(Calculus.taylor_finite_difference(x -> x^2, 1.0, :central) - 2.0) < 10e-4
end

#
# Taylor Series second derivatives
#

# TODO: Fill this in

#
# Speed comparisons
#

@elapsed Calculus.finite_difference(x -> x^2, 1.0, :forward)
@elapsed Calculus.finite_difference(x -> x^2, 1.0, :central)
@elapsed Calculus.finite_difference(x -> x^2, 1.0)
@elapsed Calculus.taylor_finite_difference(x -> x^2, 1.0, :forward, 10e-4)
@elapsed Calculus.taylor_finite_difference(x -> x^2, 1.0, :central, 10e-4)
