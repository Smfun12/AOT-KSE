function [var] = updateAOTSolution(var, p, u_hat, u_hat_old)
    ref_solution = ifft(u_hat_old,'symmetric');
    aot_sol = ifft(var.aot_hat, 'symmetric');
    
    
    if var.grid_sensors
        spatial_sensors = var.sensors;
        F_temp = griddedInterpolant(p.x, aot_sol, "linear");
        aot_sol = F_temp(var.sensors);
    else
        spatial_sensors = p.x(var.sensors);
        aot_sol = aot_sol(var.sensors);
    end

    F_temp = griddedInterpolant(p.x, ref_solution, 'linear');
    bsv_data = F_temp(spatial_sensors);
    x_pts = spatial_sensors';
    
    %Copy data at rightmost sensor and leftmost sensor to extend periodically
    u_data1 = [bsv_data(end),bsv_data, bsv_data(1) ];

   
    %Copy data at rightmost sensor and leftmost sensor to extend periodically
    u_data2 = [aot_sol(end), aot_sol, aot_sol(1)];
    

    x_pts_per = x_pts;
    %Add sensors closest to end of domain periodically
    x_pts_per = [x_pts_per(end) - p.Lx; x_pts_per; x_pts_per(1) + p.Lx];

    % Note that x_pts has been sorted, so x_pts(1) is the left most sensor,
    % and x_pts(end) is the right most sensor.
    F1 = griddedInterpolant(x_pts_per, u_data1.');
    F2 = griddedInterpolant(x_pts_per, u_data2.');
    
    vq1 = F1(p.x);
    if isfield(var, "basis_counter")
        if mod(var.basis_counter,var.temp_basis_size) ~= 0
            var.temp_basis = [var.temp_basis, vq1'];
        end
        var.basis_counter = var.basis_counter + 1;
    end
    aot_obs = fft(vq1);

    Ihumv = aot_obs - fft(F2(p.x));
    Ihumv(1) = 0;
    Ihumv = Ihumv.*p.dealias_mask;
    nonlin_aot = (1i*p.k/2).*fft(real(ifft(var.aot_hat.*p.dealias_mask)).^2);

    var.aot_hat = p.E.*(var.aot_hat - p.dt*nonlin_aot + p.dt*p.mu*(Ihumv));
    var.error_aot(p.ti) = norm(abs(u_hat - var.aot_hat),'fro')/p.N;
    var.error = var.error_aot(p.ti);
end