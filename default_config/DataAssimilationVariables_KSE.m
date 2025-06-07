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

num_sensors = 1024;
K = 0;




% Uncomment the type of observer you want to use.
%% Uniform grid setup
    % i = i+1;
    % vars(i).observer_type = "Uniform";
    % % dx=0.0982
    % vars(i).interpolation_type = "linear";
    % vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % % vars(i).sensors = 1:1:num_sensors;
    % vars(i).off_grid = true;
    % 
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).marker = '-s';
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).Ks = [];
    % vars(i).interpolation_error = [];
    % vars(i).im = [];
    % vars(i).sens_fig = [];

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
    % i = i+1;
    % vars(i).observer_type = "Lagrangian";
    % vars(i).interpolation_type = "linear";
    % % vars(i).sensors = p.x(1:513:N);
    % vars(i).num_sensors = num_sensors;
    % vars(i).sensors = linspace(p.x(1), p.x(end), vars(i).num_sensors);
    % % vars(i).sensors = (p.x(1)+p.x(end))/2;
    % vars(i).marker = 's';
    % vars(i).color = 'yellow';
    % vars(i).off_grid = true;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).amplitude = 0;
    % vars(i).interpolation_error = [];
    % vars(i).im = [];
    % vars(i).main_fig = figure;
    % vars(i).sens_fig = figure(80);
    % vars(i).difference = [];
    %% Lagrangian-Creeps observers 45
    % i = i+1;
    % vars(i).observer_type = "Lagrangian";
    % vars(i).interpolation_type = "linear";
    % % vars(i).sensors = p.x(1:25:N);
    % vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % vars(i).marker = '-o';
    % vars(i).off_grid = true;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).amplitude = 50;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).interpolation_error = [];
    % vars(i).im = [];
    % % vars(i).sens_fig = figure(80);
    % vars(i).difference = [];


 %% Lagrangian-stokes
    % i = i+1;
    % vars(i).observer_type = "Inertia";
    % vars(i).interpolation_type = "linear";
    % % vars(i).sensors = p.x(1:25:N);
    % vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % % vars(i).sensors = (p.x(1)+p.x(end))/2;
    % vars(i).vel = zeros(1, num_sensors);
    % vars(i).rho = 0.0139197;
    % vars(i).diameter = 10;
    % vars(i).marker = 'o';
    % vars(i).color = "cyan";
    % vars(i).off_grid = true;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).main_fig = figure;
    % % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).interpolation_error = [];
    % vars(i).im = [];
    % vars(i).stokes_number = [];
    % vars(i).sens_fig = figure(80);
    % vars(i).difference = [];
 %% Lagrangian-stokes
    % i = i+1;
    % vars(i).observer_type = "Inertia";
    % vars(i).interpolation_type = "linear";
    % % vars(i).sensors = p.x(1:25:N);
    % vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % % vars(i).sensors = (p.x(1)+p.x(end))/2;
    % vars(i).vel = zeros(1, num_sensors);
    % vars(i).rho = 0.139197;
    % vars(i).diameter = 10;
    % vars(i).marker = '^';
    % vars(i).color = "red";
    % vars(i).off_grid = true;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % % vars(i).main_fig = figure;
    % % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).interpolation_error = [];
    % vars(i).im = [];
    % vars(i).stokes_number = [];
    % % vars(i).sens_fig = figure(80);
    % vars(i).difference = [];

 %% Lagrangian-stokes
    % i = i+1;
    % vars(i).observer_type = "Inertia";
    % vars(i).interpolation_type = "linear";
    % % vars(i).sensors = p.x(1:25:N);
    % vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % % vars(i).sensors = (p.x(1)+p.x(end))/2;
    % vars(i).vel = zeros(1, num_sensors);
    % vars(i).rho = 1.39197;
    % vars(i).diameter = 10;
    % vars(i).marker = 'd';
    % vars(i).color = "blue";
    % vars(i).off_grid = true;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % % vars(i).main_fig = figure;
    % % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).interpolation_error = [];
    % vars(i).im = [];
    % vars(i).stokes_number = [];
    % % vars(i).sens_fig = figure(80);
    % vars(i).difference = [];
%% Lagrangian-stokes
    i = i+1;
    vars(i).observer_type = "Inertia";
    vars(i).interpolation_type = "linear";
    % vars(i).sensors = p.x(1:25:N);
    vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % vars(i).sensors = (p.x(1)+p.x(end))/2;
    vars(i).vel = zeros(1, num_sensors);
    vars(i).rho = 13.9197;
    vars(i).diameter = 10;
    vars(i).marker = 'p';
    vars(i).color = "magenta";
    vars(i).off_grid = true;
    vars(i).error = NaN(1,p.num_timesteps);
    vars(i).error_aot = vars(i).error;
    vars(i).main_fig = figure;
    vars(i).main_fig.Position(3:4) = [1000 700];
    vars(i).interpolation_error = [];
    vars(i).im = [];
    vars(i).stokes_number = [];
    vars(i).sens_fig = figure(80);
    vars(i).difference = [];

%% Lagrangian-stokes
    % i = i+1;
    % vars(i).observer_type = "Inertia";
    % vars(i).interpolation_type = "linear";
    % % vars(i).sensors = p.x(1:25:N);
    % vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % % vars(i).sensors = (p.x(1)+p.x(end))/2;
    % vars(i).vel = zeros(1, num_sensors);
    % vars(i).rho = 161.568;
    % vars(i).diameter = 10;
    % vars(i).marker = 'h';
    % vars(i).color = "k";
    % vars(i).off_grid = true;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % % vars(i).main_fig = figure;
    % % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).interpolation_error = [];
    % vars(i).im = [];
    % vars(i).stokes_number = [];
    % % vars(i).sens_fig = figure(80);
    % vars(i).difference = []; 
   




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
    % vars(i).interpolation_type = "linear";
    % vars(i).interpolation_error = [];
    % vars(i).num_sensors = 2;
    % vars(i).sensors = sort(p.x(randperm(p.N, vars(i).num_sensors)));
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).marker = '-square';
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).off_grid=false;
%% Target-Sensors
    % i = i+1;
    % vars(i).observer_type = "Physical Target Sensors";
    % vars(i).interpolation_type = "linear";
    % vars(i).num_sensors = num_sensors;
    % % vars(i).sensors = sort(p.x(randperm(p.N, vars(i).num_sensors)));
    % vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % % vars(i).sensors = p.x(1:10:N);
    % vars(i).old_locations = [];
    % vars(i).change_triggered = false;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).off_grid = true;
    % vars(i).target_off_grid = true;
    % vars(i).main_fig = figure;
    % vars(i).interpolation_error = [];
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).nu = 1;
    % % vars(i).my_k = 0.8;
    % vars(i).K = K; % 32
    % vars(i).alg = 2;
    % % vars(i).K = 4.36; % 52
    % % vars(i).K = 1.8; % 103
    % vars(i).nudg_parameter = p.mu;
    % % vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
    % vars(i).my_k = vars(i).nu*vars(i).nudg_parameter;
    % % vars(i).c = p.Lx/pi;
    % vars(i).c=1/sqrt(12);
    % vars(i).distances = [];
    % vars(i).marker = '-|';
    % vars(i).mapping = [];
    % vars(i).sens_fig = [];
    % vars(i).target_sensors = [];
    % vars(i).number_target_sensors = [];
    % vars(i).im = {};
%% Unphysical-Target-Sensors
    % i = i+1;
    % vars(i).observer_type = "Nonphysical Target Sensors";
    % vars(i).interpolation_type = "linear";
    % vars(i).num_sensors = num_sensors;
    % % vars(i).sensors = sort(p.x(randperm(p.N, vars(i).num_sensors)));
    % vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).grid_sensors = false;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).nu = 1;
    % vars(i).alg = 1;
    % vars(i).target_off_grid = true;
    % vars(i).off_grid = true;
    % vars(i).marker = '-^';
    % vars(i).K = K;
    % vars(i).nudg_parameter = p.mu;
    % vars(i).my_k = vars(i).nu*vars(i).nudg_parameter;
    % % vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
    % vars(i).c = 1/sqrt(12);
    % vars(i).sens_fig = [];
    % vars(i).im = [];
    % vars(i).interpolation_error = [];
    % vars(i).target_sensors = [];
    % vars(i).number_target_sensors = [];

%% Unphysical-Target-Sensors
    % i = i+1;
    % vars(i).observer_type = "Nonphysical Target Sensors";
    % vars(i).interpolation_type = "linear";
    % vars(i).num_sensors = num_sensors;
    % % vars(i).sensors = sort(p.x(randperm(p.N, vars(i).num_sensors)));
    % vars(i).sensors = linspace(p.x(1), p.x(end), num_sensors);
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).grid_sensors = false;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).nu = 1;
    % vars(i).alg = 2;
    % vars(i).target_off_grid = true;
    % vars(i).off_grid = true;
    % vars(i).marker = '-o';
    % vars(i).K = K;
    % vars(i).nudg_parameter = p.mu;
    % vars(i).my_k = vars(i).nu*vars(i).nudg_parameter;
    % % vars(i).nudg_parameter = vars(i).my_k / vars(i).nu;
    % vars(i).c = 1/sqrt(12);
    % vars(i).sens_fig = [];
    % vars(i).im = [];
    % vars(i).interpolation_error = [];
    % vars(i).target_sensors = [];
    % vars(i).number_target_sensors = [];
end
