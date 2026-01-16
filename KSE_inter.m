function KSE_inter()
close all; clc;
addpath("utils/", "default_config/", "plotting/", "target_sensors_functions/", "brewer/");
p = initDefaultEnv();

vars = DataAssimilationVariables_KSE(p);
p.size_vars = length(vars);

u_0 = cos(p.x/p.constant).*(1+sin(p.x/p.constant));

u_hat = fft(u_0);
p.soln_history(:,1) = u_0;

[p] = findTruncIndex(p);
[u_hat] = updateUHat(p, u_hat);
[vars] = updateVarsWithAOTField(vars, u_hat, p.trunc_index);

varsIndicesWithMachinePrecision = zeros(1, p.size_vars);
for ti = 1:p.num_timesteps
    u_hat_old = u_hat;
    % if mod(ti,p.show)==0
        disp("Iteration: " + ti + "/" + p.num_timesteps)
    % end
    nonlin_term = (1i*p.k/2).*fft(real(ifft(u_hat.*p.dealias_mask)).^2);
    u_hat = p.E.*(u_hat - p.dt*nonlin_term);
    
    p.ti = ti;
    u_phys = real(ifft(u_hat,'symmetric'));
    p.soln_history(:,p.n+1) = u_phys;
    p.n = p.n+1;
    
    error_counter = 0;
    for i=1:p.size_vars
        if ~varsIndicesWithMachinePrecision(i)
            [var] = updateObserversLocations(vars(i), p, u_hat_old, vars(i).aot_hat);
            [var] = updateAOTSolution(var, p, u_hat, u_hat_old);
            vars(i) = var;
        end
        if p.collect_sensor_trajectory
            vars(i).sensor_history(ti+1, :) = vars(i).sensors;
        end
    end
    
    if mod(ti,p.show)==0 && p.plot_var
          p = plotVars(vars, p, u_hat);
    end
    if error_counter == p.size_vars
        break
    end

end

if p.plot_gif
    for i=1:p.size_vars
        plotGif(p)
    end
end

if p.save_vars
    save_vars = zeros(1, p.size_vars);
    for i=1:p.size_vars
        save_vars(i) = vars(i);
    end
    
    timestamp = string(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
    filename = "vars" + timestamp + ".mat";
    
    save(filename, "vars")
end

if p.plot_kse_solution
    plotKSE(p)
    for i=1:p.size_vars
        plotSensorTrajectoryInXTPlane(p, vars(i))
    end
end

plotFinalErrorForVars(vars, p)
end