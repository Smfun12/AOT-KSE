function [vars] = updateVarsWithAOTField(vars, u_hat, trunc_index)
    for i=1:length(vars)
        vars(i).aot_hat = zeros(size(u_hat));
        vars(i).aot_hat(trunc_index) = u_hat(trunc_index);
    end
end

