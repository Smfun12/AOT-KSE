function KSE_inter()
% for iter=1:50
% clear; clc; close all;
close all; clc;
addpath("utils/", "default_config/", "plotting/", "target_sensors_functions/", "../KSE_CLEAN/brewer/");
% profile off
% profile on
p = initDefaultEnv();

vars = DataAssimilationVariables_KSE(p);
p.size_vars = min(length(vars), length(fieldnames(vars)));

u_0 = cos(p.x/p.constant).*(1+sin(p.x/p.constant));

u_hat = fft(u_0);
p.soln_history(:,1) = u_0;

[p] = findTruncIndex(p);
[u_hat] = updateUHat(p, u_hat);
[vars] = updateVarsWithAOTField(vars, u_hat, p.trunc_index);

varsIndicesWithMachinePrecision = zeros(1, p.size_vars);
for ti = 1:p.num_timesteps
    u_hat_old = u_hat;
    if mod(ti, p.print_iteration) == 0
        disp("Iteration: " + ti + "/" + p.num_timesteps)
    end
    nonlin_term = (1i*p.k/2).*fft(real(ifft(u_hat.*p.dealias_mask)).^2);
    u_hat = p.E.*(u_hat - p.dt*nonlin_term);
    
    p.ti = ti;
    u_phys = real(ifft(u_hat,'symmetric'));
    p.soln_history(:,p.n+1) = (u_phys);
    p.n = p.n+1;
    
    error_counter = 0;
    for i=1:p.size_vars
        if ~varsIndicesWithMachinePrecision(i)
            [var] = updateObservers(vars(i), p, u_hat_old, vars(i).aot_hat);
            if p.collect_sensor_trajecotory
                var.sensor_history(p.ti+1, :) = var.sensors;
            end
            [var] = updateAOTSolution(var, p, u_hat, u_hat_old);
            vars(i) = var;
            if mod(ti, p.print_iteration) == 0
                disp("Error="+var.error);
            end
        end
    end
    
    if mod(ti,p.show)==0 && p.plot_var
          p = plotVars(vars, p, u_hat);
    end
    if p.size_vars > 0 && vars(i).error_aot(ti) < 1e-14
        % error_counter = error_counter + 1;
        % varsIndicesWithMachinePrecision(i) = 1;
    end
    if  p.size_vars > 0 && error_counter == p.size_vars
        break
    end

end

% errors = [] ;
% try
%     err = load("err.mat");
%     errors = err.errors;
% catch ME
%     errors = [];
%     save("err.mat", "errors")
%     err = load("err.mat");
%     errors = err.errors;
% end
% 
% errors = [errors; vars(1).error_aot];
% save("err.mat", "errors")
% lagrange_info = [length(vars(1).sensors), vars(1).stokes_number, vars(1).amplitude];
% % lagrange_info = [length(vars(1).sensors), vars(1).amplitude];
% save("lagrange_info", "lagrange_info")

% save_vars = [];
% 
% for i=1:p.size_vars
%     save_vars = [save_vars, vars(i)];
% end

% timestamp = string(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
% filename = "vars" + timestamp + ".mat";
% 
% save(filename, "vars")
% vars(1).error
% u_c = computeL2NormVelocity(p.soln_history, p);
%a figure;
% plot(1:p.num_timesteps, vars(1).difference, "LineWidth", 2)
% xlabel("Time")
% ylabel("Max over $|x_{t_k} - x_{{t+1}_k}|$", "Interpreter","latex")
% fontsize(36, "points")

% fourierAnalysis(point_velocity, p);


if p.plot_gif
    for i=1:p.size_vars
        plotGif(p)
    end
end




if p.size_vars > 0
    plotFinalErrorForVars(vars, p)
end
if p.collect_sensor_trajecotory
    for i=1:p.size_vars
        plotSensorTrajectoryInXTPlane(p, vars(i))
    end
end
if p.plot_kse_solution
    plotKSE(p)
end
% end
% profile viewer
end
function U_c = computeL2NormVelocity(velocityField, p)
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
    spatialIntegral = (sum(velocitySquared, [1])); % Sum over rows and columns
    totalIntegral = sum(spatialIntegral);             % Sum over time

    % Normalize by the total space and time
    domainSize = numel(velocityField(:, 1)) * p.dx; % Total spatial size
    totalTime = size(velocityField, 2) * p.dt;          % Total time duration
 
    % Compute the L2 norm
    U_c = sqrt(totalIntegral * p.dx*p.dt / (domainSize * totalTime));

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