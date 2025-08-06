function [var] = updateInertiaSensors(var, interpolant, p)

    velocityInterp = @(pos) interpolant(pos);
    fluidVelocity = velocityInterp(var.sensors);
    t0 = var.rho*var.diameter^2 / (18*p.lambda);
    u0 = 1.3;
    if ~isfield(var, "amplitude") || isempty(var.amplitude)
        var.amplitude = 0;
    end
    randomPerturbation = var.amplitude * u0 * (2 * rand(1, length(var.sensors)) - 1);

    if t0 == 0
        u_new = fluidVelocity;
    else
        u_new = var.vel+p.dt*1/t0*(fluidVelocity-var.vel);
        var.vel = u_new;
    end
    particle_coord_x = p.dt*(u_new + randomPerturbation);
    
    l0 = p.Lx;
    var.stokes_number = t0*u0/l0;
    
    var.sensors = var.sensors + particle_coord_x;
    
    spatial_sensors = mod(var.sensors, p.Lx);
    if any(isnan(spatial_sensors))
        disp("")
    end
    var.sensors = spatial_sensors;
end