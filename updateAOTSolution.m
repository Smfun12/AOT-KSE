function [var] = updateAOTSolution(var, p, u_hat, u_hat_old)
    ref_solution = ifft(u_hat_old,'symmetric');
    aot_sol = ifft(var.aot_hat, 'symmetric');

    if var.off_grid
        spatial_sensors = var.sensors;
    else
        spatial_sensors = p.x(var.sensors);
    end
    
    [aot_obs, var] = interpolate_observations(p, ref_solution, spatial_sensors, var);
    [aot_hat] = interpolate_v(p, aot_sol, spatial_sensors);

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


function [vq1, var] = interpolate_observations(p, ref_solution, spatial_sensors, var)
    F_temp = griddedInterpolant(p.x, ref_solution, var.interpolation_type);
    bsv_data = F_temp(spatial_sensors);
    var.interpolation_error = [var.interpolation_error, norm(bsv_data - ref_solution(1:20:p.N))];
    x_pts = spatial_sensors';
    
    %Copy data at rightmost sensor and leftmost sensor to extend periodically
    u_data1 = [bsv_data(end),bsv_data, bsv_data(1) ];

    x_pts_per = x_pts;
    %Add sensors closest to end of domain periodically
    x_pts_per = [x_pts_per(end) - p.Lx; x_pts_per; x_pts_per(1) + p.Lx];

    % Note that x_pts has been sorted, so x_pts(1) is the left most sensor,
    % and x_pts(end) is the right most sensor.
    F1 = griddedInterpolant(x_pts_per, u_data1.');
    vq1 = F1(p.x);
end

function [vq2] = interpolate_v(p, aot_sol, spatial_sensors)

    F2 = griddedInterpolant(p.x, aot_sol);
    aot_sensors = F2(spatial_sensors);
    x_pts = spatial_sensors';
    u_data2 = [aot_sensors(end), aot_sensors, aot_sensors(1)];
    x_pts_per = [x_pts(end) - p.Lx; x_pts; x_pts(1) + p.Lx];

    F1 = griddedInterpolant(x_pts_per, u_data2.');
    vq2 = F1(p.x);
end