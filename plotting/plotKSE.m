function plotKSE(p)
    figure(23);
    surf([0,p.t],p.x,p.soln_history)
    shading interp
    lighting phong
    axis tight
    view([90 -90]);
    colormap(brewermap([], "-RdBu"))
end