function [spatial_sensors] = moveSpatialToTargetsPeriodically(var, p)
    targets = var.target_sensors;
    points = var.sensors;
    if norm(targets-points) == 0
        spatial_sensors = points;
        return
    end
    mapping = var.mapping;
    mean_flow = var.sensor_speed*1.3;
    domain_length = p.Lx;

    for i = 1:length(targets)
        if i > length(points)
            break;
        end
        % Compute distance to target
        % min_index = mapping(i);
        min_index = i;
        % [~, min_index] = min(targets(i) - points);
        dist_to_target = targets(i) - points(min_index);
        
        % Account for periodic boundary conditions
        if dist_to_target > domain_length / 2
            dist_to_target = dist_to_target - domain_length;
        elseif dist_to_target < -domain_length / 2
            dist_to_target = dist_to_target + domain_length;
        end
        
        % Update position towards the target
        if (abs(dist_to_target) > mean_flow * p.dt)
            
            points(min_index) = points(min_index) + mean_flow * p.dt * sign(dist_to_target);
        else
            points(min_index) = targets(i);
        end
        
        
        % Enforce periodic boundary conditions
        if points(min_index) > domain_length
            points(min_index) = points(min_index) - domain_length;
        elseif points(min_index) < 0
            points(min_index) = points(min_index) + domain_length;
        end
    end
    spatial_sensors = (points);
end
