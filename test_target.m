clear; close all; clc;
L = 32*pi;           % domain length
N = 256;             % spatial points (power of 2)
x = L*(0:N-1)/N;     % grid
dt = 0.001;           % timestep
T = 200;             % total time
Nt = round(T/dt);

mu = 400;             % nudging strength


k = [0:N/2-1 0 -N/2+1:-1]' * (2*pi/L);
k2 = k.^2; k4 = k.^4;


u = cos(x/16).*(1 + sin(x/16)) + 0.01*randn(size(x));
v = 0.5*randn(size(x));  % nudged initial guess


N_sensors = 256;

% Compute initial gradient-based distance function for adaptive targets
u_x = spectral_derivative(u, L);
h = @(xq) compute_h(xq, x, u_x);

% Compute adaptive sensor targets on [0, L]
sensor_targets = adaptive_mesh_split(h, 0, L, N_sensors);

% Initialize sensors with small perturbation and speeds
sensor_positions = linspace(x(1), x(end), N_sensors);
sensor_speeds = 0.1 + zeros(1, N_sensors);
sensor_done = false(1, N_sensors);

%% ETDRK4 precompute coefficients
L_op = k2 - k4;
E = exp(dt*L_op);
E2 = exp(dt*L_op/2);
M = 16;
r = exp(1i*pi*((1:M)-0.5)/M);
LR = dt*L_op(:,ones(M,1)) + r(ones(length(k),1),:);
Q = dt*mean( (exp(LR/2) - 1)./LR , 2);
f1 = dt*mean( (-4 - LR + exp(LR).*(4 - 3*LR + LR.^2))./LR.^3 , 2);
f2 = dt*mean( (2 + LR + exp(LR).*(-2 + LR))./LR.^3 , 2);
f3 = dt*mean( (-4 - 3*LR - LR.^2 + exp(LR).*(4 - LR))./LR.^3 , 2);


errors = zeros(1, Nt);


for n = 1:Nt
    % --- True solution update ---
    v_hat = fft(u');
    u_phys = u';
    N1 = nonlinear_term(u_phys, k);
    a = E2 .* v_hat + Q .* N1;
    ua = real(ifft(a));
    Na = nonlinear_term(ua, k);
    b = E2 .* v_hat + Q .* Na;
    ub = real(ifft(b));
    Nb = nonlinear_term(ub, k);
    c = E2 .* a + Q .* (2*Nb - N1);
    uc = real(ifft(c));
    Nc = nonlinear_term(uc, k);
    v_hat_new = E .* v_hat + N1 .* f1 + 2*(Na + Nb).*f2 + Nc .* f3;
    u = real(ifft(v_hat_new))';

    % --- Nudged solution update ---
    v_hat_nudged = fft(v');
    v_phys = v';

    % Interpolate u and v at sensor positions
    u_obs = interp1(x, u, mod(sensor_positions,L), 'spline');
    v_obs = interp1(x, v, mod(sensor_positions,L), 'spline');

    % Nudging forcing term
    nudging = zeros(size(v));
    for i = 1:N_sensors
        [~, idx] = min(abs(mod(x - sensor_positions(i) + L/2, L) - L/2));
        nudging(idx) = nudging(idx) + mu * (u_obs(i) - v_obs(i));
    end

    % Advance nudged solution with nudging forcing included in nonlinear term
    N1_nudged = nonlinear_term(v_phys, k) + fft(nudging');
    a = E2 .* v_hat_nudged + Q .* N1_nudged;
    ua = real(ifft(a));
    Na = nonlinear_term(ua, k) + fft(nudging');
    b = E2 .* v_hat_nudged + Q .* Na;
    ub = real(ifft(b));
    Nb = nonlinear_term(ub, k) + fft(nudging');
    c = E2 .* a + Q .* (2*Nb - N1_nudged);
    uc = real(ifft(c));
    Nc = nonlinear_term(uc, k) + fft(nudging');
    v_hat_new_nudged = E .* v_hat_nudged + N1_nudged .* f1 + 2*(Na + Nb).*f2 + Nc .* f3;
    v = real(ifft(v_hat_new_nudged))';

    % --- Move sensors toward targets, stop if reached ---
    % for i = 1:N_sensors
    %     if sensor_done(i), continue; end
    %     d = mod(sensor_targets(i) - sensor_positions(i) + L/2, L) - L/2;
    %     step = sensor_speeds(i) * dt;
    %     if abs(d) <= step
    %         sensor_positions(i) = sensor_targets(i);
    %         sensor_done(i) = true;
    %     else
    %         sensor_positions(i) = mod(sensor_positions(i) + sign(d)*step, L);
    %     end
    % end

    % --- Track error ---
    errors(n) = norm(u - v) / sqrt(N);

    % --- Optional visualization ---
    if mod(n, 50) == 0
        clf;
        plot(x, u, 'b', x, v, 'r--', sensor_positions, 0, 'ko', 'MarkerFaceColor', 'k');
        legend('Truth u', 'Nudged v', 'Sensors');
        title(sprintf('Time = %.2f, Error = %.3e', n*dt, errors(n)));
        xlabel('x'); ylabel('u(x,t)');
        axis([0 L -3 3]);
        drawnow;
    end
end

% Plot error convergence
figure;
plot(dt*(1:Nt), errors, 'LineWidth', 2);
xlabel('Time'); ylabel('L^2 Error');
title('Error convergence with moving adaptive sensors on KSE');
% grid on;


%% Nonlinear term for KSE: FFT of -0.5i*k*fft(u.^2)
function N = nonlinear_term(u_phys, k)
    u_sq = u_phys.^2;
    N = -0.5i * k .* fft(u_sq);
end

%% Spectral derivative (not used here but useful)
function ux = spectral_derivative(u, L)
    N = length(u);
    k = [0:N/2-1 0 -N/2+1:-1]' * (2*pi/L);
    u_hat = fft(u);
    ux = real(ifft(1i * k' .* u_hat));
end

%% Adaptive mesh splitting function (same as before)
function x_mesh = adaptive_mesh_split(h, a, b, N)
    x_fine = linspace(a, b, 256);
    h_vals = h(x_fine);
    h_vals(h_vals <= 0) = eps;
    inv_h = 1 ./ h_vals;
    cumulative = cumtrapz(x_fine, inv_h);
    total_integral = cumulative(end);
    s_target = linspace(0, total_integral, N+1);
    x_mesh = interp1(cumulative, x_fine, s_target, 'linear');
end

%% Distance function h based on gradient magnitude of u
function h_vals = compute_h(xq, x_grid, u_x)
    grad_interp = interp1(x_grid, abs(u_x), mod(xq, max(x_grid)), 'linear');
    h_vals = 0.05 + 1 ./ (1 + 10 * grad_interp);
end
