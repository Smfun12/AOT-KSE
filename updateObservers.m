function [var] = updateObservers(var, p, u_hat)
    ref_solution = ifft(u_hat, 'symmetric');
    interpolant = griddedInterpolant(p.x, ref_solution, 'linear');
    switch var.observer_type
        case "Uniform"
            var.sensors = var.sensors;
            % h = p.x(var.sensors(2))-p.x(var.sensors(1));
            % nu = 1;
            % my_k = 0.8;
            % nudg_parameter = my_k / nu;
            % c = p.Lx/pi;
            % C = (4/3)^(3/4)* (nudg_parameter^5*c/my_k)^(-1/4);
            % u_x_star = abs(gradient(ref_solution));
            % K = (h/C).^(4/3) + u_x_star;
            % var.Ks = [var.Ks, K'];
            % Ks = var.Ks;
            % save("K.mat", "Ks")
        case "Creeps"
            sensors = var.sensors;
            for i=1:length(sensors)
                dir = randi(2);
                if dir == 1
                    if sensors(i) == p.N
                        sensors(i) = 1;
                    end
                    sensors(i) = sensors(i) + 1;
                    
                else
                    if sensors(i) == 1
                        sensors(i) = p.N;
                    end
                    sensors(i) = sensors(i) - 1;
                end
            end
            var.sensors = sort(unique(sensors));

        case "Lagrangian"
            
            for i=1:length(var.sensors)
                random_noise = -1 + (2).*rand(1,1);
                var.sensors(i) = var.sensors(i) + p.dt*(interpolant(var.sensors(i)) + random_noise*var.amplitude);
                var.sensors(i) = mod(var.sensors(i), p.Lx);
            end
            var.sensors = sort(unique(var.sensors));
            
        case {"Dynamic-DD"}
            
            r = var.r;
            psensors = var.p;
            window = r;
            end_idx = window;
            if mod(p.ti, window) == 0
                end_idx = min(3000, p.ti + window);
            end
            start_idx = min(3000, max(1, end_idx-window));

            [Psi, ~, ~] = svd(p.big_basis(:, start_idx:end_idx), 'econ');
            if psensors <= r
                [~, ~, pivot] =  qr(Psi(:,1:r)','vector');
            else
                [~, ~, pivot] =  qr(Psi*Psi','vector');
            end
            % if sensors_type == 1
                % sensors = pivot(1:p);
            % else
            url = 'http://127.0.0.1:5000/api/sensors';
            data = struct('basis', Psi, 'all_sensors', pivot, "X_train", p.big_basis(:, start_idx:end_idx), 'distance', 2, 'n_sensors', psensors);
            
            options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json', 'Timeout', 3600);
            response = webwrite(url, data, options);
            sensors = response.message + 1;
            % spatial_sensors = moveSpatialToTargetsPeriodically(var.sensors, sensors, p, ref_solution);
            var.sensors = sort(sensors);
            
        case "Static-DD"
            if p.ti == 1
                r = var.r;
                psens = var.p;
                [Psi, ~, ~] = svd(p.big_basis, 'econ');
                if psens <= r
                    [~, ~, pivot] =  qr(Psi(:,1:r)','vector');
                else
                    [~, ~, pivot] =  qr(Psi*Psi','vector');
                end
                url = 'http://127.0.0.1:5000/api/sensors';
                data = struct('basis', Psi, 'all_sensors', pivot, "X_train", [], 'distance', 2, 'n_sensors', psens);
                options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json', 'Timeout', 3600);
                response = webwrite(url, data, options);
                sensors = response.message + 1;
                var.sensors = sort(sensors');
            end
        case "Random-DD"
            if mod(var.basis_counter,var.temp_basis_size) == 0
                r = var.r;
                psens = var.p;

                [Psi, ~, ~] = svd(var.temp_basis(:, 1:2), 'econ');
                if psens <= r
                    [~, ~, pivot] =  qr(Psi(:,1:r)','vector');
                else
                    [~, ~, pivot] =  qr(Psi*Psi','vector');
                end

                url = 'http://127.0.0.1:5000/api/sensors';
                data = struct('basis', Psi, 'all_sensors', pivot, "X_train", var.temp_basis(:, 1:2), 'distance', 2, 'n_sensors', psens);
                options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json', 'Timeout', 3600);
                response = webwrite(url, data, options);
                sensors = response.message + 1;
                sensors = sensors';
                % spatial_sensors = moveSpatialToTargetsPeriodically(var.sensors, p.x(sensors), p, ref_solution);
                var.sensors = sort(sensors);
                % var.sensors = sort(sensors);
                var.temp_basis = [];
            else
                sensors = randi([1, p.N], [1,length(var.sensors)]);
                sensors = unique(sensors);
                var.sensors = sort(sensors);
            end
        case "Zhao-DD"
            if mod(var.basis_counter,var.temp_basis_size) == 0
                r = var.r;
                psens = var.p;

                [Psi, ~, ~] = svd(var.temp_basis(:, 1:2), 'econ');
                if psens <= r
                    [~, ~, pivot] =  qr(Psi(:,1:r)','vector');
                else
                    [~, ~, pivot] =  qr(Psi*Psi','vector');
                end
                
                url = 'http://127.0.0.1:5000/api/sensors';
                data = struct('basis', Psi, 'all_sensors', pivot, "X_train", var.temp_basis(:, 1:2), 'distance', 2, 'n_sensors', psens);
                options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json', 'Timeout', 3600);
                response = webwrite(url, data, options);
                sensors = response.message + 1;
                sensors = sensors';
                % spatial_sensors = moveSpatialToTargetsPeriodically(var.sensors, p.x(sensors), p, ref_solution);
                var.sensors = sort(sensors);
                var.temp_basis = [];
            end
        case "Random"
            var.sensors = sort(unique(randi([1, p.N], 1,32)));
            [h_hat] = sensorsToH(p.x(var.sensors), p);
            small_k = 0.8;
            small_c = p.Lx/pi;
            nudg_parameter = small_k;
            rho = 3/4*(nudg_parameter^4*small_c*h_hat.^4).^(1/3);
            
            K = rho + abs(gradient(ref_solution));
        case "Target-Sensors"

            u_x_star = abs(gradient(ref_solution));
            [~, idx] = max(u_x_star);
            
            [r,c] = size(p.var_Ks);
            if p.ti <= c
                big_K = p.var_Ks(:, p.ti);
            else
                big_K = p.var_Ks(:, end);
            end

            C = (4/3)^(3/4)* (var.nudg_parameter^5*var.c/var.my_k)^(-1/4);
            h_hat = abs(real(C*(var.K-u_x_star).^(3/4)));
            
            % rho = 3/4*(var.nudg_parameter^4*var.c*h_hat.^4/var.nu).^(1/3);
            % bracket = 2/var.nu - var.nudg_parameter + u_x_star + rho;   
            
            % Direction: 1 - left, 2 - right
            dir = 2;
            F_temp = griddedInterpolant(p.x, h_hat, 'nearest');
            % F_temp = polyfit(p.x, h_hat, 6);

            % if p.ti == 200
            %     disp("here_")
            % end

            if p.ti == 1 || mod(p.ti, var.targets_frequency) == 0
            % if p.ti == 1 || var.distances(end) < p.dx
                var.target_sensors = p.x(idx);
                if var.target_off_grid
                    var.target_sensors = getTargetSensors(F_temp, dir, var.target_sensors, p.Lx);
                else
                    var.target_sensors = getTargetSensorsNearest(h_hat, dir, idx, p);
                end
                var.number_target_sensors = [var.number_target_sensors, length(var.target_sensors)];
            end
            
            var.old_locations = var.sensors;
            % spatial_sensors = moveSpatialToTargets(var.sensors, var.target_sensors, p, ref_solution);
            if var.target_off_grid
                [spatial_sensors,distanceSum] = moveSpatialToTargetsPeriodically(var.sensors, var.target_sensors, p, ref_solution);
            else
                [spatial_sensors,distanceSum] = moveSpatialToTargetsPeriodically(var.sensors, p.x(var.target_sensors), p, ref_solution);
            end
            
            var.sensors = spatial_sensors;
            var.distances = [var.distances, norm(distanceSum)/length(var.sensors)];
            % if length(var.distances) > 1 && var.distances(end) == var.distances(end-1)
            %     disp("Error");
            % end
            % disp(var.distances(end))
            % var.sensors = p.x(1:3:p.N);  
            if p.ti == p.num_timesteps
                disp("Average number of target sensors:" + mean(var.number_target_sensors))
            end

         case "Unphysical-Target-Sensors"
            
            u_x_star = abs(gradient(ref_solution));
            [~, idx] = max(u_x_star);
            % idx = 1;
            [r,c] = size(p.var_Ks);
            if p.ti <= c
                big_K = p.var_Ks(:, p.ti);
            else
                big_K = p.var_Ks(:, end);
            end

            C = (4/3)^(3/4)* (var.nudg_parameter^5*var.c/var.my_k)^(-1/4);
            h_hat = abs(real(C*(var.K-u_x_star).^(3/4)));
            
            % rho = 3/4*(var.nudg_parameter^4*var.c*h_hat.^4/var.nu).^(1/3);
            % bracket = 2/var.nu - var.nudg_parameter + u_x_star + rho; 
            
            % Direction: 1 - left, 2 - right
            dir = 2;
            F_temp = griddedInterpolant(p.x, h_hat, 'nearest');
            % F_temp = polyfit(p.x, h_hat, 6);
          
            if p.ti == 1 || mod(p.ti, var.targets_frequency) == 0
                var.target_sensors = p.x(idx);
                var.target_sensors = getTargetSensors(F_temp, dir, var.target_sensors, p.Lx);
                % var.target_sensors = getTargetSensorsNearest(h_hat, dir, idx, p);
            end
          
            var.sensors = var.target_sensors;
    
    end
end


function [spatial_sensors] = getTargetSensors(F_temp, dir, spatial_sensors, Lx)
    while true
        % Get location for next sensor h^(i)
       
        % Going in the left direction
        if dir == 1
            % distance_for_next_sensor = polyval(F_temp, spatial_sensors(1));
            distance_for_next_sensor = F_temp(spatial_sensors(1));
            next_pt = spatial_sensors(1) - distance_for_next_sensor;
        % Going in the right direction
        else
            distance_for_next_sensor = F_temp(spatial_sensors(end));
            % distance_for_next_sensor = polyval(F_temp, spatial_sensors(end));
            next_pt = spatial_sensors(end) + distance_for_next_sensor;
        end
    
        % sensors = [sensors, idx];
        % Change direction when reaches end of domain
        if next_pt > Lx
            dir = 1;
            continue;
        elseif next_pt < 0
            break;
        end
        if dir == 1
            spatial_sensors = [next_pt, spatial_sensors];
        else
            spatial_sensors = [spatial_sensors, next_pt];
        end
    end
end

function [spatial_sensors] = getTargetSensorsNearest(h_hat, dir, idx, p)
    spatial_sensors = [];
    start_idx = idx;
    while true
        % Get location for next sensor h^(i) 
        distance_for_next_sensor = h_hat(idx);
        next_pt = p.x(idx) + (-1)^dir * distance_for_next_sensor;
        % Calculate euclidean distance over all grid points
        distances = sqrt(sum((p.x' - next_pt).^2, 2));
        % Find such index on x
        prev_idx = idx;
        [~, idx] = min(distances);
        
        if prev_idx == idx
            idx = idx+(-1)^dir;
        end

        spatial_sensors = [spatial_sensors, idx];
        if idx == p.N
            % break
            idx = start_idx;
            if idx == 1
                break
            end
            dir = 1;
        elseif idx == 1
            break

        end
    end
    spatial_sensors = sort(unique(spatial_sensors));
end

function [h] = sensorsToH(sensors, p)
    h = zeros(size(p.x));
    h(1:length(sensors)-1) = diff(sensors);
end
