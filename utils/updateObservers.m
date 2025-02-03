function [var] = updateObservers(var, p)
    switch var.observer_type
        
        case {"Dynamic-DD"}
            
            r = var.r;
            psensors = var.p;
            window = r;
            end_idx = window;
            if mod(p.ti, window) == 0
                end_idx = min(3000, p.ti + window);
            end
            start_idx = min(3000, max(1, end_idx-window));

            [Psi, ~, ~] = svd(p.big_basis(:, start_idx:end_idx), 'econ');
            if psensors <= r
                [~, ~, pivot] =  qr(Psi(:,1:r)','vector');
            else
                [~, ~, pivot] =  qr(Psi*Psi','vector');
            end
            url = 'http://127.0.0.1:5000/api/sensors';
            data = struct('basis', Psi, 'all_sensors', pivot, "X_train", p.big_basis(:, start_idx:end_idx), 'distance', 2, 'n_sensors', psensors);
            
            options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json', 'Timeout', 3600);
            response = webwrite(url, data, options);
            sensors = response.message + 1;
            var.sensors = sort(sensors);
            
        case "Static-DD"
            if p.ti == 1
                r = var.r;
                psens = var.p;
                [Psi, ~, ~] = svd(p.big_basis, 'econ');
                if psens <= r
                    [~, ~, pivot] =  qr(Psi(:,1:r)','vector');
                else
                    [~, ~, pivot] =  qr(Psi*Psi','vector');
                end
                url = 'http://127.0.0.1:5000/api/sensors';
                data = struct('basis', Psi, 'all_sensors', pivot, "X_train", [], 'distance', 2, 'n_sensors', psens);
                options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json', 'Timeout', 3600);
                response = webwrite(url, data, options);
                sensors = response.message + 1;
                var.sensors = sort(sensors');
            end
        case "Random-DD"
            if mod(var.basis_counter,var.temp_basis_size) == 0
                r = var.r;
                psens = var.p;

                [Psi, ~, ~] = svd(var.temp_basis(:, 1:2), 'econ');
                if psens <= r
                    [~, ~, pivot] =  qr(Psi(:,1:r)','vector');
                else
                    [~, ~, pivot] =  qr(Psi*Psi','vector');
                end

                url = 'http://127.0.0.1:5000/api/sensors';
                data = struct('basis', Psi, 'all_sensors', pivot, "X_train", var.temp_basis(:, 1:2), 'distance', 2, 'n_sensors', psens);
                options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json', 'Timeout', 3600);
                response = webwrite(url, data, options);
                sensors = response.message + 1;
                sensors = sensors';
                var.sensors = sort(sensors);
                var.temp_basis = [];
            else
                sensors = randi([1, p.N], [1,length(var.sensors)]);
                sensors = unique(sensors);
                var.sensors = sort(sensors);
            end
        case "Zhao-DD"
            if mod(var.basis_counter,var.temp_basis_size) == 0
                r = var.r;
                psens = var.p;

                [Psi, ~, ~] = svd(var.temp_basis(:, 1:2), 'econ');
                if psens <= r
                    [~, ~, pivot] =  qr(Psi(:,1:r)','vector');
                else
                    [~, ~, pivot] =  qr(Psi*Psi','vector');
                end
                
                url = 'http://127.0.0.1:5000/api/sensors';
                data = struct('basis', Psi, 'all_sensors', pivot, "X_train", var.temp_basis(:, 1:2), 'distance', 2, 'n_sensors', psens);
                options = weboptions('RequestMethod', 'post', 'MediaType', 'application/json', 'Timeout', 3600);
                response = webwrite(url, data, options);
                sensors = response.message + 1;
                sensors = sensors';
                % spatial_sensors = moveSpatialToTargetsPeriodically(var.sensors, p.x(sensors), p, ref_solution);
                var.sensors = sort(sensors);
                var.temp_basis = [];
            end
        case "Random"
            if p.ti == 1 || mod(p.ti, 250) == 0
                var.sensors = sort(unique(randi([1, p.N], 1,34)));
            end
    
    end
end