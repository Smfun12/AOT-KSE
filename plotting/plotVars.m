function [p] = plotVars(vars, p, u_hat)
    ref_solution = ifft(u_hat,'symmetric');
    set(0, "CurrentFigure", figure(80));
    if p.ti == p.show
        set(gcf, 'Position', get(0, 'Screensize'));
    end
    plot(p.x, ref_solution, "LineWidth", 6);    
    hold on;
    
    F = griddedInterpolant(p.x, ref_solution);
    legend_info = cell(1,p.size_vars);
    legend_info{1} = '';
    for i=1:p.size_vars
        var = vars(i);
        switch var.observer_type
            case "Lagrangian"
                if var.amplitude == 0
                    legend_info{i+1} = var.observer_type + ", $N = " + length(var.sensors) + "$";
                else
                    legend_info{i+1} = "Pert. Lagr., $N =" + length(var.sensors) + ", c=" + var.amplitude + "$";
                end
            case "Inertia"
                legend_info{i+1} = var.observer_type + ", $N = $" + length(var.sensors) + ", St=" + var.stokes_number + "$";
            case {"Directed"}
                legend_info{i+1} = "Directed, $N = " + length(var.sensors) + ", v_s \approx 0.66$";
        end
        plot(var.sensors, F(var.sensors), var.marker,"MarkerSize", 20, "MarkerFaceColor", var.color, "MarkerEdgeColor", var.outline_color);
    end

    legend(legend_info, "Interpreter", "latex");
    set(findall(gcf,'-property','Interpreter'),'Interpreter','latex') 
    set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')

    xlabel("$x$", "Interpreter","latex")
    ylabel("$u(x,t)$", Interpreter="latex")
    title(sprintf('$t$ = %1.2f',p.t(p.ti)), "Interpreter","latex");
    axis([0, p.Lx, -3,3]);
    fontsize(48, "points")
    frame = getframe(figure(80));
    p.im{p.ti} = frame2im(frame);
    drawnow;
    hold off
end