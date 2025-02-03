function vars = DataAssimilationVariables_KSE(p)
% Author: Collin Victor. Last modified on 2020-09-25.
% Adapted for use by NSE 2D DA programs
% Initializes information for various types of observer regimes
% Including: Movement types of observers (i.e. mobile and static), type of
% interpolation, time type of observers (i.e. Chi vs Delta), and observer reset
% functionality.

vars = repelem(struct,1,1);
i = 0;
N = p.N;


% Uncomment the type of observer you want to use.
%% Uniform grid setup
    % i = i+1;
    % vars(i).observer_type = "Uniform";
    % % dx=0.0982
    % vars(i).interpolation_type = "linear";
    % vars(i).sensors = 1:10:N;
    % vars(i).off_grid = false;
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

%% Dynamic DD
    % i = i+1;
    % vars(i).observer_type = "Dynamic-DD";
    % vars(i).sensors = 1:32:N;
    % vars(i).interpolation_error = [];
    % vars(i).interpolation_type = 'linear';
    % vars(i).off_grid = false;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).marker = '-pentagram';
    % vars(i).off_grid = false;
    % vars(i).r = 5;
    % vars(i).p = 32;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).sens_fig = [];

%% Static-DD
    i = i+1;
    vars(i).observer_type = "Static-DD";
    vars(i).sensors = 1:32:N;
    vars(i).interpolation_error = [];
    vars(i).interpolation_type = 'linear';
    vars(i).off_grid = false;
    vars(i).error = NaN(1,p.num_timesteps);
    vars(i).error_aot = vars(i).error;
    vars(i).marker = '-pentagram';
    vars(i).r = 5;
    vars(i).p = 32;
    vars(i).main_fig = figure;
    vars(i).main_fig.Position(3:4) = [1000 700];
    vars(i).sens_fig = [];

%% Random-DD
    % i = i+1;
    % vars(i).observer_type = "Random-DD";
    % vars(i).sensors = p.x(1:32:N);
    % vars(i).basis_counter = 1;
    % vars(i).temp_basis_size = 100;
    % vars(i).temp_basis = [];
    % vars(i).grid_sensors = false;
    % vars(i).marker = '-pentagram';
    % vars(i).off_grid = false;
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).interpolation_error = [];
    % vars(i).interpolation_type = 'linear';
    % vars(i).off_grid = false;
    % vars(i).r = 5;
    % vars(i).p = 32;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).sens_fig = [];

%% Zhao-DD
    % i = i+1;
    % vars(i).observer_type = "Zhao-DD";
    % vars(i).sensors = (1:32:N);
    % vars(i).basis_counter = 1;
    % vars(i).temp_basis_size = 100;
    % vars(i).marker = '-pentagram';
    % vars(i).temp_basis = [];
    % vars(i).grid_sensors = false;
    % vars(i).interpolation_error = [];
    % vars(i).interpolation_type = 'linear';
    % vars(i).error = NaN(1,p.num_timesteps);
    % vars(i).error_aot = vars(i).error;
    % vars(i).off_grid = false;
    % vars(i).r = 5;
    % vars(i).p = 32;
    % vars(i).main_fig = figure;
    % vars(i).main_fig.Position(3:4) = [1000 700];
    % vars(i).sens_fig = [];

end