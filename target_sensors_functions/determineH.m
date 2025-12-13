function [h] = determineH(p, var, ref_solution)
    
    number_of_generated_sensors = p.N+1;
    Kk = [];
    K = var.K;
    c = 10;
    u_x_star = abs(gradient(ref_solution));
    precision = 1000;
    N = length(var.sensors);
    while abs(number_of_generated_sensors - N) > 1e-7
        
        old_K = K;
        if number_of_generated_sensors > N
        
            K = K -  precision;
        else
            K = K + precision;
        
        end
        Kk = [Kk, K];
        if length(Kk) > 2 && K == Kk(end-2)
            precision = precision / 10;
        end
        
        bracket = (-4/3 * (2/p.lambda - p.mu + u_x_star+K)).^(3/4);
        if ~isreal(bracket)
            K = old_K;
            precision = precision / 10;
            continue
        end
        constants = p.lambda^(1/4) / (p.mu*c^(1/4));

        h = bracket * constants;
        
        number_of_generated_sensors = (sum(1./h)*p.dx);
        
    end
end
