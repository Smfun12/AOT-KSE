function vars = DataAssimilationVariables_KSE(p)
% Author: Collin Victor. Last modified on 2020-09-25.
% Adapted for use by NSE 2D DA programs
% Initializes information for various types of observer regimes
% Including: Movement types of observers (i.e. mobile and static), type of
% interpolation, time type of observers (i.e. Chi vs Delta), and observer reset
% functionality.

sensors_types = ["uniform", "lagrangian", "dynamic dd", "random", "random+dd", 'static dd', "zhao dd" "target sensors", "unphysical target sensors"];

vars = repelem(struct,1,1);
i = 0;
offset = 0;

dx = p.dx;
dt = p.dt;
N = p.N;

num_sensors = 103;
K = 0;




% Uncomment the type of observer you want to use.
%% Uniform grid setup
%     i = i+1;
%     vars(i).observer_type = "Uniform";
%     % dx=0.0982
%     vars(i).interpolation_type = "linear";
%     vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
%     % vars(i).sensors = 1:1:num_sensors;
%     vars(i).off_grid = true;
% 
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).marker = 's';
%     vars(i).color = 'blue';
%     % vars(i).main_fig = figure;
%     % vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).Ks = [];
%     vars(i).interpolation_error = [];
%     vars(i).im = [];
%     vars(i).sens_fig = [];
% % %% Uniform grid setup
%     i = i+1;
%     vars(i).observer_type = "Uniform";
%     % dx=0.0982
%     vars(i).interpolation_type = "linear";
%     vars(i).sensors = linspace(p.x(1), p.x(end), 103);
%     % vars(i).sensors = 1:1:num_sensors;
%     vars(i).off_grid = true;
% 
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).marker = '^';
%     % vars(i).main_fig = figure;
%     % vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).Ks = [];
%     vars(i).interpolation_error = [];
%     vars(i).im = [];
%     vars(i).sens_fig = [];
% %% Uniform grid setup
%     i = i+1;
%     vars(i).observer_type = "Uniform";
%     % dx=0.0982
%     vars(i).interpolation_type = "linear";
%     vars(i).sensors = linspace(p.x(1), p.x(end), 52);
%     % vars(i).sensors = 1:1:num_sensors;
%     vars(i).off_grid = true;
% 
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).marker = 'v';
%     % vars(i).main_fig = figure;
%     % vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).Ks = [];
%     vars(i).interpolation_error = [];
%     vars(i).im = [];
%     vars(i).sens_fig = [];
% %% Uniform grid setup
%     i = i+1;
%     vars(i).observer_type = "Uniform";
%     % dx=0.0982
%     vars(i).interpolation_type = "linear";
%     vars(i).sensors = linspace(p.x(1), p.x(end), 33);
%     % vars(i).sensors = 1:1:num_sensors;
%     vars(i).off_grid = true;
% 
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).marker = '>';
%     % vars(i).main_fig = figure;
%     % vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).Ks = [];
%     vars(i).interpolation_error = [];
%     vars(i).im = [];
%     vars(i).sens_fig = [];

%% Eulerian-Creeps grid setup
    % i = i+1;
    % vars(i).observer_type = "Creeps";
    % vars(i).interpolation_type = "linear";
    % vars(i).interpolation_error = [];
    % vars(i).sensors = 1:32:N;
    % vars(i).grid_sensors = false;
    % vars(i).off_grid=false;
    % 
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).marker = '-x';
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).Ks = [];
%% Lagrangian-Creeps observers 45
    i = i+1;
    vars(i).observer_type = "Lagrangian";
    vars(i).interpolation_type = "linear";
    % vars(i).sensors = p.x(1:513:N);
    vars(i).num_sensors = num_sensors;
    vars(i).sensors = linspace(p.x(1), p.x(end), vars(i).num_sensors);
    % vars(i).sensors = (p.x(1)+p.x(end))/2;
    vars(i).marker = 'v';
    vars(i).color = 'yellow';
    vars(i).off_grid = true;
    vars(i).error = NaN(1,p.num_timesteps);
    vars(i).error_aot = vars(i).error;
    vars(i).amplitude = 0;
    vars(i).interpolation_error = [];
    vars(i).im = [];
    % vars(i).main_fig = figure;
    % vars(i).sens_fig = figure(80);
    vars(i).difference = [];
%% Lagrangian-Creeps observers 45
    i = i+1;
    vars(i).observer_type = "Lagrangian";
    vars(i).interpolation_type = "linear";
    % vars(i).sensors = p.x(1:513:N);
    vars(i).num_sensors = num_sensors;
    vars(i).sensors = linspace(p.x(1), p.x(end), vars(i).num_sensors);
    % vars(i).sensors = (p.x(1)+p.x(end))/2;
    vars(i).marker = 'o';
    vars(i).color = 'green';
    vars(i).off_grid = true;
    vars(i).error = NaN(1,p.num_timesteps);
    vars(i).error_aot = vars(i).error;
    vars(i).amplitude = 40;
    vars(i).interpolation_error = [];
    vars(i).im = [];
    % vars(i).main_fig = figure;
    % vars(i).sens_fig = figure(80);
    vars(i).difference = [];

 %% Inertia sensors
 %    i = i+1;
 %    vars(i).observer_type = "Inertia";
 %    vars(i).interpolation_type = "linear";
 %    % vars(i).sensors = p.x(1:25:N);
 %    vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
 %    % vars(i).sensors = (p.x(1)+p.x(end))/2;
 %    vars(i).vel = zeros(1, num_sensors);
 %    vars(i).rho = 0.0139197;
 %    vars(i).diameter = 10;
 %    vars(i).marker = 'o';
 %    vars(i).color = "cyan";
 %    vars(i).off_grid = true;
 %    vars(i).error = NaN(1,p.num_timesteps);
 %    vars(i).error_aot = vars(i).error;
 %    vars(i).main_fig = figure;
 %    % vars(i).main_fig.Position(3:4) = [1000 700];
 %    vars(i).interpolation_error = [];
 %    vars(i).im = [];
 %    vars(i).stokes_number = [];
 %    % vars(i).sens_fig = figure(80);
 %    vars(i).difference = [];
 % %% Inertia sensors
 %    i = i+1;
 %    vars(i).observer_type = "Inertia";
 %    vars(i).interpolation_type = "linear";
 %    % vars(i).sensors = p.x(1:25:N);
 %    vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
 %    % vars(i).sensors = (p.x(1)+p.x(end))/2;
 %    vars(i).vel = zeros(1, num_sensors);
 %    vars(i).rho = 0.139197;
 %    vars(i).diameter = 10;
 %    vars(i).marker = '^';
 %    vars(i).color = "red";
 %    vars(i).off_grid = true;
 %    vars(i).error = NaN(1,p.num_timesteps);
 %    vars(i).error_aot = vars(i).error;
 %    % vars(i).main_fig = figure;
 %    % vars(i).main_fig.Position(3:4) = [1000 700];
 %    vars(i).interpolation_error = [];
 %    vars(i).im = [];
 %    vars(i).stokes_number = [];
 %    % vars(i).sens_fig = figure(80);
 %    vars(i).difference = [];
 % 
 % %% Inertia sensors
 %    i = i+1;
 %    vars(i).observer_type = "Inertia";
 %    vars(i).interpolation_type = "linear";
 %    % vars(i).sensors = p.x(1:25:N);
 %    vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
 %    % vars(i).sensors = (p.x(1)+p.x(end))/2;
 %    vars(i).vel = zeros(1, num_sensors);
 %    vars(i).rho = 1.39197;
 %    vars(i).diameter = 10;
 %    vars(i).marker = 'd';
 %    vars(i).color = "blue";
 %    vars(i).off_grid = true;
 %    vars(i).error = NaN(1,p.num_timesteps);
 %    vars(i).error_aot = vars(i).error;
 %    % vars(i).main_fig = figure;
 %    % vars(i).main_fig.Position(3:4) = [1000 700];
 %    vars(i).interpolation_error = [];
 %    vars(i).im = [];
 %    vars(i).stokes_number = [];
 %    % vars(i).sens_fig = figure(80);
 %    vars(i).difference = [];
%%  Inertia sensors
    i = i+1;
    vars(i).observer_type = "Inertia";
    vars(i).interpolation_type = "linear";
    % vars(i).sensors = p.x(1:25:N);
    vars(i).num_sensors = num_sensors;
    vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % vars(i).sensors = (p.x(1)+p.x(end))/2;
    vars(i).vel = zeros(1, num_sensors);
    vars(i).rho = 13.9197;
    vars(i).amplitude = 0;
    vars(i).diameter = 10;
    vars(i).marker = 'p';
    vars(i).color = "magenta";
    vars(i).off_grid = true;
    vars(i).error = NaN(1,p.num_timesteps);
    vars(i).error_aot = vars(i).error;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    vars(i).interpolation_error = [];
    vars(i).im = [];
    vars(i).stokes_number = [];
    % vars(i).sens_fig = figure(80);
    vars(i).difference = [];
%% Inertia sensors
    i = i+1;
    vars(i).observer_type = "Inertia";
    vars(i).interpolation_type = "linear";
    % vars(i).sensors = p.x(1:25:N);
    vars(i).num_sensors = num_sensors;
    vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % vars(i).sensors = (p.x(1)+p.x(end))/2;
    vars(i).vel = zeros(1, num_sensors);
    vars(i).rho = 13.9197;
    vars(i).amplitude = 40;
    vars(i).diameter = 10;
    vars(i).marker = 'h';
    vars(i).color = "k";
    vars(i).off_grid = true;
    vars(i).error = NaN(1,p.num_timesteps);
    vars(i).error_aot = vars(i).error;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    vars(i).interpolation_error = [];
    vars(i).im = [];
    vars(i).stokes_number = [];
    % vars(i).sens_fig = figure(80);
    vars(i).difference = []; 


%% Target-Sensors
    i = i+1;
    vars(i).observer_type = "Target Sensors";
    vars(i).interpolation_type = "linear";
    vars(i).num_sensors = num_sensors;
    % vars(i).sensors = sort(p.x(randperm(p.N, vars(i).num_sensors)));
    vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % vars(i).sensors = rand(1, num_sensors) + p.x(end/2);
    % vars(i).sensors = p.x(1:10:N);
    vars(i).old_locations = [];
    vars(i).change_triggered = false;
    vars(i).error = NaN(1,p.num_timesteps);
    vars(i).error_aot = vars(i).error;
    vars(i).off_grid = true;
    vars(i).target_off_grid = true;
    % vars(i).main_fig = figure;
    vars(i).interpolation_error = [];
    % vars(i).main_fig.Position(3:4) = [1000 700];
    vars(i).nu = 1;
    % vars(i).my_k = 0.8;
    vars(i).K = K; % 32
    vars(i).alg = 2;
    % vars(i).K = 4.36; % 52
    % vars(i).K = 1.8; % 103

    vars(i).nudg_parameter = p.mu;
    u0 = 1.3;
    t0 = p.Lx/u0;
    vars(i).target_frequency = floor(t0/p.dt * 0.02);
    % vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
    vars(i).my_k = vars(i).nu*vars(i).nudg_parameter;
    % vars(i).c = p.Lx/pi;
    vars(i).sensor_speed = 1;
    vars(i).c=1/sqrt(12);
    vars(i).distances = [];
    vars(i).marker = 'o';
    vars(i).color = 'green';
    vars(i).mapping = [];
    vars(i).sens_fig = [];
    vars(i).target_sensors = [];
    vars(i).number_target_sensors = [];
    vars(i).im = {};
% % 
%     %% Target-Sensors
%     i = i+1;
%     vars(i).observer_type = "Target Sensors";
%     vars(i).interpolation_type = "linear";
%     vars(i).num_sensors = num_sensors;
%     % vars(i).sensors = sort(p.x(randperm(p.N, vars(i).num_sensors)));
%     vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
%     % vars(i).sensors = rand(1, num_sensors) + p.x(end/2);
%     % vars(i).sensors = p.x(1:10:N);
%     vars(i).old_locations = [];
%     vars(i).change_triggered = false;
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).off_grid = true;
%     vars(i).target_off_grid = true;
%     % vars(i).main_fig = figure;
%     vars(i).interpolation_error = [];
%     % vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).nu = 1;
%     % vars(i).my_k = 0.8;
%     vars(i).K = K; % 32
%     vars(i).alg = 2;
%     % vars(i).K = 4.36; % 52
%     % vars(i).K = 1.8; % 103
% 
%     vars(i).nudg_parameter = p.mu;
%     u0 = 1.3;
%     t0 = p.Lx/u0;
%     vars(i).target_frequency = floor(t0/p.dt * 0.02);
%     % vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
%     vars(i).my_k = vars(i).nu*vars(i).nudg_parameter;
%     % vars(i).c = p.Lx/pi;
%     vars(i).sensor_speed = 10;
%     vars(i).c=1/sqrt(12);
%     vars(i).distances = [];
%     vars(i).marker = 'o';
%     vars(i).color = 'green';
%     vars(i).mapping = [];
%     vars(i).sens_fig = [];
%     vars(i).target_sensors = [];
%     vars(i).number_target_sensors = [];
%     vars(i).im = {};
% %% Target-Sensors
%     i = i+1;
%     vars(i).observer_type = "Target Sensors";
%     vars(i).interpolation_type = "linear";
%     vars(i).num_sensors = num_sensors;
%     % vars(i).sensors = sort(p.x(randperm(p.N, vars(i).num_sensors)));
%     vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
%     % vars(i).sensors = rand(1, num_sensors) + p.x(end/2);
%     % vars(i).sensors = p.x(1:10:N);
%     vars(i).old_locations = [];
%     vars(i).change_triggered = false;
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).off_grid = true;
%     vars(i).target_off_grid = true;
%     % vars(i).main_fig = figure;
%     vars(i).interpolation_error = [];
%     % vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).nu = 1;
%     % vars(i).my_k = 0.8;
%     vars(i).K = K; % 32
%     vars(i).alg = 2;
%     % vars(i).K = 4.36; % 52
%     % vars(i).K = 1.8; % 103
% 
%     vars(i).nudg_parameter = p.mu;
%     u0 = 1.3;
%     t0 = p.Lx/u0;
%     vars(i).target_frequency = floor(t0/p.dt * 0.02);
%     % vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
%     vars(i).my_k = vars(i).nu*vars(i).nudg_parameter;
%     % vars(i).c = p.Lx/pi;
%     vars(i).sensor_speed = 100;
%     vars(i).c=1/sqrt(12);
%     vars(i).distances = [];
%     vars(i).marker = 'o';
%     vars(i).color = 'green';
%     vars(i).mapping = [];
%     vars(i).sens_fig = [];
%     vars(i).target_sensors = [];
%     vars(i).number_target_sensors = [];
%     vars(i).im = {};
%% Target-Sensors
%     i = i+1;
%     vars(i).observer_type = "Target Sensors";
%     vars(i).interpolation_type = "linear";
%     vars(i).num_sensors = num_sensors;
%     % vars(i).sensors = sort(p.x(randperm(p.N, vars(i).num_sensors)));
%     vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
%     % vars(i).sensors = rand(1, num_sensors) + p.x(end/2);
%     % vars(i).sensors = p.x(1:10:N);
%     vars(i).old_locations = [];
%     vars(i).change_triggered = false;
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).off_grid = true;
%     vars(i).target_off_grid = true;
%     % vars(i).main_fig = figure;
%     vars(i).interpolation_error = [];
%     % vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).nu = 1;
%     % vars(i).my_k = 0.8;
%     vars(i).K = K; % 32
%     vars(i).alg = 2;
%     % vars(i).K = 4.36; % 52
%     % vars(i).K = 1.8; % 103
% 
%     vars(i).nudg_parameter = p.mu;
%     u0 = 1.3;
%     t0 = p.Lx/u0;
%     vars(i).target_frequency = floor(t0/p.dt * 0.02);
%     % vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
%     vars(i).my_k = vars(i).nu*vars(i).nudg_parameter;
%     % vars(i).c = p.Lx/pi;
%     vars(i).sensor_speed = 10000;
%     vars(i).c=1/sqrt(12);
%     vars(i).distances = [];
%     vars(i).marker = 'o';
%     vars(i).color = 'green';
%     vars(i).mapping = [];
%     vars(i).sens_fig = [];
%     vars(i).target_sensors = [];
%     vars(i).number_target_sensors = [];
%     vars(i).im = {};
% %% Forward-Sensors
%     i = i+1;
%     vars(i).observer_type = "Forward Sensors";
%     vars(i).interpolation_type = "linear";
%     vars(i).num_sensors = num_sensors;
%     vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
%     vars(i).old_locations = [];
%     vars(i).change_triggered = false;
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).off_grid = true;
%     vars(i).interpolation_error = [];
%     vars(i).nu = 1;
%     vars(i).nudg_parameter = p.mu;
%     vars(i).sensor_speed = 30;
%     vars(i).marker = 'o';
%     vars(i).color = 'green';
%     vars(i).im = {};
end
