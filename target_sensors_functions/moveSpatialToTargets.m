function [spatial_sensors] = moveSpatialToTargets(spatial_sensors, target_sensors, p, ref_solution)
    interpolant = griddedInterpolant(p.x, ref_solution, 'linear');
    weight =.9;
    for i=1:length(target_sensors)
        distances = abs(spatial_sensors - target_sensors(i));
    
        % Step 2: Find the index of the closest point
        [~, closest_idx] = min(distances);
        
        closest_point = spatial_sensors(closest_idx);
        direction_vector = target_sensors(i) - closest_point;
        
        % Step 3: Get the coordinates of the closest point
        closest_point = spatial_sensors(closest_idx);
        local_vel = mean(abs(ref_solution));

        
        % new_point = closest_point + weight*direction_vector + (1-weight)*local_vel;
        new_point = closest_point + p.dt*local_vel*direction_vector;
        new_point = mod(new_point, p.Lx);

        spatial_sensors(closest_idx) = new_point;
        
    end
    spatial_sensors = sort(unique(spatial_sensors));
end
