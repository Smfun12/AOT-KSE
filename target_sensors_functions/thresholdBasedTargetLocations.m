function [sensors, final_subDomains] = thresholdBasedTargetLocations(h, p)
    
    a = 1;
    b = p.N;
    density = p.dx*sum(1./h);
    fullGrid = struct('xmin', a,'xmax', b, 'density', density);
    [final_subDomains] = splitIntervalsFromH(h, p, fullGrid);
    [final_subDomains] = splitIntervalFurtherIfRemainingSensors(h, p, final_subDomains, p.num_sensors - length(final_subDomains)); 
    sensors = sort(unique([final_subDomains.sensors]));
end