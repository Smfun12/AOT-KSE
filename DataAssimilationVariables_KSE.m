function vars = DataAssimilationVariables_KSE(p)
% Author: Collin Victor. Last modified on 2020-09-25.
% Adapted for use by NSE 2D DA programs
% Initializes information for various types of observer regimes
% Including: Movement types of observers (i.e. mobile and static), type of
% interpolation, time type of observers (i.e. Chi vs Delta), and observer reset
% functionality.

sensors_types = ["uniform", "lagrangian", "dynamic dd", "random", "random+dd", 'static dd', "zhao dd" "target sensors", "unphysical target sensors"];

vars = [];
vars = repelem(struct,1,1);
i = 0;
offset = 0;

dx = p.dx;
dt = p.dt;
N = p.N;




% Uncomment the type of observer you want to use.
%% Uniform grid setup
    % i = i+1;
    % vars(i).observer_type = "Uniform";
    % % dx=0.0982
    % vars(i).sensors = 1:32:N;
    % vars(i).off_grid = false;
    % 
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).marker = '-o';
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).Ks = [];
    % vars(i).interpolation_error = [];
%% Uniform grid setup
    i = i+1;
    vars(i).observer_type = "Uniform";
    % dx=0.0982
    vars(i).interpolation_type = "linear";
    vars(i).sensors = p.x(1:20:N)+p.dx/4;
    vars(i).off_grid = true;
    vars(i).interpolation_error = [];
    vars(i).error = NaN(1,p.num_timesteps);
    vars(i).error_aot = vars(i).error;
    vars(i).marker = '-o';
    vars(i).main_fig = figure;
    vars(i).main_fig.Position(3:4) = [1000 700];
    vars(i).Ks = [];
%% Uniform grid setup
    i = i+1;
    vars(i).observer_type = "Uniform";
    % dx=0.0982
    vars(i).interpolation_type = "spline";
    vars(i).sensors = p.x(1:20:N)+p.dx/4;
    vars(i).off_grid = true;
    vars(i).interpolation_error = [];
    vars(i).error = NaN(1,p.num_timesteps);
    vars(i).error_aot = vars(i).error;
    vars(i).marker = '-x';
    vars(i).main_fig = figure;
    vars(i).main_fig.Position(3:4) = [1000 700];
    vars(i).Ks = [];
%% Eulerian-Creeps grid setup
    % i = i+1;
    % vars(i).observer_type = "Creeps";
    % vars(i).sensors = 1:32:N;
    % vars(i).grid_sensors = false;
    % 
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).marker = '-x';
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).Ks = [];
%% Lagrangian-Creeps observers
    % i = i+1;
    % vars(i).observer_type = "Lagrangian";
    % vars(i).sensors = p.x(1:32:N);
    % vars(i).grid_sensors = true;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).marker = '-^';
    % vars(i).amplitude = 0;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];

%% Lagrangian-Creeps observers 10
    % i = i+1;
    % vars(i).observer_type = "Lagrangian";
    % vars(i).sensors = p.x(1:32:N);
    % vars(i).grid_sensors = true;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).amplitude = 10;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
%% Lagrangian-Creeps observers 45
    % i = i+1;
    % vars(i).observer_type = "Lagrangian";
    % vars(i).sensors = p.x(1:32:N);
    % vars(i).grid_sensors = true;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).amplitude = 45;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];


%% Lagrangian-Creeps observers 50
    % i = i+1;
    % vars(i).observer_type = "Lagrangian";
    % vars(i).sensors = p.x(1:32:N);
    % vars(i).grid_sensors = true;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).amplitude = 50;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];

%% Dynamic DD
    % i = i+1;
    % vars(i).observer_type = "Dynamic-DD";
    % vars(i).sensors = 1:32:N;
    % 
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % 
    % vars(i).r = 5;
    % vars(i).p = 32;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % n = 1;

%% Static-DD
    % i = i+1;
    % vars(i).observer_type = "Static-DD";
    % vars(i).sensors = 1:32:N;
    % 
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).marker = '-pentagram';
    % vars(i).r = 5;
    % vars(i).p = 32;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];

%% Random-DD
    % i = i+1;
    % vars(i).observer_type = "Random-DD";
    % vars(i).sensors = p.x(1:32:N);
    % vars(i).basis_counter = 1;
    % vars(i).temp_basis_size = 100;
    % vars(i).temp_basis = [];
    % vars(i).grid_sensors = false;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % 
    % vars(i).r = 5;
    % vars(i).p = 32;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];

%% Zhao-DD
    % i = i+1;
    % vars(i).observer_type = "Zhao-DD";
    % vars(i).sensors = (1:32:N);
    % vars(i).basis_counter = 1;
    % vars(i).temp_basis_size = 100;
    % vars(i).temp_basis = [];
    % vars(i).grid_sensors = false;
    % 
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % 
    % vars(i).r = 5;
    % vars(i).p = 32;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];

%% Random
    % i = i+1;
    % vars(i).observer_type = "Random";
    % vars(i).sensors = randi([1, p.N], 1,32);
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).marker = '-square';
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];

%% Target-Sensors
    % i = i+1;
    % vars(i).observer_type = "Target-Sensors";
    % % vars(i).sensors = sort(p.x(randi([1, p.N], 1,32)));
    % vars(i).sensors = p.x(1:32:N);
    % vars(i).old_locations = [];
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).off_grid = true;
    % vars(i).target_off_grid = false;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).nu = 1;
    % var.interpolation_error = [];
    % vars(i).my_k = 0.8;
    % vars(i).K = 8.22; % 32
    % % vars(i).K = 4.34; % 52
    % % vars(i).K = 1.8; % 103
    % vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
    % vars(i).c = p.Lx/pi;
    % vars(i).distances = [];
    % vars(i).marker = '-|';
    % vars(i).targets_frequency = 100;
    % vars(i).target_sensors = [];
    % vars(i).number_target_sensors = [];
%% Target-Sensors
    % i = i+1;
    % vars(i).observer_type = "Target-Sensors";
    % % vars(i).sensors = sort(p.x(randi([1, p.N], 1,32)));
    % vars(i).sensors = p.x(1:32:N);
    % vars(i).old_locations = [];
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).off_grid = true;
    % vars(i).target_off_grid = true;
    % vars(i).main_fig = figure;
    % vars(i).interpolation_error = [];
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).nu = 1;
    % vars(i).my_k = 0.8;
    % vars(i).K = 8.22; % 32
    % % vars(i).K = 4.34; % 52
    % % vars(i).K = 1.8; % 103
    % vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
    % vars(i).c = p.Lx/pi;
    % vars(i).distances = [];
    % vars(i).marker = '-|';
    % vars(i).targets_frequency = 100;
    % vars(i).target_sensors = [];
    % vars(i).number_target_sensors = [];

%% Unphysical-Target-Sensors
    % i = i+1;
    % vars(i).observer_type = "Unphysical-Target-Sensors";
    % vars(i).sensors = randi([1, p.N], 1, 32);
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).grid_sensors = false;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).nu = 1;
    % vars(i).target_off_grid = true;
    % vars(i).off_grid = true;
    % vars(i).marker = '-_';
    % vars(i).my_k = .8;
    % % vars(i).K = 4.34; % 52
    % % vars(i).K = 1.8; % 103
    % vars(i).K = 8.22; % 32
    % vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
    % vars(i).c = p.Lx/pi;
    % vars(i).targets_frequency = 100;
    % vars(i).interpolation_error = [];
    % vars(i).target_sensors = [];
% %% Target-Sensors
%     i = i+1;
%     vars(i).observer_type = "Target-Sensors";
%     % vars(i).sensors = sort(p.x(randi([1, p.N], 1,32)));
%     vars(i).sensors = p.x(1:32:N);
%     vars(i).old_locations = [];
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).grid_sensors = true;
%     vars(i).main_fig = figure;
%     vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).nu = 1;
%     vars(i).my_k = 0.8;
%     vars(i).K = 8.22;
%     % vars(i).K = 4.34; % 52
%     vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
%     vars(i).c = p.Lx/pi;
%     vars(i).marker = '-|';
%     vars(i).targets_frequency = 100;
%     vars(i).target_sensors = [];
%     vars(i).number_target_sensors = [];
% 
% %% Unphysical-Target-Sensors
%     i = i+1;
%     vars(i).observer_type = "Unphysical-Target-Sensors";
%     vars(i).sensors = randi([1, p.N], 1, 32);
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).grid_sensors = true;
%     vars(i).main_fig = figure;
%     vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).nu = 1;
%     vars(i).marker = '-_';
%     vars(i).my_k = .8;
%     % vars(i).K = 4.34; % 52
%     vars(i).K = 8.22; % 32
%     vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
%     vars(i).c = p.Lx/pi;
%     vars(i).targets_frequency = 100;
%     vars(i).target_sensors = [];
% %% Target-Sensors
%     i = i+1;
%     vars(i).observer_type = "Target-Sensors";
%     % vars(i).sensors = sort(p.x(randi([1, p.N], 1,32)));
%     vars(i).sensors = p.x(1:32:N);
%     vars(i).old_locations = [];
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).grid_sensors = true;
%     vars(i).main_fig = figure;
%     vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).nu = 1;
%     vars(i).my_k = 0.8;
%     vars(i).K = 8.22;
%     % vars(i).K = 4.34; % 52
%     vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
%     vars(i).c = p.Lx/pi;
%     vars(i).marker = '-|';
%     vars(i).targets_frequency = 200;
%     vars(i).target_sensors = [];
%     vars(i).number_target_sensors = [];
% 
% %% Unphysical-Target-Sensors
%     i = i+1;
%     vars(i).observer_type = "Unphysical-Target-Sensors";
%     vars(i).sensors = randi([1, p.N], 1, 32);
%     vars(i).error = NaN(1,p.num_timesteps);
%     vars(i).error_aot = vars(i).error;
%     vars(i).grid_sensors = true;
%     vars(i).main_fig = figure;
%     vars(i).main_fig.Position(3:4) = [1000 700];
%     vars(i).nu = 1;
%     vars(i).marker = '-_';
%     vars(i).my_k = .8;
%     % vars(i).K = 4.34; % 52
%     vars(i).K = 8.22; % 32
%     vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
%     vars(i).c = p.Lx/pi;
%     vars(i).targets_frequency = 200;
%     vars(i).target_sensors = [];

end