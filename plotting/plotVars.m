function [p] = plotVars(vars, p, u_hat)
    % set(gcf, 'Position', get(0, 'Screensize'));
    % for i=1:p.size_vars
    %     var = vars(i);
    %     set(0, 'CurrentFigure', var.main_fig);
    %     subplot(2,1,1)
    %     semilogy(p.dt:p.dt:p.dt*length(var.error), var.error);
    %     hold on;
    %     semilogy(p.dt:p.dt:p.dt*length(var.error_aot), var.error_aot, "LineWidth",3);
    %     hold off;
    %     title("Error plot. Type="+var.observer_type+", N=" + length(var.sensors));
    %     xlabel("Time")
    %     ylabel("Error")
    % 
    %     subplot(2,1,2);
    %     ref_solution = ifft(u_hat,'symmetric');
    %     % set(0, "CurrentFigure", figure(80));
    %     % set(gcf, 'Position', get(0, 'Screensize'));
    %     plot(p.x, ref_solution, "LineWidth",3);    
    %     hold on;
    %     xlabel("$X$", "Interpreter","latex")
    %     ylabel("$u(x, t)$", Interpreter="latex")
    %     title(sprintf('$t$ = %1.2f',p.t(p.ti)), "Interpreter","latex");
    %     axis([0, p.Lx, -3,3]);
    %     fontsize(48, "points")
    %     sensor_size = 300;
    %     F_temp = griddedInterpolant(p.x, ref_solution);
    %     legend_info = cell(1,p.size_vars+1);
    %     legend_info{1} = '';
    %     for i=1:p.size_vars
    %         var = vars(i);
    %         switch var.observer_type
    %             case {"Nonphysical Target Sensors" "Physical Target Sensors"}
    %                 scatter(var.sensors, .5+zeros(1, length(var.sensors)), sensor_size, 'blue', 'filled')
    %                 legend_info{i+1} = var.observer_type + "(#sensors=" + length(var.sensors) + ")";
    %                 scatter(var.target_sensors, zeros(length(var.target_sensors)), sensor_size, "red", "filled", "DisplayName", "Target Locations" + "(#sensors=" + length(var.target_sensors) + ")")
    %             case "Inertia"
    %                 % scatter(var.sensors, F_temp(var.sensors), sensor_size, var.color, 'filled', var.marker)
    %                 plot(var.sensors, F_temp(var.sensors), var.marker, "MarkerSize", 30, "MarkerFaceColor", var.color)
    %                 legend_info{i+1} = var.observer_type + "(\#sensors=" + length(var.sensors) + ", $St=$" + var.stokes_number + ")";
    %             case "Lagrangian"
    %                 plot(var.sensors, F_temp(var.sensors), var.marker,"MarkerSize", 30, "MarkerFaceColor", var.color)
    %                 legend_info{i+1} = var.observer_type + "(\#sensors=" + length(var.sensors) + ", $c=$" + var.amplitude + ")";
    %             case ""
    %                 scatter(var.sensors, F_temp(var.sensors), sensor_size, 'r', 'filled')
    %                 legend_info{i+1} = var.observer_type + "(#sensors=" + length(var.sensors) + ")";
    %         end
    % 
    %     end
    %     % if p.ti == p.show
    %     l = legend(legend_info, "Interpreter","latex");
    %     % l.FontSize = 30;
    %     drawnow;
    %     frame = getframe(gcf);
    %     p.im{p.ti} = frame2im(frame);
    %     hold off
    % end
    ref_solution = ifft(u_hat,'symmetric');
    set(0, "CurrentFigure", figure(80));
    set(gcf, 'Position', get(0, 'Screensize'));
    plot(p.x, (ref_solution ), "LineWidth", 6);    
    hold on;
    xlabel("$X$", "Interpreter","latex")
    ylabel("$u(x,t)$", Interpreter="latex")
    title(sprintf('$t$ = %1.2f',p.t(p.ti)), "Interpreter","latex");
    axis([0, p.Lx, -3,3]);
    fontsize(84, "points")
    sensor_size = 30;
    F_temp = griddedInterpolant(p.x, ref_solution);
    legend_info = cell(1,p.size_vars);
    legend_info{1} = '';
    height = [0.5, 0];
    for i=1:p.size_vars
        var = vars(i);
        switch var.observer_type
            case {"Target Sensors"}
                legend_info{i+1} = var.observer_type + ". $N = $" + length(var.sensors) + ", $v_p = $" + var.sensor_speed + "$\times u^*$.";
            case "Inertia"
                legend_info{i+1} = var.observer_type + ". $N = $" + length(var.sensors) + ", $St=$" + var.stokes_number + ".";
            case "Lagrangian"
                if var.amplitude == 0
                    legend_info{i+1} = var.observer_type + ". $N = $" + length(var.sensors) + ".";
                else
                    legend_info{i+1} = "$N = $" + length(var.sensors) + ", $c = $" + var.amplitude + ".";
                end
        end
        % plot(var.sensors, zeros(size(var.sensors)), var.marker,"MarkerSize", sensor_size, "MarkerFaceColor", var.color);
        % plot(var.sensors, F_temp(var.sensors), var.marker,"MarkerSize", sensor_size, "MarkerFaceColor", var.color);
        plot(var.sensors, height(i), var.marker,"MarkerSize", sensor_size, "MarkerFaceColor", var.color);

    end
    
    l = legend(legend_info, "Interpreter","latex", "Location","northeast");
    set(findall(gcf,'-property','Interpreter'),'Interpreter','latex') 
    set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    % set(findall(gcf,'-property','Box'),'Box','off') 
    fontsize(84, "points")
    l.FontSize = 36;
    frame = getframe(figure(80));
    p.im{p.ti} = frame2im(frame);
    drawnow;
    hold off
end