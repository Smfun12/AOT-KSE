function [var] = updateObservers(var, p, u_hat_old, aot_sol)
    ref_solution = ifft(u_hat_old, 'symmetric');
    interpolant = griddedInterpolant(p.x, ref_solution, 'linear');
    switch var.observer_type
        case {"Lagrangian", "Inertia"}
            var = updateInertiaSensors(var, interpolant, p);
        case "Target Sensors"
            if p.ti == 1 || (norm(var.target_sensors - var.sensors) < 1e-6 && var.error > 1e-13)
                p.num_sensors = length(var.sensors);
                if var.alg == 1
                    var.target_sensors = intervalBasedTargetLocations(p, var, ref_solution);
                elseif var.alg == 2
                    var.target_sensors = thresholdBasedTargetLocations(p, var, ref_solution);
                end
            end
            var = moveDirectedSensorsToTargetLocations(var, p);
            
        case "Forward Sensors"
            u0 = 1.3;
            var.sensors = var.sensors + p.dt*u0*var.sensor_speed;
            var.sensors = sort(mod(var.sensors, p.Lx));
    end
end