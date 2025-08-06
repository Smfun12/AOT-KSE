function [var] = updateAOTSolution(var, p, u_hat, u_hat_old)
    ref_solution = ifft(u_hat_old, 'symmetric');
    aot_sol = ifft(var.aot_hat, 'symmetric');
    
    if var.off_grid
        spatial_sensors = var.sensors;
    else
        spatial_sensors = p.x(var.sensors);
    end
    
    [aot_obs] = interpolateOntoobservationalGridAndBack(p, ref_solution, sort(unique(spatial_sensors)), var);
    [aot_hat] = interpolateOntoobservationalGridAndBack(p, aot_sol, sort(unique(spatial_sensors)), var);
    aot_obs = fft(aot_obs);
    aot_obs(p.trunc_index_comp) = 0;

    Ihumv = aot_obs - fft(aot_hat);
    Ihumv(p.trunc_index_comp) = 0;
    Ihumv(1) = 0;
    Ihumv = Ihumv.*p.dealias_mask;

    nonlin_aot = (1i*p.k/2).*fft(real(ifft(var.aot_hat.*p.dealias_mask)).^2);

    var.aot_hat = p.E.*(var.aot_hat - p.dt*nonlin_aot + p.dt*p.mu*(Ihumv));
    
    var.error_aot(p.ti) = norm(abs(u_hat - var.aot_hat),'fro')/p.N;
    var.error = var.error_aot(p.ti);
end


function [vq1] = interpolateOntoobservationalGridAndBack(p, ref_solution, spatial_sensors, var)
    F_temp = griddedInterpolant(p.x, ref_solution, var.interpolation_type);
    bsv_data = F_temp(spatial_sensors);
    x_pts = spatial_sensors';
    
    u_data1 = [bsv_data(end), bsv_data, bsv_data(1)];
    x_pts_per = [x_pts(end) - p.Lx; x_pts; x_pts(1) + p.Lx];

    F1 = griddedInterpolant(x_pts_per, u_data1.', "linear");
    vq1 = F1(p.x);
end