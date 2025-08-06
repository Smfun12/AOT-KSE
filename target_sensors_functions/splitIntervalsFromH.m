function [finalSubDomains] = splitIntervalsFromH(h, p, subdomain)

    stack = subdomain;
    precision = 0.75;
    finalSubDomains = [];
    
    while ~isempty(stack)
        
        [~, idx] = max([stack.density]);
        subdomain = stack(idx);
        stack(idx) = [];
        temp_list = [];
        
       [subDom, subDom_2] = splitIntervalIndexed(subdomain, p, 1./h);

        if subDom.density >= precision && subDom.xmin ~= subDom.xmax
            temp_list = [temp_list, subDom];
        end
        if subDom_2.density >= precision && subDom_2.xmin ~= subDom_2.xmax
            temp_list = [temp_list, subDom_2];
        end

        % if (n1 >= precision || n2 >= precision)
        %     if n1 > n2 && xmin ~= xmax
        %         temp_list = [temp_list, subDom];
        %         n = n - 1;
        %         if n >= 1 && n2 >= precision
        %             temp_list = [temp_list, subDom_2];
        %         end
        %     elseif xmin_2 ~= xmax_2
        %         temp_list = [temp_list, subDom_2];
        %         n = n - 1;
        %         if n >= 1 && n1 >= precision
        %             temp_list = [temp_list, subDom];
        %         end
        %     end
        % end

        if isempty(temp_list)
            subdomain.sensors = (p.x(subdomain.xmin) + p.x(subdomain.xmax)) / 2;
            finalSubDomains = [finalSubDomains, subdomain];
            if length(finalSubDomains) == p.num_sensors
                break;
            end
        else
            stack = [stack, temp_list];
        end
    end
end
