% function [spatial_sensors, distanceSum] = moveSpatialToTargetsPeriodically(spatial_sensors, target_sensors, p, ref_solution)
%     interpolant = griddedInterpolant(p.x, ref_solution, 'linear');
%     temp_list_of_used_indices = [];
%     spatial_sensors_extended = [spatial_sensors(end)-p.Lx, spatial_sensors, p.Lx + spatial_sensors(1)];
%     distanceSum =[];
%     % if length(spatial_sensors) > length(target_sensors)
%     %     disp("Some spatial sensors are staying in the same place")
%     % end
%     for i=1:length(target_sensors)
%         if i > length(spatial_sensors)
%             % disp("All references sensors have been mapped to target")
%             break
%         end
%         periodic_case = false;
%         distances = abs(spatial_sensors_extended - target_sensors(i));
% 
%         % Step 2: Find the index of the closest point
%         [~, closest_idx] = min(distances);
%         while ismember(closest_idx, temp_list_of_used_indices)
%             % Setting a large distance which exceeds Lx
%             distances(closest_idx) = 1e3;
%             [~, closest_idx] = min(distances);
%         end
%         if length(temp_list_of_used_indices) == length(spatial_sensors_extended)
%             disp("No more sensors");
%         end
% 
%         temp_list_of_used_indices = [temp_list_of_used_indices, closest_idx];
%         if closest_idx == 1
%             temp_list_of_used_indices = [temp_list_of_used_indices, length(distances)-1];
%         elseif closest_idx == length(distances)-1
%             temp_list_of_used_indices = [temp_list_of_used_indices, 1];
%         elseif closest_idx == length(distances)
%             temp_list_of_used_indices = [temp_list_of_used_indices, 2];
%         elseif closest_idx == 2
%             temp_list_of_used_indices = [temp_list_of_used_indices, length(distances)];
%         end
% 
% 
%         if closest_idx == 1
%             periodic_point = spatial_sensors_extended(closest_idx);
%             direction_vector = target_sensors(i) - periodic_point;
%             closest_idx = length(spatial_sensors);
%             periodic_case = true;
%         elseif closest_idx == length(spatial_sensors_extended)
%             periodic_case = true;
%             periodic_point = spatial_sensors_extended(closest_idx);
%             closest_idx = 1;
%             direction_vector = target_sensors(i) - periodic_point;
%         else
%             closest_idx = closest_idx - 1;
%             closest_point = spatial_sensors(closest_idx);
%             direction_vector = target_sensors(i) - closest_point; 
%         end
%         % Step 3: Get the coordinates of the closest point
%         closest_point = spatial_sensors(closest_idx);
%         local_vel = mean(abs(ref_solution));
%         % char_velocity = 1.3;
% 
%         if direction_vector > 0
%             direction_vector = 1;
%         elseif direction_vector < 0
%             direction_vector = -1;
%         end
% 
%         new_point = closest_point + p.dt*local_vel*direction_vector;
%         new_point = mod(new_point, p.Lx);
%         if periodic_case && new_point < closest_point
%             new_point = min(new_point, target_sensors(i));
%         elseif periodic_case && closest_point <= new_point
%             new_point = max(target_sensors(i), new_point);
%         elseif ~periodic_case && closest_point < new_point
%             new_point = min(target_sensors(i), new_point);
%         elseif ~periodic_case && new_point <= closest_point
%             new_point = max(new_point, target_sensors(i));
%         end
% 
%         spatial_sensors(closest_idx) = new_point;
%         distanceSum = [distanceSum, abs(direction_vector)];
% 
%     end
%     spatial_sensors = sort(unique(spatial_sensors));
% end
% 
% function dispayPoints(target_sensor, closest_point, new_point)
% figure(10)
% scatter(target_sensor, 0, "red", "filled")
% hold on
% scatter(closest_point, 0, "blue", "filled")
% scatter(new_point, 0, "green", "filled")
% end

function [spatial_sensors, distanceSum] = moveSpatialToTargetsPeriodically(var, p, ref_solution)
    targets = var.target_sensors;
    points = var.sensors;
    mapping = var.mapping;
    % mean_flow = mean(abs(ref_solution));
    mean_flow = 1.3;
    domain_length = p.Lx;
    distanceSum = 0;
    for i = 1:length(targets)
        if i > length(points)
            break;
        end
        % Compute distance to target
        % min_index = mapping(i);
        min_index = i;
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
    spatial_sensors = ((points));
end
