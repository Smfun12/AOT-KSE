function plotSensorTrajectoryInXTPlane(p, var)
    figure(23);
    hold on
    colors = distinguishable_colors(length(var.sensors));
    for i=1:size(var.sensor_history, 2)
        sensor_trajectory = zeros(1, size(var.sensor_history, 1));
        for j=1:size(var.sensor_history, 1)
            if j >= 2
                dx = abs(var.sensor_history(j, i) - var.sensor_history(j-1, i));
            else
                dx = 0;
            end
            if dx < p.Lx/2
                sensor_trajectory(j) = var.sensor_history(j, i);
            else
                sensor_trajectory(j) = NaN;
            end
        end
        plot3([0, p.t], sensor_trajectory, -5*ones(size(sensor_trajectory)), "LineWidth",10, "Color",[colors(i, :)]);
    end
    ylabel('$x$');
    xlabel('$t$');
    fontsize(64, "points")
    set(findall(gcf,'-property','Interpreter'),'Interpreter','latex') 
    set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    box on
    set(gca, 'Layer', 'top')
    ax = gca;
    ax.XMinorTick = 'on';
    ax.YMinorTick = 'on';
    colormap(brewermap([], '-RdBu'))
    set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 16 9])
end