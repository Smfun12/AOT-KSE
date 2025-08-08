function plotFinalErrorForVars(vars, p)
    hfig = figure;
    legendInfo = cell(1, p.size_vars);
    for i=1:p.size_vars
        legendInfo{i} = vars(i).observer_type+ " sensors. $N=$"+ length(vars(i).sensors) + ".";
        switch vars(i).observer_type
            case "Lagrangian"
                if vars(i).amplitude == 0
                    legendInfo{i} = "$N=$"+ length(vars(i).sensors) + ".";
                else
                    legendInfo{i} = "$c=$" + vars(i).amplitude + "$\times u^*$.";
                end
            case "Inertia"
                if vars(i).amplitude == 0
                    legendInfo{i} = "$St = $" + vars(i).stokes_number + ".";
                else
                    legendInfo{i} =  "$St = $" + vars(i).stokes_number + ", $c = $" + vars(i).amplitude + "$\times u^*$.";
                end
            case {"Target Sensors"}
                legendInfo{i} = "$v_p = $" + vars(i).sensor_speed + "$\times u^*$.";
            case {"Forward Sensors"}
                legendInfo{i} ="Forward Sensors. $N = $"+ length(vars(i).sensors) + ", $v_p = $" + vars(i).sensor_speed + "$\times u^*$.";
        end
        time_axis = p.dt:p.dt:p.dt*length(vars(i).error_aot);
        semilogy(time_axis(1:1:length(vars(i).error_aot)), vars(i).error_aot(1:1:length(vars(i).error_aot)), vars(i).marker, 'LineWidth', 4);
        if i == 1
            hold on
        end
        if p.prod
            xlabel("Time (simulated)", "Interpreter","latex")
            ylabel("Error $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex")
        else
            xlabel("Time, $t$", "Interpreter","latex", "FontSize", 36)
            ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",36)
        end
    end
    l = legend(legendInfo, "Interpreter", "latex");
    
    if p.prod
        fontsize(84, "points");
    else
        fontsize(36, "points");
    end
    l.Location = 'Best';
    set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
    set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    set(findall(gcf,'-property','Box'),'Box','off') 
    % set(gca, 'XTick', [], 'XTickLabel', []);
    % set(gca, 'YTick', [], 'YTickLabel', []);
end