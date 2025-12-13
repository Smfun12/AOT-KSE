function [var] = moveDirectedSensorsToTargetLocations(var, p)
    
    L = p.Lx;
    x_target = var.target_sensors;
    x_sensors = var.sensors;

    speeds = var.sensor_speed*1.3 + zeros(1, length(x_sensors));
    direction = mod(x_target - x_sensors + L/2, L) - L/2;
    distance = abs(direction);
    movement = p.dt * speeds;

    overshoot = movement >= distance;
    x_sensors(overshoot) = x_target(overshoot);    
    move = ~overshoot;
    x_sensors(move) = x_sensors(move) + movement(move) .* sign(direction(move));

    x_sensors = mod(x_sensors, L);

    new_distance = abs(mod(x_sensors - var.sensors + L/2, L) - L/2);
    var.average_speed(:, p.ti) = new_distance/p.dt;
    var.sensors = x_sensors;
end