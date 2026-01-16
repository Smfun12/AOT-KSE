function bias_sensors_analysis(generate_figures, output_filename)
% Script to analyze Bias Sensors placement for all combinations of
% left_half and right_half up to 60, and create 3D plots of the results.
%
% Inputs:
%   generate_figures - (optional) boolean, if true generates figures (default: false)
%                      Set to false for cluster/SLURM runs
%   output_filename  - (optional) string, filename to save data (default: auto-generated)
%
% Usage:
%   bias_sensors_analysis()                    % Cluster mode: no figures, saves data
%   bias_sensors_analysis(false)              % Cluster mode: no figures, saves data
%   bias_sensors_analysis(true)                % Local mode: generates figures
%   bias_sensors_analysis(false, 'my_data.mat') % Cluster mode with custom filename

if nargin < 1
    generate_figures = false;  % Default to cluster mode
end
if nargin < 2
    timestamp = string(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
    output_filename = "bias_sensors_data_" + timestamp + ".mat";
    generate_figures = true;
end

close all; clc;
addpath("utils/", "default_config/", "plotting/", "target_sensors_functions/", "brewer/");

% Initialize environment
p = initDefaultEnv();
% Disable plotting during simulation for speed
p.plot_var = false;
p.plot_gif = false;
p.plot_kse_solution = false;
p.save_vars = false;

% Maximum value for left_half and right_half
max_sensors = 3;

% Preallocate arrays to store results
results_left = [];
results_right = [];

% Initialize arrays for 3D plots
X_left = [];
Y_left = [];
Z_left = [];

X_right = [];
Y_right = [];
Z_right = [];

fprintf('Starting Bias Sensors analysis...\n');
fprintf('Total combinations to test: %d\n', max_sensors * max_sensors);

% Loop over all combinations of left_half and right_half
for left_half = 1:max_sensors
    for right_half = 1:max_sensors
        total_sensors = left_half + right_half;
        
        % Skip if total exceeds reasonable limit (optional)
        if total_sensors > 200
            continue;
        end
        
        fprintf('Testing: left_half = %d, right_half = %d, total = %d\n', ...
            left_half, right_half, total_sensors);
        
        % Create Bias Sensors configuration
        vars = createBiasSensorsConfig(p, left_half, right_half);
        p.size_vars = length(vars);
        
        % Run simulation
        [final_error, vars] = runSimulation(p, vars);
        
        % Store results for left_half plot
        X_left = [X_left; left_half / total_sensors];
        Y_left = [Y_left; total_sensors];
        Z_left = [Z_left; final_error];
        
        % Store results for right_half plot
        X_right = [X_right; right_half / total_sensors];
        Y_right = [Y_right; total_sensors];
        Z_right = [Z_right; final_error];
        
        results_left = [results_left; left_half, right_half, total_sensors, final_error];
        results_right = [results_right; right_half, left_half, total_sensors, final_error];
    end
end

% Save data to file
fprintf('Saving data to: %s\n', output_filename);
save(output_filename, 'X_left', 'Y_left', 'Z_left', 'X_right', 'Y_right', 'Z_right', ...
     'results_left', 'results_right', 'max_sensors', '-v7.3');
fprintf('Data saved successfully!\n');

% Generate figures if requested
if generate_figures
    plot_bias_sensors_results(output_filename);
else
    fprintf('Figures not generated (cluster mode).\n');
    fprintf('To generate figures locally, run: plot_bias_sensors_results(''%s'')\n', output_filename);
end

fprintf('Analysis complete!\n');

end

function vars = createBiasSensorsConfig(p, left_half, right_half)
% Creates a Bias Sensors configuration with specified left_half and right_half
    vars = repelem(struct, 1, 1);
    vars(1).observer_type = "Bias Sensors";
    vars(1).interpolation_type = "linear";
    vars(1).num_sensors = left_half + right_half;
    vars(1).sensors = [linspace(0, floor(p.Lx/2), left_half) ...
                       linspace(ceil(p.Lx/2), p.Lx-p.dx, right_half)];
    vars(1).error = NaN(1, p.num_timesteps);
    vars(1).error_aot = vars(1).error;
    vars(1).off_grid = true;
    vars(1).marker = 's';
    vars(1).outline_color = 'k';
    vars(1).color = 'y';
end

function [final_error, vars] = runSimulation(p, vars)
% Runs the KSE simulation and returns the final L2 error
    
    % Reset simulation parameters
    p.n = 1;
    p.ti = 0;
    p.soln_history = zeros(p.N, ceil(p.num_timesteps/p.show)+1);
    
    % Initial condition
    u_0 = cos(p.x/p.constant).*(1+sin(p.x/p.constant));
    u_hat = fft(u_0);
    p.soln_history(:,1) = u_0;
    
    % Initialize truncation and AOT field
    [p] = findTruncIndex(p);
    [u_hat] = updateUHat(p, u_hat);
    [vars] = updateVarsWithAOTField(vars, u_hat, p.trunc_index);
    
    % Run simulation
    varsIndicesWithMachinePrecision = zeros(1, p.size_vars);
    for ti = 1:p.num_timesteps
        u_hat_old = u_hat;
        
        if mod(ti, 1000) == 0
            fprintf('  Timestep: %d/%d\n', ti, p.num_timesteps);
        end
        
        % Update solution
        nonlin_term = (1i*p.k/2).*fft(real(ifft(u_hat.*p.dealias_mask)).^2);
        u_hat = p.E.*(u_hat - p.dt*nonlin_term);
        
        p.ti = ti;
        u_phys = real(ifft(u_hat,'symmetric'));
        p.soln_history(:,p.n+1) = u_phys;
        p.n = p.n+1;
        
        % Update observers
        error_counter = 0;
        for i=1:p.size_vars
            if ~varsIndicesWithMachinePrecision(i)
                [var] = updateObserversLocations(vars(i), p, u_hat_old, vars(i).aot_hat);
                [var] = updateAOTSolution(var, p, u_hat, u_hat_old);
                vars(i) = var;
            end
            if p.collect_sensor_trajectory
                vars(i).sensor_history(ti+1, :) = vars(i).sensors;
            end
        end
        
        if error_counter == p.size_vars
            break
        end
    end
    
    % Get final error (last non-NaN value)
    error_values = vars(1).error_aot(~isnan(vars(1).error_aot));
    if ~isempty(error_values)
        final_error = error_values(end);
    else
        final_error = NaN;
    end
end

