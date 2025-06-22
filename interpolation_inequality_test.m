clear; clc;

f = @(x) sin(pi*x);
df = @(x) pi*cos(pi*x);

check_interpolation_inequality(f, df);


function check_interpolation_inequality(f, df)
    % Fine grid over the domain
    p.N = 2^10;
    p.Lx = 32*pi;
    dx = p.Lx/p.N;
    x_fine = 0:dx:p.Lx -dx;
    p.x = x_fine;

    % True function and its derivative on fine grid
    f_vals = f(x_fine);
    df_vals = df(x_fine);

    % Compute H1 norm using simple Riemann sum
    H1_norm = sqrt(sum(f_vals.^2 + df_vals.^2) * dx);

    % Interpolation using sensor (node) values
    x_nodes = unique(sort(p.x(randi(1024, 1, ))));
    % x_nodes = p.x;
    f_interp = interpolate_observations(p, sin(pi*p.x), x_nodes);

    % Compute L2 error using simple sum
    L2_error = sqrt(sum((f_vals - f_interp).^2) * dx);

    % Estimate h as max node spacing
    h = max(diff(x_nodes));

    % Show result
    fprintf('h = %.4f\n', h);
    fprintf('L2 error = %.3e\n', L2_error);
    fprintf('H1 norm = %.3e\n', H1_norm);
    fprintf('Inequality ratio: error / (h^2 * ||f||_H1) = %.3f\n', ...
        L2_error / (h^2 * H1_norm));
end

function [vq1, bsv_data] = interpolate_observations(p, ref_solution, spatial_sensors)
    F_temp = griddedInterpolant(p.x, ref_solution);
    bsv_data = F_temp(spatial_sensors);
    x_pts = spatial_sensors';
    u_data1 = [bsv_data(end), bsv_data, bsv_data(1)];
    x_pts_per = x_pts;
    x_pts_per = [x_pts_per(end) - p.Lx; x_pts_per; x_pts_per(1) + p.Lx];
    F1 = griddedInterpolant(x_pts_per, u_data1.', "linear");
    vq1 = F1(p.x);
end