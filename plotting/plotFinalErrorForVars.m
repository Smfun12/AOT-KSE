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
        semilogy(time_axis, vars(i).error_aot, vars(i).marker, 'LineWidth',3);
        hold off;
        xlabel("Time, $t$", "Interpreter","latex", "FontSize", 36)
        ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex", "FontSize",36)
    end
    legend(legends)
    fontsize(36, "points");
    
end