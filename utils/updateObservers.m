function [var] = updateObservers(var, p, u_hat, aot_sol)
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
    
            velocityInterp = @(pos) interpolant(pos);
            particleVelocities = velocityInterp(var.sensors);
    
            randomPerturbation = 1.3*var.amplitude * (2 * rand(1, length(var.sensors)) - 1); % Uniform noise in [-strength, +strength]
            
            particlePositions = var.sensors + (particleVelocities + randomPerturbation) * p.dt;
            var.difference = [var.difference, max(abs(var.sensors - particlePositions))];
            particlePositions = mod(particlePositions, p.Lx);
            
            % 
            % for i=1:length(var.sensors)
            %     random_noise = -1 + (2).*rand(1,1);
            %     char_velocity = 1.3;
            %     perturbation = sign(random_noise)*(var.amplitude*char_velocity); 
            %     var.sensors(i) = var.sensors(i) + p.dt*(interpolant(var.sensors(i)) + perturbation);
            %     temp = [temp, abs(perturbation - interpolant(var.sensors(i)))];
            %     var.sensors(i) = mod(var.sensors(i), p.Lx);
            % end
            % var.sensors = sort(unique(var.sensors));tsize(36, "points")
            var.sensors = particlePositions;
            
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
            if p.ti == 1 || mod(p.ti, 250) == 0
                var.sensors = sort(unique(randi([1, p.N], 1,34)));
            end
            % [h_hat] = sensorsToH(p.x(var.sensors), p);
            % small_k = 0.8;
            % small_c = p.Lx/pi;
            % nudg_parameter = small_k;
            % rho = 3/4*(nudg_parameter^4*small_c*h_hat.^4).^(1/3);
            % 
            % K = rho + abs(gradient(ref_solution));
        case "Target-Sensors"
    
                
            aot_physic_sol = ifft(aot_sol, "symmetric");
            u_x_star = abs(gradient(aot_physic_sol));
            [~, idx] = max(u_x_star);
            % idx = 1;
            C = (4/3)^(3/4)* (var.nudg_parameter^5*var.c/var.my_k)^(-1/4);
            h_hat = abs(real(C*(var.K-u_x_star).^(3/4)));
            
            % rho = 3/4*(var.nudg_parameter^4*var.c*h_hat.^4/var.nu).^(1/3);
            % bracket = 2/var.nu - var.nudg_parameter + u_x_star + rho;   
            
            % Direction: 1 - left, 2 - right
            dir = 2;
            F_temp = griddedInterpolant(p.x, h_hat, 'linear');
            tsize = length(var.target_sensors);
            ssize = length(var.sensors);
            if p.ti == 1 || mod(p.ti, var.targets_frequency) == 0
            % if p.ti == 1 || var.change_triggered
                var.change_triggered = false;
            % if p.ti == 1 || var.distances(end) < p.dx
                var.target_sensors = p.x(idx);
                [var.target_sensors, var] = getTargetSensors(F_temp, dir, var, p);
                var.number_target_sensors = [var.number_target_sensors, length(var.target_sensors)];
                remaining_sensors = var.sensors;

                for i=1:length(var.target_sensors)
                    distances = abs(var.target_sensors(i) - remaining_sensors);
        
                    [~, idx] = min(distances);

                    var.mapping(i) = idx;

                    remaining_sensors(idx) = 100*p.Lx;
                end
            end

            var.old_locations = var.sensors;
            [spatial_sensors,~] = moveSpatialToTargetsPeriodically(var, p, ref_solution);
            
            var.sensors = spatial_sensors;
            % var.distances = [var.distances, norm(distanceSum)/length(var.sensors)];
            if p.ti == p.num_timesteps
                disp("Average number of target sensors:" + mean(var.number_target_sensors))
            end

         case "Unphysical-Target-Sensors"
            
            aot_physic_sol = ifft(aot_sol, "symmetric");
            u_x_star = abs(gradient(aot_physic_sol));
            [~, idx] = max(aot_physic_sol);
            % idx = 1;
            % idx = randperm(p.N, 1);

            % [r,c] = size(p.var_Ks);
            % if p.ti <= c
            %     big_K = p.var_Ks(:, p.ti);
            % else
            %     big_K = p.var_Ks(:, end);
            % end

            C = (4/3)^(3/4)* (var.nudg_parameter^5*var.c/var.my_k)^(-1/4);
            h_hat = abs(real(C*(var.K-u_x_star).^(3/4)));
            
            % rho = 3/4*(var.nudg_parameter^4*var.c*h_hat.^4/var.nu).^(1/3);
            % bracket = 2/var.nu - var.nudg_parameter + u_x_star + rho; 
            
            % Direction: 1 - left, 2 - right
            dir = 2;
            F_temp = griddedInterpolant(p.x, h_hat, 'linear');
            % F_temp = polyfit(p.x, h_hat, 6);
          
            if p.ti == 1 || mod(p.ti, var.targets_frequency) == 0
                var.target_sensors = p.x(idx);
                % [var] = getTargetSensors(h_hat, var, p);
                var.target_sensors = getSimpleTargetSensors(F_temp, dir, var, p);
                var.number_target_sensors = [var.number_target_sensors, length(var.target_sensors)];
                % var.target_sensors = getTargetSensorsNearest(h_hat, dir, idx, p);
            end
          
            var.sensors = var.target_sensors;
            if p.ti == p.num_timesteps
                disp("Average number of target sensors:" + mean(var.number_target_sensors))
            end
        case "Unphysical-Target-Sensors1"
            
            aot_physic_sol = ifft(aot_sol, "symmetric");
            u_x_star = abs(gradient(aot_physic_sol));
            % [~, idx] = max(u_x_star);
            idx = 1;
            % idx = randperm(p.N, 1);

            % [r,c] = size(p.var_Ks);
            % if p.ti <= c
            %     big_K = p.var_Ks(:, p.ti);
            % else
            %     big_K = p.var_Ks(:, end);
            % end

            C = (4/3)^(3/4)* (var.nudg_parameter^5*var.c/var.my_k)^(-1/4);
            h_hat = abs(real(C*(var.K-u_x_star).^(3/4)));
            
            % rho = 3/4*(var.nudg_parameter^4*var.c*h_hat.^4/var.nu).^(1/3);
            % bracket = 2/var.nu - var.nudg_parameter + u_x_star + rho; 
            
            % Direction: 1 - left, 2 - right
            dir = 2;
            F_temp = griddedInterpolant(p.x, h_hat, 'linear');
            % F_temp = polyfit(p.x, h_hat, 6);
          
            if p.ti == 1 || mod(p.ti, var.targets_frequency) == 0
                var.target_sensors = p.x(idx);
                var.target_sensors = getSimpleTargetSensors(F_temp, dir, var, p);
                var.number_target_sensors = [var.number_target_sensors, length(var.target_sensors)];
                % var.target_sensors = getTargetSensorsNearest(h_hat, dir, idx, p);
            end
          
            var.sensors = var.target_sensors;
            if p.ti == p.num_timesteps
                disp("Average number of target sensors:" + mean(var.number_target_sensors))
            end

        case "Unphysical-Target-Sensorsr"
            
            aot_physic_sol = ifft(aot_sol, "symmetric");
            u_x_star = abs(gradient(aot_physic_sol));
            % [~, idx] = max(u_x_star);
            % idx = 1;
            idx = randperm(p.N, 1);

            % [r,c] = size(p.var_Ks);
            % if p.ti <= c
            %     big_K = p.var_Ks(:, p.ti);
            % else
            %     big_K = p.var_Ks(:, end);
            % end

            C = (4/3)^(3/4)* (var.nudg_parameter^5*var.c/var.my_k)^(-1/4);
            h_hat = abs(real(C*(var.K-u_x_star).^(3/4)));
            
            % rho = 3/4*(var.nudg_parameter^4*var.c*h_hat.^4/var.nu).^(1/3);
            % bracket = 2/var.nu - var.nudg_parameter + u_x_star + rho; 
            
            % Direction: 1 - left, 2 - right
            dir = 2;
            F_temp = griddedInterpolant(p.x, h_hat, 'linear');
            % F_temp = polyfit(p.x, h_hat, 6);
          
            if p.ti == 1 || mod(p.ti, var.targets_frequency) == 0
                var.target_sensors = p.x(idx);
                var.target_sensors = getSimpleTargetSensors(F_temp, dir, var, p);
                var.number_target_sensors = [var.number_target_sensors, length(var.target_sensors)];
                % var.target_sensors = getTargetSensorsNearest(h_hat, dir, idx, p);
            end
          
            var.sensors = var.target_sensors;
            if p.ti == p.num_timesteps
                disp("Average number of target sensors:" + mean(var.number_target_sensors))
            end

        case "Target-Sensors-Random"

            if p.ti == 1 || mod(p.ti, var.targets_frequency) == 0
                var.target_sensors = p.x(sort(randperm(p.N, 32)));
                var.number_target_sensors = [var.number_target_sensors, length(var.target_sensors)];
            end
            
            [spatial_sensors,~] = moveSpatialToTargetsPeriodically(var.sensors, var.target_sensors, p, ref_solution);
            var.sensors = spatial_sensors;
            % var.distances = [var.distances, norm(distanceSum)/length(var.sensors)];
            
            if p.ti == p.num_timesteps
                disp("Average number of random target sensors:" + mean(var.number_target_sensors))
                % boxplot(var.number_target_sensors)
            end
    
    end
end

function [var] = getTargetSensors(h, var, p)
discrete_integral = p.dx*sum(1./h);
Ntotal = length(var.sensors);
kappa = Ntotal / discrete_integral;
fullGrid = SubDomain(1,p.N, [], Ntotal, discrete_integral, kappa, []);
grid_to_idx = dictionary;
idx_to_subdomain = dictionary;
grid_to_idx(fullGrid) = 1;
idx_to_subdomain(1) = fullGrid;
p.idx_to_grid = idx_to_subdomain;
p.grid_to_idx = grid_to_idx;
subdomains = [fullGrid];
[~, final_subDomains] = placeSensorsInSubDomains(fullGrid, 1./h, var, p, subdomains, []);
[final_subDomains] = placeRemainingSensors(final_subDomains, Ntotal - length(final_subDomains), p); 
var.target_sensors = convertSubgridsToTargetCoordinates(final_subDomains);
% var = plot_subgrids(final_subDomains, p, var);
end


function [domains] = placeRemainingSensors(domains, remaining_sensors, p)

    currIdx = 1;
    while remaining_sensors > 0
        currSubDomain = domains(currIdx);
        [r,~] = size(currSubDomain.sensors);
        domains(currIdx).sensors = placeSensorsUniformly(currSubDomain, r+1, p);
        currIdx = currIdx + 1;
        remaining_sensors = remaining_sensors -1;

    end
end

function [sensors] = placeSensorsUniformly(subDomain, nsensors, p)
    sensors = linspace(p.x(subDomain.xmin), p.x(subDomain.xmax), nsensors+1);
    sensors = sensors(2:end);
end
function [target_coordinates] = convertSubgridsToTargetCoordinates(subgrids)
    
    target_coordinates = [];
    for i=1:length(subgrids)
        target_coordinates = [target_coordinates, subgrids(i).sensors];
    end
end

function [subdomains, finalSubDomains] = placeSensorsInSubDomains(subdomain, h, var, p, subdomains, finalSubDomains)
    temp_list = [];
    n = subdomain.nsensors;
    xmin = subdomain.xmin;
    xmax = floor((subdomain.xmax+subdomain.xmin)/2);
    h_values = h(xmin:xmax);
    curr_integral = p.dx * sum(h_values(:));
    n1 = subdomain.kappa*p.dx * sum(h_values(:));
    
    subDom = SubDomain(xmin, xmax, [], n1, curr_integral, subdomain.kappa, []);
    if n1 >= .5
        subdomains = [subdomains, subDom];
        temp_list = [temp_list, subDom];
        p.idx_to_grid(length(p.idx_to_grid)+1) = subDom;
        p.grid_to_idx(subDom) = length(p.idx_to_grid)+1;
        n = n - 1;
    end

    xmin = floor((subdomain.xmax+subdomain.xmin)/2);
    xmax = subdomain.xmax;
    h_values = h(xmin:xmax);
    curr_integral = p.dx * sum(h_values(:));
    n2 = subdomain.kappa*p.dx * sum(h_values(:));
    
    subDom = SubDomain(xmin, xmax, [], n2, curr_integral, subdomain.kappa, []);
    if n2 >= .5 && n >= 1
        subdomains = [subdomains, subDom];
        temp_list = [temp_list, subDom];
        p.idx_to_grid(length(p.idx_to_grid)+1) = subDom;
        p.grid_to_idx(subDom) = length(p.idx_to_grid)+1;
    end
    
    if isempty(temp_list)
        grid_idx = p.grid_to_idx(subdomain);
        subdomain.final_box= true;
        subdomain.sensors =  (p.x(subdomain.xmin)+p.x(subdomain.xmax))/2;
        % subdomain.sensors =  p.x(subdomain.xmax);
        % subdomain.sensors =  p.x(subdomain.xmin);
        subdomains(grid_idx) = subdomain;
        finalSubDomains = [finalSubDomains, subdomain];
    end

    for i=1:length(temp_list)
        subdomain_i = temp_list(i);
        [subdomains, finalSubDomains] = placeSensorsInSubDomains(subdomain_i, h, var, p, subdomains,finalSubDomains); 
    end

end

function [spatial_sensors] = getSimpleTargetSensors(F_temp, dir, var, p)
    spatial_sensors = var.target_sensors;
    while true
        % if length(spatial_sensors) == 103
        %     break;
        % end
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
        if next_pt > p.x(end)
            dir = 1;
            continue;
            % next_pt = next_pt - Lx;
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
function [h] = sensorsToH(sensors, p)
    h = zeros(size(p.x));
    h(1:length(sensors)-1) = diff(sensors);
end

function [var] = plot_subgrids(subgrids, p, var)

    fig = figure(10);
    
    colors = jet(length(subgrids));
    
    
    % plot(X, Y, 'k.', 'MarkerSize', 1);
    hold on

    for i=1:length(subgrids)
    
        xmin = subgrids(i).xmin;
        xmax = subgrids(i).xmax;
        plotted_region = p.x(xmin:xmax);
        y = linspace(0, 1, 100);
        [X, Y] = meshgrid(plotted_region, y);
        plot(X,Y , '.', 'Color', colors(i, :), 'MarkerSize', 10);
        title(sprintf('Reference solution at t = %1.2f',p.t(p.ti)));
        xlabel("X")
        ylabel("Y")
        % xx = [plotted_region(1), plotted_region(1), plotted_region(end), plotted_region(end)];
        % yy = [0, 1, 0, 1];
        % line(xx, yy, "LineWidth", 3);
    end
    hold off
    % frame = getframe(fig);
    % var.im{p.ti} = frame2im(frame);

end