function adaptiveSimpsons(f::Function,  a,  b,  epsilon, S,  fa,  fb,  fc, bottom)
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
    return adaptiveSimpsons(f, a, c, epsilon / 2, Sleft,  fa, fc, fd, bottom - 1) +
           adaptiveSimpsons(f, c, b, epsilon / 2, Sright, fc, fb, fe, bottom - 1)
end

function integrate(f::Function, a::Real, b::Real, accuracy::Real, max_iterations::Int)
    c = (a + b) / 2
    h = b - a
    fa = f(a)
    fb = f(b)
    fc = f(c)
    S = (h / 6) * (fa + 4 * fc + fb)
  return adaptiveSimpsons(f, a, b, accuracy, S, fa, fb, fc, max_iterations)
end
integrate(f::Function, a::Real, b::Real) = integrate(f, a, b, 1e-9, 50)
