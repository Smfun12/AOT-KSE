function [var] = updateInertiaSensors(var, interpolant, p)

    velocityInterp = @(pos) interpolant(pos);
    fluidVelocity = velocityInterp(var.sensors);
    t0 = var.rho*var.diameter^2 / (18*p.lambda);
    u0 = 1.3;
    randomPerturbation = var.amplitude * u0 * (2 * rand(1, length(var.sensors)) - 1);

    if t0 == 0
        u_new = fluidVelocity;
    else
        u_new = var.vel+p.dt*1/t0*(fluidVelocity-var.vel);
        var.vel = u_new;
    end
    particle_coord_x = p.dt*(u_new + randomPerturbation);
    
    var.stokes_number = t0*u0/p.Lx; 
    var.sensors = (mod(var.sensors + particle_coord_x, p.Lx));
end