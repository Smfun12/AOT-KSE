function plotFinalErrorForVars(vars, p)
    hfig = figure;
    legendInfo = cell(1, p.size_vars);
    for i=1:p.size_vars
        legendInfo{i} = vars(i).observer_type+ " sensors. $N=$"+ length(vars(i).sensors);
        switch vars(i).observer_type
            case "Lagrangian"
                if vars(i).amplitude == 0
                    legendInfo{i} = "Lagrangian";
                else
                    legendInfo{i} = "Perb. Lagrangian, $c=$" + vars(i).amplitude;
                end
            case "Inertia"
                if vars(i).amplitude == 0
                    legendInfo{i} = "Inertia $St = $" + vars(i).stokes_number;
                else
                    legendInfo{i} =  "Perb. Inertia, $St = $" + vars(i).stokes_number + ", $c = $" + vars(i).amplitude;
                end
            case {"Target Sensors"}
                legendInfo{i} = "Directed, $v_p = $" + vars(i).sensor_speed;
            case {"Forward Sensors"}
                legendInfo{i} ="Forward Sensors. $N = $"+ length(vars(i).sensors) + ", $v_p = $" + vars(i).sensor_speed + "$\times u^*$";
        end
        time_axis = p.dt:p.dt:p.dt*length(vars(i).error_aot);
        semilogy(time_axis(1:1:length(vars(i).error_aot)), vars(i).error_aot(1:1:length(vars(i).error_aot)), '-', 'LineWidth', 10);
        if i == 1
            hold on
        end
        if p.prod
            xlabel("Time (simulated)", "Interpreter","latex")
            ylabel("$L^2$ norm of $\epsilon$","Interpreter","latex")
        else
            xlabel("Time, $t$", "Interpreter","latex", "FontSize", 36)
            ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",36)
        end
    end
    l = legend(legendInfo, "Interpreter", "latex");
    % 0.49,0.18,0.56
    if p.prod
        fontsize(84, "points");
    else
        fontsize(36, "points");
    end
    l.Location = 'Best';
    l.Box = "on";
    l.FontSize = 82;
    yticks([1e-16 1e-8 1e0])
    set(findall(gcf,'-property','Interpreter'),'Interpreter','latex') 
    set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    set(findall(gcf,'-property','Box'),'Box','off') 
    % set(gca, 'XTick', [], 'XTickLabel', [], 'XLabel', []);
    % set(gca, 'YTick', [], 'YTickLabel', [], 'YLabel', []);
end