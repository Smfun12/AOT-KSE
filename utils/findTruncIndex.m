function [p] = findTruncIndex(p)
    trunc_array = zeros(p.N,1);
    
    for i = 1:p.N
        if(abs(p.k(i)./(2*pi/p.Lx)) < p.observed_modes)
            trunc_array(i) = 1;
        end
    
    end
    trunc_array(1) = 0;
    trunc_array(p.N/2+1) = 0;
    p.trunc_index = find(trunc_array == 1);
    p.trunc_index_comp = find(trunc_array == 0);
end

