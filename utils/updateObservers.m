    function [var] = updateObservers(var, p, u_hat, aot_sol)
    ref_solution = ifft(u_hat, 'symmetric');
    interpolant = griddedInterpolant(p.x, ref_solution, 'linear');
    u0 = 1.3;
    switch var.observer_type
        case "Uniform"
            var.sensors = var.sensors;

        case "Lagrangian"
    
            velocityInterp = @(pos) interpolant(pos);
            particleVelocities = velocityInterp(var.sensors);
            
            randomPerturbation = var.amplitude * 1.3 * (2 * rand(1, length(var.sensors)) - 1); % Uniform noise in [-strength, +strength]
            
            particlePositions = var.sensors + (particleVelocities + randomPerturbation) * p.dt;
            var.difference = [var.difference, max(abs(var.sensors - particlePositions))];
            particlePositions = mod(particlePositions, p.Lx);
            var.sensors = particlePositions;
        case "Inertia"
            
            velocityInterp = @(pos) interpolant(pos);
            particleVelocities = velocityInterp(var.sensors);
            t0 = var.rho*var.diameter^2 / (18*p.lambda);
            if ~isfield(var, "amplitude") || isempty(var.amplitude)
                var.amplitude = 0;
            end
            randomPerturbation = var.amplitude * u0* (2 * rand(1, length(var.sensors)) - 1);

            u_new = var.vel+p.dt*1/t0*(particleVelocities-var.vel);
            var.vel = u_new;
            particle_coord_x = p.dt*(u_new + randomPerturbation);
           
            l0 = p.Lx;
            var.stokes_number = t0*u0/l0;
            
            var.sensors = var.sensors + particle_coord_x;
            var.sensors = mod(var.sensors, p.Lx);

        case "Target Sensors"

            aot_physic_sol = ifft(aot_sol, "symmetric");
            u_x_star = abs(gradient(aot_physic_sol));

            p.ref_solution = aot_physic_sol;
            [var.K, h_hat] = determineH(p.mu, length(var.sensors), p, var.K);

            rho = 3/4*(var.nudg_parameter^4*var.c*h_hat.^4/var.nu).^(1/3);
            
            nsensors = sum(1./h_hat)*p.dx;
            recent_errors = var.error_aot(max(1,p.ti-100):(p.ti-1));
            std_recent = std(recent_errors);
            mean_recent = mean(abs(recent_errors));
            
            if p.ti == 1 || (norm(var.target_sensors - var.sensors) < 1e-6)
            % if p.ti == 1 || mod(p.ti, var.target_frequency) == 0
            % if p.ti <= 2 || (var.error_aot(p.ti-1) >= var.error_aot(p.ti-2)
            
                if var.alg == 1
                    var.target_sensors = mesh_refine_greedy(h_hat, p.x(1), p.x(end), length(var.sensors), p.x, p.dx);
                elseif var.alg == 2
                    var.target_sensors = getTargetSensors(var, h_hat, p);
                else
                    var.target_sensors = priority_adaptive_refinement(h_hat, p, var);
                end
            end

            var.old_locations = var.sensors;
            % var = calculateMappingBetweenPhysicalAndTargetSensors(var, p);
            % var = greedy_unique_periodic_match(var, p);
            [spatial_sensors] = moveSpatialToTargetsPeriodically(var, p);
            var.sensors = spatial_sensors;
        case "Forward Sensors"
            var.sensors = var.sensors + p.dt*u0*var.sensor_speed;
            var.sensors = sort(mod(var.sensors, p.Lx));
    end
end

function [var] = calculateMappingBetweenPhysicalAndTargetSensors(var, p)
    mapping = zeros(size(var.target_sensors));
    remainingPoints = var.sensors;
    assigned = false(1, length(var.target_sensors));
    for i = 1:length(var.target_sensors)
        % Compute distances from array1(i, :) to all remaining points in array2
        distances = abs(var.sensors - var.target_sensors(i));
        distances = min(distances, p.Lx - distances);
        
        distances(assigned) = Inf;
        % Find the closest point
        [~, idx] = min(distances);

        % Store the mapping
        mapping(i) = idx;

        % Remove the matched point from remainingPoints
        % remainingPoints(idx) = [1e3];
        assigned(idx) = true;
    end
    var.mapping = mapping;
end

function var = greedy_unique_periodic_match(var, p)
    % A, B: 1D arrays of points in [0, L)
    % L: length of periodic domain
    % Output: indicesB(i) is index in B matched to A(i), uniquely
    A = var.target_sensors;
    B = var.sensors;
    L = p.Lx;
    nA = length(A);
    nB = length(B);
    assert(nA <= nB, 'Set B must have at least as many points as A.');

    indicesB = zeros(size(A));       % Final output
    assigned = false(1, nB);         % Keep track of assigned B points

    for i = 1:nA
        % Compute periodic distances from A(i) to all B
        dists = abs(A(i) - B);
        dists = min(dists, L - dists);

        % Invalidate distances for already assigned points
        dists(assigned) = Inf;

        % Assign to closest unassigned point
        [~, idx] = min(dists);
        indicesB(i) = idx;
        assigned(idx) = true;
    end
    var.mapping = indicesB;
end


function [sensor_positions] = priority_adaptive_refinement(h_func, p, var)
% PRIORITY_ADAPTIVE_REFINEMENT: Adaptive splitting by sensor need
% Inputs:
%   h_func - density function
%   a, b   - domain bounds
%   N      - total number of sensors
%   M      - resolution for numerical integration
% Outputs:
%   subdomains - final subdomain list
%   sensor_positions - centers of final subdomains

    % Initial domain
    a = p.x(1);
    b = p.x(end);
    subdomains = [a, b];
    N = var.num_sensors;
    
    h_total = trapz(p.x, h_func);
    % Loop until all subdomains require ≤ 1 sensor
    while length(subdomains) < N
        needs_split = false;
        new_subdomains = [];

        % Compute sensor needs per subdomain
        sensor_needs = zeros(size(subdomains,1),1);
        for i = 1:size(subdomains,1)
            x1 = subdomains(i,1);
            x2 = subdomains(i,2);
            % x_local = linspace(x1, x2, p.N);
            % h_local = h_func(x_local);
            % h_local = compute_weight(h, x1, x2, p.x);
            integral_local = compute_weight(h_func, x1, x2, p.x);
            sensor_needs(i) = N * integral_local / h_total;
        end

        % Find subdomain with max sensor need > 1
        [max_need, idx_max] = max(sensor_needs);

        if max_need <= 0.5
            break;  % All subdomains done
        else
            needs_split = true;
            % Split the max-need subdomain
            x1 = subdomains(idx_max,1);
            x2 = subdomains(idx_max,2);
            xm = (x1 + x2)/2;

            % Replace with two halves
            new_subdomains = [subdomains(1:idx_max-1, :);
                              x1, xm;
                              xm, x2;
                              subdomains(idx_max+1:end, :)];
            subdomains = new_subdomains;
        end
    end

    % Place sensors at subdomain centers
    sensor_positions = mean(subdomains, 2);
end



function [mesh,segments]= mesh_refine_greedy(h_func, a, b, N, x, dx)
    % Start with one segment
    segments = struct('a', a, 'b', b, 'weight', compute_weight(h_func, a, b, x, dx));
    
    % Keep splitting until we have N segments
    while length(segments) < N
        % Find the segment with the highest weight
        [~, idx] = max([segments.weight]);
        seg = segments(idx);
        
        % Split it in half
        mid = (seg.a + seg.b) / 2;
        
        left.weight = compute_weight(h_func, seg.a, mid, x, dx);
        left.a = seg.a;
        left.b = mid;
        
        right.weight = compute_weight(h_func, mid, seg.b, x, dx);
        right.a = mid;
        right.b = seg.b;
        
        % Replace the selected segment with its two children
        segments(idx) = [];  % remove the old one
        segments(end+1) = left;
        segments(end+1) = right;
    end
    
    % Extract mesh points
    % mesh = sort(unique([segments.a, segments.b]));
    mesh = sort(unique(([segments.a] + [segments.b]) / 2));
end

function w = compute_weight(h_func, a, b, x, dx)
    % Weight is the integral of 1/h(x) over [a, b]
    F = griddedInterpolant(x, h_func);
    h = @(x) F(x);
    w = integral(@(x) 1 ./ h(x), a, b);
    % w = sum(1./h_func)*dx;
end

function [K, h] = determineH(mu, N, p, initialK)

    number_of_generated_sensors = p.N+1;
    Kk = [];
    K = initialK;
    c = 1/sqrt(12);
    u_x_star = abs(gradient(p.ref_solution));
    precision = 1000;
    while abs(number_of_generated_sensors - N) > 1e-7
        
        old_K = K;
        if number_of_generated_sensors > N
        
            K = K -  precision;
        else
            K = K + precision;
        
        end
        Kk = [Kk, K];
        if length(Kk) > 2 && K == Kk(end-2)
            precision = precision / 10;
        end
        
        bracket = (-4/3 * (2/p.lambda - mu + u_x_star+K)).^(3/4);
        if ~isreal(bracket)
            K = old_K;
            precision = precision / 10;
            continue
        end
        constants = p.lambda^(1/4) / (mu*c^(1/4));

        h = bracket * constants;
        
        number_of_generated_sensors = (sum(1./h)*p.dx);
        
    end
end

function [sensors] = getTargetSensors(var, h, p)
discrete_integral = p.dx*sum(1./h);
Ntotal = length(var.sensors);
p.num_sensors = Ntotal;
kappa = Ntotal / discrete_integral;
fullGrid = SubDomain(1,p.N, [], Ntotal, discrete_integral, kappa, []);
subdomains = fullGrid;
[~, final_subDomains] = placeSensorsInPrioritySubDomainsLoop(fullGrid, 1./h, p, subdomains, []);
% [~, final_subDomains] = placeSensorsInPrioritySubDomains(fullGrid, 1./h, p, subdomains, []);

p.h = 1./h;
[final_subDomains] = splitFurtherIfRemainingSensors(final_subDomains, Ntotal - length(final_subDomains), p); 
sensors = sort(unique(convertSubgridsToTargetCoordinates(final_subDomains)));
end

function [target_coordinates] = convertSubgridsToTargetCoordinates(subgrids)
    
    target_coordinates = [];
    for i=1:length(subgrids)
        target_coordinates = [target_coordinates, subgrids(i).sensors];
    end
end
function [domains] = splitFurtherIfRemainingSensors(domains, remaining_sensors, p)
    [~, idx] = sort([domains.nsensors], 'descend');
    domains = domains(idx);
    while remaining_sensors > 0
        currSubDomain = domains(1);
        
        [domain1, domain2] = splitDomain(currSubDomain, p);
        domains(1) = [];
        domains = [domains, [domain1, domain2]];
        remaining_sensors = remaining_sensors -1;
    end
end

function [domain1, domain2] = splitDomain(subdomain, p)
        h = p.h;
        xmin = subdomain.xmin;
        xmax = floor((subdomain.xmax + subdomain.xmin) / 2);

        h_values = h(xmin:xmax);
        curr_integral = p.dx * sum(h_values(:));
        n1 = 1 * curr_integral;
        domain1 = SubDomain(xmin, xmax, [], n1, curr_integral, subdomain.kappa, []);
        domain1.sensors = (p.x(xmin) + p.x(xmax)) / 2;

        xmin_2 = ceil((subdomain.xmax + subdomain.xmin) / 2);
        xmax_2 = subdomain.xmax;
        h_values_2 = h(xmin_2:xmax_2);
        curr_integral_2 = p.dx * sum(h_values_2(:));
        n2 = 1 * curr_integral_2;
        domain2 = SubDomain(xmin_2, xmax_2, [], n2, curr_integral_2, subdomain.kappa, []);
        domain2.sensors = (p.x(xmin_2) + p.x(xmax_2)) / 2;

end

function [subdomains, finalSubDomains] = placeSensorsInPrioritySubDomainsLoop(subdomain, h, p, subdomains, finalSubDomains)

    % Initialize a stack with the initial subdomain
    stack = [subdomain];
    NTotal = p.num_sensors;
    % Loop while there are subdomains to process
    while ~isempty(stack)
        % Pop the last subdomain from the stack
        [~, idx] = max([stack.nsensors]);
        % seg = segments(idx);
        
        subdomain = stack(idx);
        stack(idx) = [];

        temp_list = [];
        n = subdomain.nsensors;
        xmin = subdomain.xmin;
        xmax = floor((subdomain.xmax + subdomain.xmin) / 2);

        h_values = h(xmin:xmax);
        curr_integral = p.dx * sum(h_values(:));
        n1 = 1 * curr_integral;
        subDom = SubDomain(xmin, xmax, [], n1, curr_integral, subdomain.kappa, []);

        xmin_2 = ceil((subdomain.xmax + subdomain.xmin) / 2);
        xmax_2 = subdomain.xmax;
        h_values_2 = h(xmin_2:xmax_2);
        curr_integral_2 = p.dx * sum(h_values_2(:));
        n2 = 1 * curr_integral_2;
        subDom_2 = SubDomain(xmin_2, xmax_2, [], n2, curr_integral_2, subdomain.kappa, []);

        precision = .5;

        if (n1 >= precision || n2 >= precision)
            if n1 > n2 && xmin ~= xmax
                temp_list = [temp_list, subDom];
                % subdomains = [subdomains, subDom];
                n = n - 1;
                if n >= 1
                    temp_list = [temp_list, subDom_2];
                    % subdomains = [subDom_2, subdomains];
                end
            elseif xmin_2 ~= xmax_2
                temp_list = [temp_list, subDom_2];
                % subdomains = [subdomains, subDom_2];
                n = n - 1;
                if n >= 1
                    temp_list = [temp_list, subDom];
                    % subdomains = [subDom, subdomains];
                end
            end
        end

        % If no further splitting, mark this as final and assign a sensor
        if isempty(temp_list)
            % grid_idx = p.grid_to_idx(subdomain);
            % subdomain.final_box = true;
            subdomain.sensors = (p.x(subdomain.xmin) + p.x(subdomain.xmax)) / 2;
            % subdomains(grid_idx) = subdomain;
            finalSubDomains = [finalSubDomains, subdomain];
            NTotal = NTotal - 1;
            if NTotal == 0
                break;
            end
        else
            % Push new subdomains to the stack
            stack = [stack, temp_list];
        end
    end
end


function [subdomains, finalSubDomains] = placeSensorsInPrioritySubDomains(subdomain, h, p, subdomains, finalSubDomains)
    temp_list = [];
    n = subdomain.nsensors;
    xmin = subdomain.xmin;
    xmax = floor((subdomain.xmax+subdomain.xmin)/2);
    h_values = h(xmin:xmax);
    curr_integral = p.dx * sum(h_values(:));
    n1 = 1*curr_integral;
    subDom = SubDomain(xmin, xmax, [], n1, curr_integral, subdomain.kappa, []);

    xmin_2 = ceil((subdomain.xmax+subdomain.xmin)/2);
    xmax_2 = subdomain.xmax;
    h_values_2 = h(xmin_2:xmax_2);
    curr_integral_2 = p.dx * sum(h_values_2(:));
    n2 = 1*curr_integral_2;
    subDom_2 = SubDomain(xmin_2, xmax_2, [], n2, curr_integral_2, subdomain.kappa, []);
    precision = .5;
    if (xmin ~= xmax && xmin_2 ~= xmax_2) % To handle out-of-mesh case
        if (n1 >= precision && n2>= precision ) % Both subdomains must satisfy the threshold, otherwise we stop splitting
            if n1 > n2 % Select subdomain that requires more sensors
                temp_list = [temp_list, subDom];
                subdomains = [subdomains, subDom];
                p.idx_to_grid(length(p.idx_to_grid)+1) = subDom;
                p.grid_to_idx(subDom) = length(p.idx_to_grid)+1;
                n = n - 1;
                if n > 1 % If any sensors left, place it in other subdomain
                    temp_list = [temp_list, subDom_2];
                    subdomains = [subdomains, subDom_2];
                    p.idx_to_grid(length(p.idx_to_grid)+1) = subDom_2;
                    p.grid_to_idx(subDom_2) = length(p.idx_to_grid)+1;
                end
            else
                temp_list = [temp_list, subDom_2];
                subdomains = [subdomains, subDom_2];
                p.idx_to_grid(length(p.idx_to_grid)+1) = subDom_2;
                p.grid_to_idx(subDom_2) = length(p.idx_to_grid)+1;
                n = n - 1;
                if n > 1
                    temp_list = [temp_list, subDom];
                    subdomains = [subdomains, subDom];
                    p.idx_to_grid(length(p.idx_to_grid)+1) = subDom;
                    p.grid_to_idx(subDom) = length(p.idx_to_grid)+1;
                end
            end
        end
    else
        disp("out of mesh")
    end
    % Empty temp list means we haven't include any new subdomains for
    % mesh-refinement, so we mark the current subdomain as final.
    if isempty(temp_list)
        grid_idx = p.grid_to_idx(subdomain);
        subdomain.final_box= true;
        subdomain.sensors =  (p.x(subdomain.xmin)+p.x(subdomain.xmax))/2;
        subdomains(grid_idx) = subdomain;
        finalSubDomains = [finalSubDomains, subdomain];
    end
    
    % Recursive call
    for i=1:length(temp_list)
        subdomain_i = temp_list(i);
        [subdomains, finalSubDomains] = placeSensorsInPrioritySubDomains(subdomain_i, h, p, subdomains,finalSubDomains); 
    end

end

function plot_subgrids(subgrids, p)

    figure(10);
    
    colors = jet(length(subgrids));
    
    hold on

    for i=1:length(subgrids)
    
        xmin = subgrids(i).xmin;
        xmax = subgrids(i).xmax;
        plotted_region = p.x(xmin:xmax);
        y = linspace(0, 1, 100);
        [X, Y] = meshgrid(plotted_region, y);
        plot(X,Y , '.', 'Color', colors(i, :), 'MarkerSize', 10);
        xlabel("X")
        ylabel("Y")
    end
    hold off;

end

% function [spatial_sensors] = getSimpleTargetSensors(F_temp, dir, var, p)
%     spatial_sensors = var.target_sensors;
%     while true
%         % if length(spatial_sensors) == 53
%         %     break;
%         % end
%         % Get location for next sensor h^(i)
% 
%         % Going in the left direction
%         if dir == 1
%             % distance_for_next_sensor = polyval(F_temp, spatial_sensors(1));
%             distance_for_next_sensor = F_temp(spatial_sensors(1));
%             next_pt = spatial_sensors(1) - distance_for_next_sensor;
%         % Going in the right direction
%         else
%             distance_for_next_sensor = F_temp(spatial_sensors(end));
%             % distance_for_next_sensor = polyval(F_temp, spatial_sensors(end));
%             next_pt = spatial_sensors(end) + distance_for_next_sensor;
%         end
% 
%         % sensors = [sensors, idx];
%         % Change direction when reaches end of domain
%         if next_pt > p.x(end)
%             dir = 1;
%             continue;
%             % next_pt = next_pt - Lx;
%         elseif next_pt < 0
%             break;
%         end
%         if dir == 1
%             spatial_sensors = [next_pt, spatial_sensors];
%         else
%             spatial_sensors = [spatial_sensors, next_pt];
%         end
%     end
% end
% function [h] = sensorsToH(sensors, p)
%     h = zeros(size(p.x));
%     h(1:length(sensors)-1) = diff(sensors);
% end
