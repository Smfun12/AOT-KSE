function w = computeDensityForInterval(inv_h, a, b, p)
    x = p.x;
    F = griddedInterpolant(x, inv_h);
    h = @(x) F(x);
    w = integral(@(x) h(x), a, b);
end
