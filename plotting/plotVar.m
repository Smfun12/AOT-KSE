function [var] = plotVar(var, p, u_hat)
    
    set(0, 'CurrentFigure', var.main_fig);
    subplot(2,2,1)
    spec_aot = generate_spectrum_1D(var.aot_hat);
    spec = generate_spectrum_1D(u_hat);
    loglog(p.modes, spec_aot);
    hold on
    loglog(p.modes, spec);
    hold off
    legend("AOT spectrum", "Reference spectrum")
    title(sprintf('Energy spectrum at t = %1.2f',p.t(p.ti)));
    
    
    subplot(2,2,2)
    plot(p.x, ifft(var.aot_hat,'symmetric'));
    title(sprintf('AOT solution at t = %1.2f',p.t(p.ti)));
    axis([0, p.Lx, -3,3]);
    
    subplot(2,2,3)
    semilogy(p.dt:p.dt:p.dt*length(var.error), var.error);
    hold on;
    semilogy(p.dt:p.dt:p.dt*length(var.error_aot), var.error_aot);
    hold off;
    title("Error plot. Type="+var.observer_type+", N=" + length(var.sensors));
    xlabel("Time")
    ylabel("Error")

    subplot(2,2,4);
    if p.ti == p.show
        var.sens_fig = figure(80);
        set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    else
        set(0 ,"CurrentFigure", var.sens_fig)
    end

    ref_solution = ifft(u_hat,'symmetric');
    plot(p.x, ref_solution, "LineWidth",2, "DisplayName", "Ground-truth solution");
    hold on;
    % plot(p.Lx+p.x, ref_solution, "LineWidth",2, "DisplayName", "Ground-truth solution");
    % aot_obs = interpolate_observations(p, ref_solution, p.x(var.sensors), var);
    % plot(p.x, aot_obs, "LineWidth",2, "Color", [0.9290 0.6940 0.1250], "Marker","x", "DisplayName", "Intepolated solution");

    sensor_size = 100;
    if var.off_grid 
        
        if contains(var.observer_type, "Target")
            scatter(var.sensors, .5+zeros(1, length(var.sensors)), sensor_size, 'blue', 'filled', "DisplayName", var.observer_type + "(#sensors=" + length(var.sensors) + ", frequency=" + var.targets_frequency + ")")
            % scatter(p.x(1:10:p.N), zeros(length(p.x(1:10:p.N))), 100, 'blue', 'filled', "DisplayName", "Uniform(103)")
            scatter(var.target_sensors, zeros(length(var.target_sensors)), sensor_size, "red", "filled", "DisplayName", "Target Locations" + "(#sensors=" + length(var.target_sensors) + ")")
            % scatter(var.target_sensors(1), .5, 100, "filled", "green")
            % scatter(p.Lx+var.target_sensors, .5+zeros(length(var.target_sensors)), sensor_size, "red", "filled", "DisplayName", "Target Locations" + "(#sensors=" + length(var.target_sensors) + ")")
            % scatter(p.Lx+var.target_sensors(1), .5, 100, "filled", "green")
            legendUnq();
            legend;
            % legend(["", var.observer_type + "(#sensors=" + length(var.sensors) + ")", "Target locations"])
        else
            scatter(var.sensors, zeros(length(var.sensors)), sensor_size, 'r', 'filled', "DisplayName", var.observer_type + "(#sensors=" + length(var.sensors) + ", amplitude=" + var.amplitude + "%)")
            legendUnq();
            legend;
        end
    else
        if contains(var.observer_type, "Target")
            scatter(p.x(var.sensors), zeros(length(var.sensors)), sensor_size, 'blue', 'filled', "DisplayName", var.observer_type + "(#sensors=" + length(var.sensors) + ", frequency=" + var.targets_frequency + ")")
            scatter(p.x(1:10:p.N), zeros(length(p.x(1:10:p.N))), sensor_size, 'red', 'filled', "DisplayName", "Uniform(103)")
            % scatter(var.target_sensors, zeros(length(var.target_sensors)), 200, "red", "filled", "DisplayName", "Target Locations")
            legendUnq();
            legend;
            % legend(["", var.observer_type + "(#sensors=" + length(var.sensors) + ")", "Target locations"])
        else
            scatter(p.x(var.sensors), zeros(length(var.sensors)), 'r', 'filled')
        end
        
    end
    
    
    hold off;
    title(sprintf('Reference solution at t = %1.2f',p.t(p.ti)));
    axis([0, p.Lx, -3,3]);
    fontsize(var.sens_fig, 26, "points")
    if contains(var.observer_type, "Lagrangian")
        legend(["", var.observer_type + "(#sensors=" + length(var.sensors) + ", a=" + var.amplitude + ")"])
    end
    drawnow;
    frame = getframe(var.sens_fig);
    var.im{p.ti} = frame2im(frame);
    % pause(0.5);
end


function [vq1, bsv_data] = interpolate_observations(p, ref_solution, spatial_sensors, var)
    F_temp = griddedInterpolant(p.x, ref_solution, var.interpolation_type);
    bsv_data = F_temp(spatial_sensors);
    
    closest_points = zeros(size(spatial_sensors));
    % Loop through each point
    for i = 1:length(spatial_sensors)
        % Compute the absolute distance to all grid points
        [~, idx] = min(abs(p.x - spatial_sensors(i)));
        % Find the closest grid point
        closest_points(i) = ref_solution(idx);
    end

    

    x_pts = spatial_sensors';
    
    %Copy data at rightmost sensor and leftmost sensor to extend periodically
    u_data1 = [bsv_data(end),bsv_data, bsv_data(1) ];

    x_pts_per = x_pts;
    %Add sensors closest to end of domain periodically
    x_pts_per = [x_pts_per(end) - p.Lx; x_pts_per; x_pts_per(1) + p.Lx];

    % Note that x_pts has been sorted, so x_pts(1) is the left most sensor,
    % and x_pts(end) is the right most sensor.
    F1 = griddedInterpolant(x_pts_per, u_data1.');
    vq1 = F1(p.x);
end
function unqLegHands = legendUnq(h, sortType)
% unqLegHands = legendUnq(h, sortType)
%   Run this function just before running 'legend()' to avoid representing duplicate or missing
% DisplayNames within the legend. This solves the problem of having a cluttered legend with 
% duplicate or generic values such as "data1" assigned by matalab's legend() function.  This 
% also makes is incredibly easy to assign one legend to a figure with multiple subplots. 
% Use the 'DisplayName' property in your plots and input the axis handle or the figure handle 
% so this code can search for all potential legend elements, find duplicate DisplayName strings, 
% and remove redundent components by setting their IconDisplayStyle to 'off'.  Then call 
% legend(unqLegHands) to display unique legend components. 
% INTPUT
%       h: (optional) either a handle to a figure, an axis, or a vector of axis handles. The code 
%           will search for plot elements in all axes belonging to h.  If h is missing, gca is used.
%       sort: (optional) can be one of the following strings that will sort the unqLeghands.
%           'alpha': alphabetical order. 
% OUTPUT
%       unqLegHands: a list of handles that have unique DisplayNames; class 'matlab.graphics.chart.primitive.Line'.
%           ie: unqLegHands = legendUnq(figHandle); legend(unqLegHands)
% EXAMPLE 1: 
%         figure; axis; hold on
%         for i=1:10
%             plot(i,rand(), 'ko', 'DisplayName', 'randVal1');        % included in legend
%             plot(i+.33, rand(), 'ro', 'DisplayName', 'randVal2');   % included in legend       
%         end
%         plot(rand(1,10), 'b-'); 	% no DisplayName so it is absent from legend
%         legend(legendUnq())
% EXAMPLE 2: 
%         fh = figure; subplot(2,2,1); hold on
%         plot(1:10, rand(1,10), 'b-o', 'DisplayName', 'plot1 val1')
%         plot(1:2:10, rand(1,5), 'r-*', 'DisplayName', 'plot1 val2')
%         subplot(2,2,2); hold on
%         plot(1:10, rand(1,10), 'm-o', 'DisplayName', 'plot2 val1')
%         plot(1:2:10, rand(1,5), 'g-*', 'DisplayName', 'plot2 val2')
%         subplot(2,2,3); hold on
%         plot(1:10, rand(1,10), 'c-o', 'DisplayName', 'plot3 val1')
%         plot(1:2:10, rand(1,5), 'k-*', 'DisplayName', 'plot3 val2')
%         lh = legend(legendUnq(fh)); 
%         lh.Position = [.6 .2 .17 .21];
%
% Danz 180515
% Change history
% 180912 fixed error when plot is empty
% 180913 adapted use of undocumented function for matlab 2018b
persistent useOldMethod
% If handle isn't specified, choose current axes
if nargin == 0
    h = gca; 
end
% If user entered a figure handle, replace with a list of children axes; preserve order of axes
if strcmp(get(h, 'type'), 'figure')
    h = flipud(findall(h, 'type', 'Axes')); 
end
% set flag to use old method of obtaining legend children
% In 2018b matlab changed an undocumented function that obtains legend handles. 
useOldMethod = verLessThan('matlab', '9.5.0'); 
% Set the correct undocumented function 
if useOldMethod
    getLegendChildren = @(x) graph2dhelper('get_legendable_children', x);
else
    getLegendChildren = @(x) matlab.graphics.illustration.internal.getLegendableChildren(x);
end
% Get all objects that will be assigned to legend.
% This uses an undocumented function that the legend() func uses to get legend componenets.
legChildren = matlab.graphics.chart.primitive.Line; %initializing class (unsure of a better way)
for i = 1:length(h)
    temp = getLegendChildren(h(i));
    if ~isempty(temp)
        legChildren(end+1:end+length(temp),1) = temp; 
    end
end
legChildren(1) = [];
% Get display names
dispNames = get(legChildren, 'DisplayName');
if isempty(dispNames)
    dispNames = {''}; 
end
if ~iscell(dispNames)
    dispNames = {dispNames}; 
end
% Find the first occurance of each name 
[~, firstIdx] = unique(dispNames, 'first'); 
% Create an index of legend items that will be hidden from legend
legRmIdx = true(size(legChildren)); 
legRmIdx(firstIdx) = false; 
% Add any elements that have no displayName to removal index (legend would assign them 'dataX')
legRmIdx = legRmIdx | cellfun(@isempty,dispNames);
% get all annotations
annot = get(legChildren, 'Annotation'); 
% Loop through all items to be hidden and turn off IconDisplayStyle
for i = 1:length(annot)
    if legRmIdx(i)
        set(get(annot{i}, 'LegendInformation'), 'IconDisplayStyle', 'off');
    end
end
% Output remaining, handles to unique legend entries
unqLegHands = legChildren(~legRmIdx); 
% Sort, if user requested
if nargin > 1 && ~isempty(sortType) && length(unqLegHands)>1
    [~, sortIdx] = sort(get(unqLegHands, 'DisplayName'));
    unqLegHands = unqLegHands(sortIdx); 
end
end