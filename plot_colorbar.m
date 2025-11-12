clear; close all; clc;

% Create a figure
fig = figure;

set(gca, 'Visible', 'off');  % hide axes
colormap(brewermap([], "-RdBu"));
c = colorbar();
clim([-3.0880 3.0880])

% Add title
c.Title.String = '$u(x,t)$';
c.Title.Interpreter= "latex";
c.Position(3:4) = [0.0429    0.6292];
c.Ticks = [-2 0 2];
% Adjust axes so only colorbar is shown
% set(gca, 'Position', [0.05 0.35 0.9 0.3]);  
set(findall(gcf,'-property','Interpreter'),'Interpreter','latex') 
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
% Export as JPG
fontsize(120, "points")
% fontname("Latin Modern Roman")
% saveas(fig, 'colorbar_horizontal.jpg');

