function fzero(f::Function, a::Real, b::Real;
               maxiter::Integer=100, tol::Real=1e-07, method::Symbol=:ridders)
    if method == :ridders
        ridders(f, a, b, maxiter = maxiter, tol = tol)
    elseif method == :bisect
        bisect(f, a, b, maxiter = maxiter, tol = tol)
    elseif method == :brent
        brent_dekker(f, a, b, maxiter = maxiter, tol = tol)
    else
        error("Unknown method of root finding: $(method).")
    end
end


function ridders(f::Function, a::Real, b::Real;
                 maxiter::Integer = 100, tol::Real = 1e-07)

    x1 = a;     x2 = b
    f1 = f(x1); f2 = f(x2)
    if f1 * f2 > 0
        error("f(a) and f(b) must have different signs.")
    elseif f1 == 0
        return x1
    elseif f2 == 0
        return f2
    end

    niter = 2
    while niter < maxiter && abs(x1 - x2) > tol
        xm = (x1 + x2)/2.0
        fm = f(xm)
        if fm == 0; return xm; end

        x3 = xm + (xm - x1) * sign(f1 - f2) * fm / sqrt(fm^2 - f1 * f2)
        f3 = f(x3)
        niter += 2
        if f3 == 0; return x3; end

        if fm * f3 < 0
            x1 = xm;  f1 = fm
            x2 = x3;  f2 = f3
        elseif f1 * f3 < 0
            x2 = x3;  f2 = f3
        elseif f2 * f3 < 0
            x1 = x3;  f1 = f3
        else
            error("Inform the maintainer: you should never get here.")
        end
    end

    return (x1 + x2) / 2.0
end


function bisect(f::Function, a::Real, b::Real;
                maxiter::Integer = 100, tol::Real = 1e-07)

	if f(a)*f(b) > 0
	    error("f(a) and f(b) must have different signs.")
	end

	x1 = min(a, b); x2 = max(a,b)
	xm = (x1+x2) / 2.0

	n = 0
	while abs(x1-x2)/2.0 > tol
		n += 1
		if abs(f(xm)) <= tol; break; end
		if f(x1)*f(xm) < 0
			x2 = xm
		else
			x1 = xm
		end
		xm = (x1+x2) / 2.0
		if n >= maxiter; break; end
	end

	return xm
end


function brent_dekker(f::Function, a::Real, b::Real;
                       maxiter::Integer = 100, tol::Real = 1e-07)

	x1 = a; f1 = f(x1)
	if f1 == 0; return a; end
	x2 = b; f2 = f(x2)
	if f2 == 0; return b; end
	if (f1*f2 > 0.0)
	    error("Brent-Dekker: Root is not bracketed in [a, b]")
	end

	x3 = 0.5*(a+b)
	# Beginning of iterative loop
	niter = 1
	while (niter <= maxiter)
		f3 = f(x3)
		if abs(f3) < tol
		    x0 = x3
		    break
		end

		# Tighten brackets [a, b] on the root
		if f1*f3 < 0.0
		    b = x3
		else
		    a = x3
		end
		if (b-a) < tol*max(abs(b), 1.0)
		    x0 = 0.5*(a + b)
		    break
	    end

		# Try quadratic interpolation
		denom = (f2 - f1)*(f3 - f1)*(f2 - f3)
		numer = x3*(f1 - f2)*(f2 - f3 + f1) + f2*x1*(f2 - f3) + f1*x2*(f3 - f1)
		# if denom==0, push x out of bracket to force bisection
		if denom == 0
			dx = b - a
		else
			dx = f3*numer/denom
		end

		x = x3 + dx
		# If interpolation goes out of bracket, use bisection.
		if (b - x)*(x - a) < 0.0
			dx = 0.5*(b - a)
			x  = a + dx;
		end

		# Let x3 <-- x & choose new x1, x2 so that x1 < x3 < x2.
		if x1 < x3
			x2 = x3; f2 = f3
		else
			x1 = x3; f1 = f3
		end

		niter += 1
		if abs(x - x3) < tol
		    x0 = x
		    break
	    end
		x3 = x
	end

    if (niter > maxiter)
        println("Maximum number of iterations has been reached.")
    end

    prec = min(abs(x1-x3), abs(x2-x3))
    return x3
end
