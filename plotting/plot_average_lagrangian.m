close all; clear; clc;
err = load("err.mat");
lagrange_info = load("lagrange_info.mat");
lagrange_info = lagrange_info.lagrange_info;

err = err.errors;

figure;
p.dt = 0.01;
number_of_trials = size(err, 1);
for i=1:number_of_trials
    % disp(i) 
    time_axis = p.dt:p.dt:p.dt*length(err);
    
    semilogy(time_axis, (err(i, :)), "--", 'LineWidth', 1);
    % plot(time_axis, log(err(i, :)), "--", 'LineWidth', 1, "Color","blue");
    hold on
end
err_avg = 1/number_of_trials * sum(log(err(1:number_of_trials, :)));
time_axis = p.dt:p.dt:p.dt*length(err);
h = plot(time_axis, exp(err_avg), "-o", 'LineWidth', 6, 'Color',"red");
xlabel("Time (simulated)", "Interpreter","latex")
ylabel("$L^2$ norm of $\epsilon$","Interpreter","latex")
legend(h, {"Lagrangian. $N =$" + lagrange_info(1) + ", $c = $" + lagrange_info(2) + "$\times u^*$. Average result."}, "Interpreter","latex")
set(gcf, 'Position', get(0, 'Screensize'));
yticks([1e-16 1e-8 1])
fontsize(84, "points")
set(findall(gcf,'-property','Interpreter'),'Interpreter','latex') 
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(findall(gcf,'-property','Box'),'Box','off') 
saveas(gcf, "plots/lagrangian/" + lagrange_info(1) + "_" + lagrange_info(2) + ".jpg")
