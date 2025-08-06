function [mesh]= intervalBasedTargetLocations(p, var, ref_solution) 
    h_hat = determineH(p, var.K, ref_solution);
    segments = struct('xmin', 1, 'xmax', p.N, 'density', sum(1./h_hat)*p.dx);
    while length(segments) < p.num_sensors
    
        [~, idx] = max([segments.density]);
        seg = segments(idx);
        
        [left, right] = splitIntervalIndexed(seg, p, 1./h_hat);
        
        segments(idx) = [];
        segments(end+1) = left;
        segments(end+1) = right;
    end
    sensors = ((p.x([segments.xmin]) + p.x([segments.xmax])) / 2);
    mesh = sort(unique(sensors));
end