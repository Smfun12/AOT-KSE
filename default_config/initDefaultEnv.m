function [p] = initDefaultEnv()
    p.N = 2^10;
    p.Lx = 32*pi;
    p.dx = p.Lx/p.N;
    p.x = 0:p.dx:p.Lx -p.dx;
    p.T = 600;
    p.dt = 0.01;
    p.num_timesteps = ceil(p.T/p.dt);
    p.t = p.dt:p.dt:p.dt*p.num_timesteps;
    p.constant = .5*p.Lx/pi;
    p.observed_modes = 20;
    p.mu = 100;
    p.modes = 1:p.N/2;
    p.lambda = 1;
    p.k = [0:p.N/2-1 0 -p.N/2+1:-1]*(2*pi/p.Lx);
    p.E = exp(p.dt*(p.lambda*p.k.^2 - p.k.^4));
    p.dealias_mask = abs(p.k) <= floor((2/3)*p.N);
    p.characteristic_velocity = 1.3;
    

    p.show = p.T/p.dt;
    p.soln_history = zeros(p.N, ceil(p.num_timesteps/p.show)+1);
    p.n = 1;
    p.save_vars = false;
    p.plot_gif = false;
    p.plot_var = true;
    p.stop_when_reached_machine_precision = false;
    p.show_interpolation_error = false;
    p.im = {};
    p.plot_kse_solution = false;
    p.collect_sensor_trajectory = false;
end