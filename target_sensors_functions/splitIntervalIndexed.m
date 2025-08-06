function [domain1, domain2] = splitIntervalIndexed(subdomain, p, inv_h)
    xmin = subdomain.xmin;
    xmax = subdomain.xmax;
    xmid = floor((xmax + xmin) / 2);
    
    density = p.dx * sum(inv_h(xmin:xmid));
    domain1 = struct('xmin', xmin, 'xmax', xmid, 'density', density);

    density_2 = p.dx * sum(inv_h(xmid+1:xmax));
    domain2 = struct('xmin', xmid+1, 'xmax', xmax, 'density', density_2);
end