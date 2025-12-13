function [var] = updateObserversLocations(var, p, u_hat_old, aot_sol)
    ref_solution = ifft(u_hat_old, 'symmetric');
    switch var.observer_type
        case {"Lagrangian", "Inertia"}
            var = updateInertiaSensorsLocations(var, ref_solution, p);
        case "Directed"
            if p.ti == 1 || (norm(var.target_sensors - var.sensors) < 1e-6 && var.error > 1e-13)
                var.target_sensors = intervalBasedTargetLocations(p, var, ref_solution);
            end
            var = moveDirectedSensorsToTargetLocations(var, p);
        case "Forward Sensors"
            var.sensors = var.sensors + p.dt*p.characteristic_velocity*var.sensor_speed;
            var.sensors = sort(mod(var.sensors, p.Lx));
    end
end