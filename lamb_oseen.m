clear; clc; close all;
addpath('./brewer/')
load("big_basis_lamb_oseen.mat")
r=-3.1:0.09:3.1;
% Choices: [perodic, inside, leave]
choice = "periodic";

[x,y]=meshgrid(r);

tMax = 0.3;
dt = 0.001;

mu = 0.25;
optimal_x = [];
optimal_y = [];
lagrangian_path = [];

idx = 23;
idxy = 23;
x_pos = x(idx, idxy);
y_pos = y(idx, idxy);
counter = 1;
start_idx = 1;
step = 25;
end_idx = step;
sns = 25;
r = step;
% lagrangian_sensors = [LagrangianSensor(x_pos, y_pos, [],'r',idx, idxy)];
lagrangian_sensors = [];
accumulator = 1;
lagrangian_error = [];
optimal_error = [];
simulation = figure(1);
recovery = figure(2);
for t = 0:dt:tMax
   
    % Test case

    K1 = 700; % strength of the vortex
    K2 = -15; % speed of the vortex
    offset_x = 0;
    offset_y = 2;

    offset_x_2 = 2;
    offset_y_2 = 0; 


    % offset_x_3 = 2;
    % offset_y_3 = -2; 

        
    
    
    rr=((x +offset_x).^2+(y-offset_y-(K2*t)).^2)*10;
    rr2=((x + offset_x_2+ K2*t).^2+(y+offset_y_2).^2)*10;
    
    % Vertical down
    U = -K1*(y-offset_y-(K2*t))./(rr).*(1-exp((-rr)/(4*mu)))-K1*(y-offset_y_2)./(rr2).*(1-exp((-rr2)/(4*mu)));
    V = K1*(x +offset_x)./(rr).*(1-exp((-rr)/(4*mu)))+K1*(x +offset_x_2+(K2*t))./(rr2).*(1-exp((-rr2)/(4*mu)));
    
    u = reshape(U, [], 1);
    v = reshape(V, [], 1);

    
    set(0, "CurrentFigure", simulation)
    quiver(x,y, U, V , "b" ) ;
    hold on
    
    for j=1:length(lagrangian_sensors)
    
        x_pos = lagrangian_sensors(j).x;
        y_pos = lagrangian_sensors(j).y;
        plot(x_pos, y_pos, '.', 'Color', 'r', 'MarkerSize', 10);
    end
    
    if counter == fix(end_idx)
        bigs = size(big_basis);
        
        start_idx = min(bigs(2)-step, start_idx + step);
        end_idx = min(bigs(2), end_idx + step);
    end
    
    [Psi,~, ~] = svd(big_basis(:, start_idx:end_idx), "econ");

    [optimal_loc_x, optimal_loc_y, xs, ys] = data_reconstruction(x,y, [u.*v], Psi, r, sns, recovery);   
    set(0, "CurrentFigure", simulation)
    plot(xs,-ys, '.', 'Color','black', 'MarkerSize', 10)
    set(0, "CurrentFigure", simulation)
    counter = counter + 1;
    if counter == 2
        x_pos = xs;
        y_pos = ys;

        for j=1:length(xs)
            lagrangian_sensors = [lagrangian_sensors, LagrangianSensor(xs(j), -ys(j), [], 'r', optimal_loc_x(j), optimal_loc_y(j))];
            plot(xs(j), -ys(j), '.', 'Color', 'r', 'MarkerSize', 10);
        end
    end
    optimal_x = [optimal_x; optimal_loc_x];
    optimal_y = [optimal_y; optimal_loc_y];


    for j=1:length(lagrangian_sensors)
        x_pos = lagrangian_sensors(j).x;
        y_pos = lagrangian_sensors(j).y;
        idx = lagrangian_sensors(j).idx;
        idxy = lagrangian_sensors(j).idxy;
        
        x_pos = max(-3.1, min(3.1, x_pos + U(idx, idxy)*dt));
        y_pos = min(3.1, max(-3.1, y_pos + V(idx, idxy)*dt));

        givenPoint = [x_pos; y_pos];

        % Calculate Euclidean distances
        distances = sqrt((x - givenPoint(1)).^2 + (y - givenPoint(2)).^2);

        % Find the indices of the minimum distance
        [minDist, minIdx] = min(distances(:));

        % Convert linear index to subscripts
        [minRow, minCol] = ind2sub(size(distances), minIdx);
        lagrangian_sensors(j).idx = minRow;
        lagrangian_sensors(j).idxy = minCol;
        paths = lagrangian_sensors(j).path;
        paths = [paths, [lagrangian_sensors(j).x; lagrangian_sensors(j).y]];
        lagrangian_sensors(j).path = paths;
        lagrangian_sensors(j).x = x_pos;
        lagrangian_sensors(j).y = y_pos;
    end
    
    % calculateLagrangeError(lagrangian_sensors)
    % calculateOptimalError(optimal_loc_x, optimal_loc_x, [u;v])

    hold off
    axis([-3 3 -3 3]);
    axis equal ;

    title(['Vorticity Contours of Lamb-Oseen Vortex at t = ', num2str(t)]);
    xlabel('x');
    ylabel('y');
    drawnow;
end

figure(1)
quiver(x,y, U, V , "b" ) ;
title(['Vorticity Contours of Lamb-Oseen Vortex at t = ', num2str(t)]);
xlabel('x');
ylabel('y');

%% Plot optimal sensors
figure(3)
quiver(x,y, U, V , "b" ) ;
title("Optimal path");
xlabel('x');
ylabel('y');
hold on
xs = [];
ys = [];
for i=1:length(optimal_x)
    x1 = x(optimal_x(i), optimal_x(i));
    y1 = y(optimal_y(i), optimal_y(i));
    xs = [xs, x1];
    ys = [ys, y1];
    % scatter(x(optimal_x(i), optimal_x(i)), y(optimal_y(i), optimal_y(i)), 50, darkColor, 'filled')
        % if i <= length(optimal_x) && i > 1
        %     x1 = x(optimal_x(i-1),optimal_x(i-1));
        %     y1 = y(optimal_y(i-1),optimal_y(i-1));
        % 
        %     x2 = x(optimal_x(i), optimal_x(i));
        %     y2 = y(optimal_y(i), optimal_y(i));
        % 
        %     dx = x2 - x1;
        %     dy = y2 - y1;
        %     optimal_path = quiver(x1, y1, dx, dy, 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 2);
        % end
end
scatter(xs, ys, 20, 1:length(xs), 'filled');
colormap(brewermap([], 'PuOr'))
c = colorbar;
c.Label.String = 'Time step';
ticklabels = linspace(0, 0.25, length(c.Ticks));
ticklabels = arrayfun(@(value) sprintf('%.2f', value), ticklabels, 'UniformOutput', false);
c.TickLabels = ticklabels;
hold off;

%% Plot lagrangian sensors
figure(4)
quiver(x,y, U, V , "b" ) ;
title("Lagrangian path");
xlabel('x');
ylabel('y');
hold on
for j=1:length(lagrangian_sensors)
    lagrangian_path = lagrangian_sensors(j).path;
    color = lagrangian_sensors(j).color;
    xs = [];
    ys = [];
    for i=1:length(lagrangian_path)
        point = lagrangian_path(:, i);
        x1 = point(1);
        y1 = point(2);
        xs = [xs, x1];
        ys = [ys, y1];
    end
    scatter(xs, ys, 20, 1:length(xs), 'filled');
    colormap(brewermap([], 'YlOrBr'))
    % for i=1:length(lagrangian_path)-1
    % 
    %         point = lagrangian_path(:, i);
    %         x1 = point(1);
    %         y1 = point(2);
    % 
    %         point_2 = lagrangian_path(:, i+1);
    % 
    %         x2 = point_2(1);
    %         y2 = point_2(2);
    % 
    %         dx = x2 - x1;
    %         dy = y2 - y1;
    %         lagr_path = quiver(x1, y1, dx, dy, 'Color', 'cyan', 'LineWidth', 2);
    % end
end
c = colorbar;
c.Label.String = 'Time step';
ticklabels = linspace(0, 0.25, length(c.Ticks));
ticklabels = arrayfun(@(value) sprintf('%.2f', value), ticklabels, 'UniformOutput', false);
c.TickLabels = ticklabels;
% legend([lagr_path, optimal_path], {'Lagr', 'Opt'})
% hold off


%% 2D example
function [row, col, xs, ys] = data_reconstruction(X,Y,x_input_orig, Psi, r, sns, recovery)
    N = length(X);
   
    x_input = reshape(x_input_orig, [] ,1);

    % [Psi, ~, ~] = svd(Psi, 'econ');
    if sns <= r
        [~, ~, pivot] =  qr(Psi(:,1:r)','vector');
        sensors = pivot(1:sns);
    else
        [~, ~, pivot] =  qr(Psi(:, 1:r)*Psi(:, 1:r)','vector');
        sensors = pivot(1:sns);
    end
    % [~, ~, pivot] =  qr(Psi(:,1:r)','vector');
    
    Theta = Psi(sensors, 1:r);

    % Y vector
    y = x_input(sensors);
    % Finding a
    a = pinv(Theta) * y;
    xrecon = Psi(:,1:r)*a;
    set(0, "CurrentFigure", recovery)
    subplot(2,1,1)
    plot(x_input_orig)
    title("Original signal.")
    subplot(2,1,2)
    plot(xrecon)
    title("Reconstructed signal.")

    hold on
    for i=1:length(sensors)
        plot(sensors(i), 0, 'o', 'MarkerSize', 5, 'MarkerFaceColor', 'red');
    end
    hold off
    points = zeros(size(x_input));
    % For selecting row and column regardless of its value
    measurements = x_input(sensors);
    measurements(measurements == 0) = -1;
    points(sensors) = measurements;
    points2d = reshape(points, N,N);
    [col, row] = find(points2d ~= 0);
    % figure(1);
    xs = X(row, row);
    xs = xs(1, :);
    ys = Y(col, col);
    ys = -ys(:, 1);
    % plot(xs,ys, '.', 'Color','black', 'MarkerSize', 10)
end