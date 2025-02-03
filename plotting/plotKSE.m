function plotKSE(p)
    figure(23);
    surf(p.soln_history);
    surf(p.soln_history);
    shading interp;
    surf([0,p.t],p.x,p.soln_history), shading interp, lighting phong, axis tight
    surf(p.plot_time,p.x,p.soln_history), shading interp, lighting phong, axis tight
    surf(p.plot_time,p.x,p.soln_history),  shading interp, axis tight
    view([-90 90]), colormap("jet");
    colormap(autumn);
    light('color',[1 1 0],'position',[-1,2,2])
    material([0.30 0.60 0.60 40.00 1.00]);
    % save("big_basis_kse.mat", "big_basis")
    % hold on
    % for i=1:3000-1
    %     start_idx = max(1, 10*(i-1));
    %     end_idx = 10*(i);
    %     scatter(t(i), x(sensor_locations_over_time(start_idx:end_idx)), 'black', 'filled')
    % end
    % hold off
end