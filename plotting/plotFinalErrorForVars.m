function plotFinalErrorForVars(vars, p)
    hfig = figure;
    legendInfo = cell(1, p.size_vars);
    for i=1:p.size_vars
        switch vars(i).observer_type
            case "Lagrangian"
                if vars(i).amplitude == 0
                    legendInfo{i} = "Lagrangian.";
                else
                    legendInfo{i} = "Perturbed Lagrangian, $c=" + vars(i).amplitude + "\times u^*$.";
                end
            case "Inertia"
                if vars(i).amplitude == 0
                    legendInfo{i} = "Pseudo-Lagrangian, $St = $" + vars(i).stokes_number + ".";
                else
                    legendInfo{i} =  "Perturbed Pseudo-Lagragian, $St = " + vars(i).stokes_number + ",c = " + vars(i).amplitude + "\times u^*$.";
                end
            case {"Directed"}
                legendInfo{i} = "Directed, $v_p \approx " + vars(i).sensor_speed + "\times u^*$.";
            case {"Forward Sensors"}
                legendInfo{i} ="Forward Sensors, $v_p = " + vars(i).sensor_speed + "$\times u^*$.";
        end
        time_axis = p.dt:p.dt:p.dt*length(vars(i).error_aot);
        semilogy(time_axis(1:1:length(vars(i).error_aot)), vars(i).error_aot(1:1:length(vars(i).error_aot)), vars(i).marker, 'LineWidth', 4);
        if i == 1
            hold on
        end
    end
    xlabel("Time (simulated)", "Interpreter","latex")
    ylabel("$||\epsilon||_{L^2}$","Interpreter","latex")
    l = legend(legendInfo, "Interpreter", "latex");
    fontsize(48, "points");
    l.Location = 'Best';
    set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
    set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    set(findall(gcf,'-property','Box'),'Box','off') 
    % set(gca, 'XTick', [], 'XTickLabel', []);
    % set(gca, 'YTick', [], 'YTickLabel', []);
end