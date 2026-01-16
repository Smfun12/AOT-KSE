function plot_bias_sensors_results(data_filename)
% Function to load saved bias sensors analysis data and generate 3D plots
%
% Inputs:
%   data_filename - (optional) string, filename of saved data
%                   If not provided, will look for most recent bias_sensors_data_*.mat file
%
% Usage:
%   plot_bias_sensors_results()                    % Loads most recent data file
%   plot_bias_sensors_results('bias_sensors_data_20240101_120000.mat')

% Check if running in headless environment and set appropriate renderer
try
    % Try to create a test figure to check if display is available
    test_fig = figure('Visible', 'off');
    close(test_fig);
    use_software_renderer = false;
catch
    % If figure creation fails, we're likely in headless mode
    use_software_renderer = true;
    warning('Display may not be available. Using software renderer.');
end

if nargin < 1
    % Find most recent bias_sensors_data_*.mat file
    files = dir('bias_sensors_data_*.mat');
    if isempty(files)
        error('No bias_sensors_data_*.mat files found. Please specify a filename.');
    end
    [~, idx] = max([files.datenum]);
    data_filename = files(idx).name;
    fprintf('Loading most recent data file: %s\n', data_filename);
end

% Load data
if ~exist(data_filename, 'file')
    error('Data file not found: %s', data_filename);
end

fprintf('Loading data from: %s\n', data_filename);
data = load(data_filename);

% Extract data
X_left = data.X_left;
Y_left = data.Y_left;
Z_left = log10(data.Z_left);  % Apply log scale to error
X_right = data.X_right;
Y_right = data.Y_right;
Z_right = log10(data.Z_right);  % Apply log scale to error

% Create 3D plot for left_half
fig1 = figure('Position', [100, 100, 1200, 800]);
if use_software_renderer
    set(fig1, 'Renderer', 'painters');
end
plot3(X_left, Y_left, Z_left, 'MarkerSize', 10);
xlabel('$l$/$N$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('$N$', 'Interpreter', 'latex', 'FontSize', 14);
zlabel('$\log_{10}(\|\epsilon\|_{L^2})$', 'Interpreter', 'latex', 'FontSize', 14);
title('Bias Sensors: Error vs $l/N$ ratio and $N$', ...
    'Interpreter', 'latex', 'FontSize', 16);
view(45, 30);
fontsize(36, "points")

% Create 3D plot for right_half
fig2 = figure('Position', [200, 200, 1200, 800]);
if use_software_renderer
    set(fig2, 'Renderer', 'painters');
end
plot3(X_right, Y_right, Z_right, 'MarkerSize', 10);
xlabel('$r$/$N$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('$N$', 'Interpreter', 'latex', 'FontSize', 14);
zlabel('$\log_{10}(\|\epsilon\|_{L^2})$', 'Interpreter', 'latex', 'FontSize', 14);
title('Bias Sensors: Error vs $r/N$ ratio and $N$', ...
    'Interpreter', 'latex', 'FontSize', 16);
view(45, 30);
fontsize(36, "points")

fprintf('Figures generated successfully!\n');

end

