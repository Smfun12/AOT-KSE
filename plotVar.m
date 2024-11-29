function [p] = plotVar(var, p, u_hat)
    
    set(0, 'CurrentFigure', var.main_fig);
    subplot(2,2,1)
    spec_aot = generate_spectrum_1D(var.aot_hat);
    spec = generate_spectrum_1D(u_hat);
    loglog(p.modes, spec_aot);
    hold on
    loglog(p.modes, spec);
    hold off
    legend("AOT spectrum", "Reference spectrum")
    title(sprintf('Energy spectrum at t = %1.2f',p.t(p.ti)));
    
    
    subplot(2,2,2)
    plot(p.x, ifft(var.aot_hat,'symmetric'));
    title(sprintf('AOT solution at t = %1.2f',p.t(p.ti)));
    axis([0, p.Lx, -3,3]);
    
    subplot(2,2,3)
    semilogy(p.dt:p.dt:p.dt*length(var.error), var.error);
    hold on;
    semilogy(p.dt:p.dt:p.dt*length(var.error_aot), var.error_aot);
    hold off;
    title("Error plot. Type="+var.observer_type+", N=" + length(var.sensors));
    xlabel("Time")
    ylabel("Error")

    subplot(2,2,4)
    ref_solution = ifft(u_hat,'symmetric');
    plot(p.x, ref_solution);
    hold on;
    if var.grid_sensors
        scatter(var.sensors, zeros(length(var.sensors)), 'r', 'filled')
    else
        scatter(p.x(var.sensors), zeros(length(var.sensors)), 'r', 'filled')
    end
    
    hold off;
    title(sprintf('Reference solution at t = %1.2f',p.t(p.ti)));
    axis([0, p.Lx, -3,3]);
    drawnow;
    pause(0.5);
end

