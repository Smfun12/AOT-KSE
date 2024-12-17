function [spatial_sensors, distanceSum] = moveSpatialToTargetsPeriodically(spatial_sensors, target_sensors, p, ref_solution)
    interpolant = griddedInterpolant(p.x, ref_solution, 'linear');
    temp_list_of_used_indices = [];
    spatial_sensors_extended = [spatial_sensors(end)-p.Lx, spatial_sensors, p.Lx + spatial_sensors(1)];
    distanceSum =[];
    % if length(spatial_sensors) > length(target_sensors)
    %     disp("Some spatial sensors are staying in the same place")
    % end
    for i=1:length(target_sensors)
        if i > length(spatial_sensors)
            % disp("All references sensors have been mapped to target")
            break
        end
        periodic_case = false;
        distances = abs(spatial_sensors_extended - target_sensors(i));
    
        % Step 2: Find the index of the closest point
        [~, closest_idx] = min(distances);
        while ismember(closest_idx, temp_list_of_used_indices)
            % Setting a large distance which exceeds Lx
            distances(closest_idx) = 1e3;
            [~, closest_idx] = min(distances);
        end

        temp_list_of_used_indices = [temp_list_of_used_indices, closest_idx];
        if closest_idx == 1
            temp_list_of_used_indices = [temp_list_of_used_indices, length(distances)-1];
        elseif closest_idx == length(distances)
            temp_list_of_used_indices = [temp_list_of_used_indices, 2];
        end

        
        if closest_idx == 1
            periodic_point = spatial_sensors_extended(closest_idx);
            direction_vector = target_sensors(i) - periodic_point;
            closest_idx = length(spatial_sensors);
            periodic_case = true;
        elseif closest_idx == length(spatial_sensors_extended)
            periodic_case = true;
            periodic_point = spatial_sensors_extended(closest_idx);
            closest_idx = 1;
            direction_vector = target_sensors(i) - periodic_point;
        else
            closest_idx = closest_idx - 1;
            closest_point = spatial_sensors(closest_idx);
            direction_vector = target_sensors(i) - closest_point; 
        end
        % Step 3: Get the coordinates of the closest point
        closest_point = spatial_sensors(closest_idx);
        % local_vel = abs(interpolant(closest_point));
        local_vel = mean(abs(ref_solution));

        new_point = closest_point + p.dt*local_vel*direction_vector;
        new_point = mod(new_point, p.Lx);
        if periodic_case && new_point < closest_point
            new_point = min(new_point, target_sensors(i));
        elseif periodic_case && closest_point <= new_point
            new_point = max(target_sensors(i), new_point);
        elseif ~periodic_case && closest_point < new_point
            new_point = min(target_sensors(i), new_point);
        elseif ~periodic_case && new_point <= closest_point
            new_point = max(new_point, target_sensors(i));
        end
        
        spatial_sensors(closest_idx) = new_point;
        % if periodic_case
        %     disp("Big vector")
        % end
        distanceSum = [distanceSum, abs(direction_vector)];
        
    end
    spatial_sensors = sort(unique(spatial_sensors));
end

function dispayPoints(target_sensor, closest_point, new_point)
figure(10)
scatter(target_sensor, 0, "red", "filled")
hold on
scatter(closest_point, 0, "blue", "filled")
scatter(new_point, 0, "green", "filled")
end