function [domain1, domain2] = splitInterval(subdomain, p, inv_h)
        xmid = (subdomain.xmax + subdomain.xmin) / 2;
        
        density = computeDensityForInterval(inv_h, subdomain.xmin, xmid, p);
        domain1 = struct('xmin', subdomain.xmin, 'xmax', xmid, 'density', density);

        density_2 = computeDensityForInterval(inv_h, xmid, subdomain.xmax, p);
        domain2 = struct('xmin', xmid, 'xmax', subdomain.xmax, 'density', density_2);
end

