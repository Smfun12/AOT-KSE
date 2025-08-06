function [domains] = splitIntervalFurtherIfRemainingSensors(h, p, domains, remaining_sensors)
    while remaining_sensors > 0
        [~, idx] = max([domains.density]);
        domain = domains(idx);
        
        [domain1, domain2] = splitIntervalIndexed(domain, p, 1./h);
        a = p.x(domain1.xmin);
        b = p.x(domain1.xmax);
        c = p.x(domain2.xmin);
        d = p.x(domain2.xmax);
        
        domain1.sensors = (a+b)/2;
        domain2.sensors = (c+d)/2;
        domains(idx) = [];
        domains = [domains, [domain1, domain2]];
        remaining_sensors = remaining_sensors - 1;
    end
end

