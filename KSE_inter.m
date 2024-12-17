function KSE_inter()
clear; clc; close all;
addpath("utils/");
[db] = load("data/big_basis_kse.mat");
[Ks] = load("K.mat");

p = initDefaultEnv(); 
p.prod = false;
p.var_Ks = Ks.Ks;
p.L = log4m.getLogger('logs.txt');

p.big_basis = db.datas;
vars = DataAssimilationVariables_KSE(p);
p.size_vars = length(vars);

u_0 = cos(p.x/p.constant).*(1+sin(p.x/p.constant));
u_hat = fft(u_0);
p.soln_history(:,1) = u_0;

[trunc_index] = findTruncIndex(p);
[u_hat] = updateUHat(p, u_hat);
[vars] = updateVarsWithAOTField(vars, u_hat, trunc_index);




for ti = 1:p.num_timesteps
    u_hat_old = u_hat;
    % p.L.info("KSE Main", "Iteration: " + ti + "/" + p.num_timesteps)
    disp("Iteration: " + ti + "/" + p.num_timesteps)
    
    nonlin_term = (1i*p.k/2).*fft(real(ifft(u_hat.*p.dealias_mask)).^2);
    u_hat = p.E.*(u_hat - p.dt*nonlin_term);
    p.ti = ti;
    u_phys = real(ifft(u_hat,'symmetric'));
    
    p.soln_history(:,p.n+1) = u_phys;
    p.n = p.n+1;
    p.plot_time = [p.plot_time; ti*p.dt];
    error_counter = 0;
    for i=1:p.size_vars
        % if vars(i).error < 1e-15
        %     error_counter = error_counter + 1;
        %     vars(i).interpolation_error = [vars(i).interpolation_error, vars(i).interpolation_error(end)];
        %     continue
        % end
        [var] = updateObservers(vars(i), p, u_hat, vars(i).aot_hat);
        [var] = updateAOTSolution(var, p, u_hat, u_hat_old);
        
        if mod(ti,p.show)==0
            [var] = plotVar(var,p, u_hat);
        end
        vars(i) = var;
        
    end
    if error_counter == p.size_vars
        break
    end

end

plotFinalErrorForVars(vars, p)
% plotMeanVelocity(p)

if p.plot_kse_solution
    plotKSE(p)
end

end

function plotMeanVelocity(p)
columnAverages = mean(abs(p.soln_history));
boxplot(columnAverages)
xlabel('Time')
ylabel('Velocity')
title('Velocity magnitude over time')
end


