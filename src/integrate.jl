function adaptive_simpsons_inner(f::Function, a::Real, b::Real,
                                 epsilon::Real, S::Real,
                                 fa::Real, fb::Real, fc::Real, bottom::Int)
    c = (a + b) / 2
    h = b - a
    d = (a + c) / 2
    g = (c + b) / 2
    fd = f(d)
    fe = f(g)
    Sleft = (h / 12) * (fa + 4 * fd + fc)
    Sright = (h / 12) * (fc + 4 * fe + fb)
    S2 = Sleft + Sright
    if bottom <= 0 || abs(S2 - S) <= 15 * epsilon
        return S2 + (S2 - S) / 15
    end
    return adaptive_simpsons_inner(f, a, c, epsilon / 2, Sleft,  fa, fc, fd, bottom - 1) +
           adaptive_simpsons_inner(f, c, b, epsilon / 2, Sright, fc, fb, fe, bottom - 1)
end

function adaptive_simpsons_outer(f::Function, a::Real, b::Real,
                                 accuracy::Real=10e-10, max_iterations::Int=50)
    c = (a + b) / 2
    h = b - a
    fa = f(a)
    fb = f(b)
    fc = f(c)
    S = (h / 6) * (fa + 4 * fc + fb)
    return adaptive_simpsons_inner(f, a, b, accuracy, S, fa, fb, fc, max_iterations)
end

function monte_carlo(f::Function, a::Real, b::Real, iterations::Int=10_000)
    estimate = 0.0
    width = (b - a)
    for i in 1:iterations
        x = width * rand() + a
        estimate += f(x) * width
    end
    return estimate / iterations
end

function integrate(f::Function, a::Real, b::Real, method::Symbol=:simpsons)
    if method == :simpsons
        adaptive_simpsons_outer(f, a, b)
    elseif method == :monte_carlo
        monte_carlo(f, a, b)
    else
        error("Unknown method of integration: $(method)")
    end
end
