function KSE_inter()
clc; close all;
addpath("utils/");
addpath("default_config/");
addpath("plotting/");
% [db] = load("data/big_basis_kse.mat");
% [Ks] = load("K.mat");


% p.var_Ks = Ks.Ks;
% p.big_basis = db.datas;
% p.L = log4m.getLogger('logs.txt');


p = initDefaultEnv();

f = sin(p.x);

grid_factor = 2;
grid_spacing = p.x(1:grid_factor:p.N);

h = diff(grid_spacing);
h = [h, h(end)];
F = griddedInterpolant(grid_spacing, f(1:grid_factor:p.N));
f_int = F(p.x);
lhs = norm(f - f_int).^2;
rhs = h.^2 * norm(gradient(f)).^2;

lhs/rhs(1)


vars = DataAssimilationVariables_KSE(p);
p.size_vars = length(vars);

u_0 = cos(p.x/p.constant).*(1+sin(p.x/p.constant));
u_hat = fft(u_0);
p.soln_history(:,1) = u_0;

[trunc_index] = findTruncIndex(p);
[u_hat] = updateUHat(p, u_hat);
[vars] = updateVarsWithAOTField(vars, u_hat, trunc_index);

idx = round(p.N/2);
point_velocity = [u_0(idx)];
sample_frequency = 1;

for ti = 1:p.num_timesteps
    u_hat_old = u_hat;
    % p.L.info("KSE Main", "Iteration: " + ti + "/" + p.num_timesteps)
    % disp("Iteration: " + ti + "/" + p.num_timesteps)

    nonlin_term = (1i*p.k/2).*fft(real(ifft(u_hat.*p.dealias_mask)).^2);
    u_hat = p.E.*(u_hat - p.dt*nonlin_term);
    
    p.ti = ti;
    u_phys = real(ifft(u_hat,'symmetric'));
    if mod(ti, sample_frequency) == 0
        point_velocity = [point_velocity, u_phys(idx)];
        p.plot_time = [p.plot_time; ti*p.dt];
    end
    p.soln_history(:,p.n+1) = u_phys;
    p.n = p.n+1;
    
    error_counter = 0;
    for i=1:p.size_vars

        if p.stop_when_reached_machine_precision && vars(i).error < 1e-15
            error_counter = error_counter + 1;
            vars(i).interpolation_error = [vars(i).interpolation_error, vars(i).interpolation_error(end)];
            continue
        end
        
        [var] = updateObservers(vars(i), p, u_hat, vars(i).aot_hat);
        [var] = updateAOTSolution(var, p, u_hat, u_hat_old);

        if mod(ti,p.show)==0 && p.plot_var
            [var] = plotVar(var,p, u_hat);
        end
        vars(i) = var;

    end
    if error_counter == p.size_vars
        break
    end

end

vars(1).error
u_c = computeL2NormVelocity(p.soln_history);
% figure;
% plot(1:p.num_timesteps, vars(1).difference, "LineWidth", 2)
% xlabel("Time")
% ylabel("Max over $|x_{t_k} - x_{{t+1}_k}|$", "Interpreter","latex")
% fontsize(36, "points")

% fourierAnalysis(point_velocity, p);
plotFinalErrorForVars(vars, p)
% plot_darkmode

if p.plot_gif
    for i=1:p.size_vars
        plotGif(vars(i), p)
    end
end


if p.plot_kse_solution
    plotKSE(p)
end

end
function U_c = computeL2NormVelocity(velocityField)
    % Computes the characteristic velocity as the L2 norm over space and time.
    %
    % Parameters:
    % velocityField - A 3D array representing the velocity field:
    %                 (rows x cols x time steps)
    % dx            - Spatial resolution (assumes uniform grid)
    % dt            - Time resolution (uniform time steps)
    %
    % Returns:
    % U_c - The characteristic velocity (L2 norm)

    % Compute the squared magnitude of the velocity field
    velocitySquared = velocityField.^2;

    % Integrate over space and time
    spatialIntegral = sum(velocitySquared, [1]); % Sum over rows and columns
    totalIntegral = sum(spatialIntegral);             % Sum over time

    % Normalize by the total space and time
    domainSize = numel(velocityField(:, 1)); % Total spatial size
    totalTime = size(velocityField, 2);          % Total time duration

    % Compute the L2 norm
    U_c = sqrt(totalIntegral / (domainSize * totalTime));
end

function fourierAnalysis(func, p)
    T = p.T;
    dt = 1/T;
    fs = 1 / dt;     % Sampling frequency
    N = T / dt;      % Number of samples
    t = 0:dt:T; % Time vector
    
    % Example signal (replace with your function)
    % Example: A combination of two sine waves
    f1 = 5;          % Frequency 1 (Hz)
    f2 = 20;          % Frequency 2 (Hz)
    % signal = sin(2*pi*f1*t) + sin(2*pi*f2*t);
    signal = func;
    N = length(signal);
    % Fourier Transform
    fftSignal = fft(signal);
    P2 = abs(fftSignal / N);       % Two-sided spectrum
    P1 = P2(1:ceil(N/2));              % Single-sided spectrum
    P1(2:end-1) = 2*P1(2:end-1);   % Adjust for symmetry
    frequencies = fs * (0:(N/2)) / N;
    % frequencies = fftshift(frequencies);
    % Find the dominant frequency
    [~, idx] = max(P1);            % Index of maximum magnitude
    dominantFrequency = frequencies(idx);
    
    
    % Plot
    figure;
    subplot(2,1,1);
    plot(t, signal, "LineWidth", 2);
    title('Original Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    fontsize(24, "points")
    subplot(2,1,2);
    plot(frequencies, P1, "LineWidth",2);
    title('Single-Sided Amplitude Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('|P1(f)|');
    % xlim([0, 10]); % Adjust as needed
    grid on;
    fontsize(24, "points")
    
    % Display dominant frequency
    disp(['Dominant Frequency: ', num2str(dominantFrequency), ' Hz']);

end