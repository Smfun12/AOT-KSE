function plotFinalErrorForVars(vars, p)
    legends = [];
    figure;
    for i=1:p.size_vars
        if contains(vars(i).observer_type, "Lagrangian")
            legends = [legends, vars(i).observer_type+ "(#sensors="+ length(vars(i).sensors) + ", a=" + vars(i).amplitude + ")"];
        elseif contains(vars(i).observer_type, "Target")
            legends = [legends, vars(i).observer_type+ "("+ length(vars(i).sensors) + ", " + "frequency=" + vars(i).targets_frequency  + ",interpolation=" + vars(i).interpolation_type + ")"];
        else
            legends = [legends, vars(i).observer_type+ "("+ length(vars(i).sensors) + ", " + "offgrid=" + vars(i).off_grid  + ",interpolation=" + vars(i).interpolation_type + ")"];
        end
        if i > 1
            hold on;
        end
        time_axis = p.dt:p.dt:p.dt*length(vars(i).error_aot);
        semilogy(time_axis(1:100:length(vars(i).error_aot)), vars(i).error_aot(1:100:length(vars(i).error_aot)), vars(i).marker, 'LineWidth',3);
        hold off;
        % title("Error computed over time");
        if p.prod
            xlabel("Time, $t$", "Interpreter","latex", "FontSize", 48)
            ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",48)
        else
            xlabel("Time, $t$", "Interpreter","latex", "FontSize", 36)
            ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",36)
        end
    end
    legend(legends)
    % ylim([10^(-16), 10^2])
    if p.prod
        fontsize(48, "points");
    else
        fontsize(36, "points");
    end
    if p.show_interpolation_error
        figure;
        legends = [];
        for i=1:p.size_vars
            vars(i).interpolation_error(vars(i).interpolation_error == 0) = 1e-15;
            time_axis = p.dt:p.dt:p.dt*length(vars(i).interpolation_error);
            semilogy(time_axis, vars(i).interpolation_error, vars(i).marker, "LineWidth",3)
            hold on
            legends = [legends, vars(i).observer_type + "(" + length(vars(i).sensors)+ ", offgrid=" + vars(i).off_grid + ", interpolation="+ vars(i).interpolation_type + ")"];
    
        end
        xlabel("Time, $t$", Interpreter="latex", FontSize=36)
        ylabel("AOT error, $\epsilon$ ,Interpolation error", "Interpreter","latex", "FontSize",36)
        legend(legends)
        set(gca, "FontSize", 26)
    end
    
end