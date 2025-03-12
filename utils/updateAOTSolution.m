function [var] = updateAOTSolution(var, p, u_hat, u_hat_old)
    ref_solution = ifft(u_hat_old,'symmetric');
    aot_sol = ifft(var.aot_hat, 'symmetric');

    if var.off_grid
        spatial_sensors = var.sensors;
    else
        spatial_sensors = p.x(var.sensors);
    end
    
    [aot_obs, ~] = interpolate_observations(p, ref_solution, sort(unique(spatial_sensors)), var);
    [aot_hat, ~] = interpolate_v(p, aot_sol, sort(unique(spatial_sensors)), var);
    

    var.interpolation_error = [var.interpolation_error, norm(ref_solution - aot_obs)];

    if isfield(var, "basis_counter")
        if mod(var.basis_counter,var.temp_basis_size) ~= 0
            var.temp_basis = [var.temp_basis, vq1'];
        end
        var.basis_counter = var.basis_counter + 1;
    end
    
    Ihumv = fft(aot_obs) - fft(aot_hat);
    Ihumv(1) = 0;
    Ihumv = Ihumv.*p.dealias_mask;
    nonlin_aot = (1i*p.k/2).*fft(real(ifft(var.aot_hat.*p.dealias_mask)).^2);

    var.aot_hat = p.E.*(var.aot_hat - p.dt*nonlin_aot + p.dt*p.mu*(Ihumv));
    
    var.error_aot(p.ti) = norm(abs(u_hat - var.aot_hat),'fro')/p.N;
    var.error = var.error_aot(p.ti);
end


function [vq1, bsv_data] = interpolate_observations(p, ref_solution, spatial_sensors, var)
    F_temp = griddedInterpolant(p.x, ref_solution, var.interpolation_type);
    bsv_data = F_temp(spatial_sensors);
    
    % closest_points = zeros(size(spatial_sensors));
    % % Loop through each point
    % for i = 1:length(spatial_sensors)
    %     % Compute the absolute distance to all grid points
    %     [~, idx] = min(abs(p.x - spatial_sensors(i)));
    %     % Find the closest grid point
    %     closest_points(i) = ref_solution(idx);
    % end

    x_pts = spatial_sensors';
    
    %Copy data at rightmost sensor and leftmost sensor to extend periodically
    % u_data1 = [bsv_data(end-2), bsv_data(end-1), bsv_data(end),bsv_data, bsv_data(1), bsv_data(2), bsv_data(3) ];
    u_data1 = [bsv_data(end), bsv_data, bsv_data(1)];

    x_pts_per = x_pts;
    %Add sensors closest to end of domain periodically
    % x_pts_per = [x_pts_per(end-2) - p.Lx;x_pts_per(end-1) - p.Lx; x_pts_per(end) - p.Lx; x_pts_per; x_pts_per(1) + p.Lx; x_pts_per(2) + p.Lx;x_pts_per(3) + p.Lx];
    x_pts_per = [x_pts_per(end) - p.Lx; x_pts_per; x_pts_per(1) + p.Lx];

    % Note that x_pts has been sorted, so x_pts(1) is the left most sensor,
    % and x_pts(end) is the right most sensor.
    F1 = griddedInterpolant(x_pts_per, u_data1.', "linear");
    vq1 = F1(p.x);
end

function [vq2, aot_sensors] = interpolate_v(p, aot_sol, spatial_sensors, var)

    F2 = griddedInterpolant(p.x, aot_sol, var.interpolation_type);
    aot_sensors = F2(spatial_sensors);
    x_pts = spatial_sensors';
    % u_data2 = [aot_sensors(end-2), aot_sensors(end-1), aot_sensors(end),aot_sensors, aot_sensors(1), aot_sensors(2), aot_sensors(3)];
    u_data2 = [aot_sensors(end),aot_sensors, aot_sensors(1)];
    % x_pts_per = [x_pts(end-2) - p.Lx;x_pts(end-1) - p.Lx; x_pts(end) - p.Lx; x_pts; x_pts(1) + p.Lx; x_pts(2) + p.Lx;x_pts(3) + p.Lx];
    x_pts_per = [x_pts(end) - p.Lx; x_pts; x_pts(1) + p.Lx];

    F1 = griddedInterpolant(x_pts_per, u_data2.', "linear");
    vq2 = F1(p.x);
end