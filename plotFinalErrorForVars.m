function plotFinalErrorForVars(vars, p)
    legends = [];
    figure;
    for i=1:p.size_vars
        if contains(vars(i).observer_type, "Lagrangian")
            legends = [legends, vars(i).observer_type+ "("+ length(vars(i).sensors) + ", " + vars(i).amplitude + ")"];
        else
            legends = [legends, vars(i).observer_type+ "("+ length(vars(i).sensors) + ")"];
        end
        if i > 1
            hold on;
        end
        semilogy(p.dt:p.dt:p.dt*length(vars(i).error_aot), vars(i).error_aot, vars(i).marker, 'LineWidth',2);
        hold off;
        title("Error computed over time");
        xlabel("Time", "FontSize", 48)
        ylabel("Error", "FontSize",48)
    end
    legend(legends)
    fontsize(48, "points");
end