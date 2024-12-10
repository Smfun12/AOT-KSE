function plotFinalErrorForVars(vars, p)
    legends = [];
    figure;
    for i=1:p.size_vars
        if contains(vars(i).observer_type, "Lagrangian")
            legends = [legends, vars(i).observer_type+ "("+ length(vars(i).sensors) + ", " + vars(i).amplitude + ")"];
        elseif contains(vars(i).observer_type, "Target")
            legends = [legends, vars(i).observer_type+ "("+ length(vars(i).sensors) + ", " + "offgrid=" + vars(i).target_off_grid  + ")"];
        else
            legends = [legends, vars(i).observer_type+ "("+ length(vars(i).sensors) + ", " + "offgrid=" + vars(i).off_grid  + ",interpolation=" + vars(i).interpolation_type + ")"];
        end
        if i > 1
            hold on;
        end
        semilogy(p.dt:p.dt:p.dt*length(vars(i).error_aot), vars(i).error_aot, vars(i).marker, 'LineWidth',2);
        hold off;
        % title("Error computed over time");
        if p.prod
            xlabel("$t$, Time", "Interpreter","latex", "FontSize", 48)
            ylabel("$\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",48)
        else
            xlabel("$t$, Time", "Interpreter","latex", "FontSize", 36)
            ylabel("$\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",36)
        end
    end
    legend(legends)
    if p.prod
        fontsize(48, "points");
    else
        fontsize(36, "points");
    end
    figure;
    semilogy(1:p.ti, vars(1).interpolation_error, vars(1).marker, "LineWidth",3)
    hold on
    semilogy(1:p.ti, vars(2).interpolation_error, vars(2).marker, "LineWidth",3)
    xlabel("$t$, Time", Interpreter="latex", FontSize=36)
    ylabel("$\epsilon$ ,Interpolation error", "Interpreter","latex", "FontSize",36)
    legends = ["Type: " + vars(1).interpolation_type, "Type: " + vars(2).interpolation_type];
    legend(legends)
end