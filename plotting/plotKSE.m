function plotKSE(p)
    figure(gcf);
    hold on;
    % derivative_history = p.soln_history;
    % for i=1:size(derivative_history, 2)
    %     derivative_history = 
    % end
    surf(p.x,[0,p.t],p.soln_history'), shading interp, lighting phong, axis tight
    % colormap()
    % view([-90 90]), colormap("jet");
    % colormap(autumn);
    % light('color',[1 1 0],'position',[-1,2,2])
    % material([0.30 0.60 0.60 40.00 1.00]);
end