function plotFinalErrorForVars(vars, p)
    hfig = figure;
    % hold on
    legendInfo = cell(1, p.size_vars);
    for i=1:p.size_vars
        legendInfo{i} = vars(i).observer_type+ " sensors. $N=$"+ length(vars(i).sensors) + ".";
        switch vars(i).observer_type
            case "Lagrangian"
                legendInfo{i} = vars(i).observer_type+ " sensors. $N=$"+ length(vars(i).sensors) + ", $c=$" + vars(i).amplitude + "$\times u^*$.";
                % legendInfo{i} = vars(i).observer_type+ " sensors. $N=$"+ length(vars(i).sensors) + ".";
            case "Inertia"
                % legendInfo{i} = vars(i).observer_type+ " sensors. $N=$"+ length(vars(i).sensors) + ", $St=$" + vars(i).stokes_number + ", $c = $" + vars(i).amplitude + "$\times u^*$.";
                % legendInfo{i} = vars(i).observer_type + ", $St = $" + vars(i).stokes_number + ", $c = $" + vars(i).amplitude + ".";
                legendInfo{i} = vars(i).observer_type + ". $N = $" + length(vars(i).sensors) + ", $St = $" + vars(i).stokes_number + ".";
            case {"Target Sensors"}
                % legendInfo{i} = vars(i).observer_type+ ", algorithm " + vars(i).alg + ". $N=$"+ length(vars(i).sensors) + ".";
                legendInfo{i} ="Target sensors. $N = $"+ length(vars(i).sensors) + ", $v_p = $" + vars(i).sensor_speed + "$\times u^*$.";
            case {"Forward Sensors"}
                % legendInfo{i} = vars(i).observer_type+ ", algorithm " + vars(i).alg + ". $N=$"+ length(vars(i).sensors) + ".";
                legendInfo{i} ="Forward Sensors. $N = $"+ length(vars(i).sensors) + ", $v_p = $" + vars(i).sensor_speed + "$\times u^*$.";
        end
        time_axis = p.dt:p.dt:p.dt*length(vars(i).error_aot);
        semilogy(time_axis(1:1:length(vars(i).error_aot)), vars(i).error_aot(1:1:length(vars(i).error_aot)), vars(i).marker, 'LineWidth', 4);
        if i == 1
            hold on
        end
        if p.prod
            xlabel("Time, $t$", "Interpreter","latex", "FontSize", 48)
            ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",48)
        else
            xlabel("Time, $t$", "Interpreter","latex", "FontSize", 36)
            ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",36)
        end
    end
    l = legend(legendInfo, "Interpreter", "latex");
    l.Location = 'Best';
    if p.prod
        fontsize(48, "points");
    else
        fontsize(36, "points");
    end
    l.FontSize = 48;
    set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
    set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    % figure(2)
    % plot(p.x, p.soln_history(:, end), "LineWidth", 3)
    % hold on
    % xlabel("$X$", "Interpreter","latex")
    % ylabel("$u(x, t)$", Interpreter="latex")
    % title(sprintf('$t$ = %1.2f',p.t(p.ti)), "Interpreter","latex");
    % axis([0, p.Lx, -3,3]);
    % fontsize(48, "points")
    % ref_solution = p.soln_history(:, end);
    % F_temp = griddedInterpolant(p.x, ref_solution);
    % plot(vars(1).sensors, F_temp(vars(1).sensors), vars(1).marker, "MarkerSize", 30, "MarkerFaceColor", vars(1).color)
    % legend(["", vars(1).observer_type + "(\#sensors=" + length(vars(1).sensors) + ", $St=$" + vars(1).stokes_number + ")"], "Interpreter", "latex")
    
    
    % plotAndSaveFigure(hfig)
    % set(gcf, 'Position', get(0, 'Screensize'));
    % filename_error = "all_" + length(vars(1).sensors) + "_mu_" + p.mu;
    % filename_error = replace(filename_error, ".", ",");
    % savefig(gcf, "/Users/oleksandr/Documents/AOT_clean/KSE/plots/all/" + filename_error)
    % saveas(gcf, "/Users/oleksandr/Documents/AOT_clean/KSE/plots/all/" + filename_error + ".jpg")

end