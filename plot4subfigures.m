clear; clc;
% Demo: 2x2 subplot figure using tiledlayout
% Creates a figure suitable for export to LaTeX/Overleaf

vars_1 = load("vars20250604_015023.mat");
vars_1 = vars_1.vars;

vars_2 = load("vars20250604_015133.mat");
vars_2 = vars_2.vars;
close all; 
% Create tiled layout (2 rows, 2 columns)
hfig = figure;
t = tiledlayout(2,2, 'TileSpacing', 'loose', 'Padding', 'loose');
p.dt = 0.01;
% First plot
nexttile;
time_axis = p.dt:p.dt:p.dt*length(vars_1.error_aot);
semilogy(time_axis(1:1:length(vars_1.error_aot)), vars_1.error_aot(1:1:length(vars_1.error_aot)), vars_1.marker, 'LineWidth', 2);
legend(vars_1.observer_type+ " sensors. $N=$"+ length(vars_1.sensors) + ", $\kappa=100$" + ".");
xlabel("Time, $t$")
ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$")

% Second plot
nexttile;
time_axis = p.dt:p.dt:p.dt*length(vars_2.error_aot);
semilogy(time_axis(1:1:length(vars_2.error_aot)), vars_2.error_aot(1:1:length(vars_2.error_aot)), vars_2.marker, 'LineWidth', 2);
legend(vars_2.observer_type+ " sensors. $N=$"+ length(vars_2.sensors) + ", $\kappa=100$" + ".");
xlabel("Time, $t$")
ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$")

% Third plot
nexttile;
time_axis = p.dt:p.dt:p.dt*length(vars_1.error_aot);
semilogy(time_axis(1:1:length(vars_1.error_aot)), vars_1.error_aot(1:1:length(vars_1.error_aot)), vars_1.marker, 'LineWidth', 2);
legend(vars_1.observer_type+ " sensors. $N=$"+ length(vars_1.sensors) + ", $\kappa=100$" + ".");
xlabel("Time, $t$")
ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$")

% Fourth plot
nexttile;
time_axis = p.dt:p.dt:p.dt*length(vars_2.error_aot);
semilogy(time_axis(1:1:length(vars_2.error_aot)), vars_2.error_aot(1:1:length(vars_2.error_aot)), vars_2.marker, 'LineWidth', 2);
legend(vars_2.observer_type+ " sensors. $N=$"+ length(vars_2.sensors) + ", $\kappa=100$" + ".");
xlabel("Time, $t$")
ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$")

fname = "myfigure";
    
picturewidth = 45; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',26) % adjust fontsize to your document

set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig,fname,'-dpdf','-vector','-fillpage')
print(hfig,fname,'-dpng','-vector')
% Export as vector PDF (best for LaTeX)
exportgraphics(hfig, 'trig_2x2.pdf', 'ContentType', 'vector');
