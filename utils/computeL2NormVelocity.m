function U_c = computeL2NormVelocity(velocityField, p)
    % Computes the characteristic velocity as the L2 norm over space and time.
    %
    % Parameters:
    % velocityField - A 3D array representing the velocity field:
    %                 (rows x cols x time steps)
    % dx            - Spatial resolution (assumes uniform grid)
    % dt            - Time resolution (uniform time steps)
    %
    % Returns:
    % U_c - The characteristic velocity (L2 norm)

    % Compute the squared magnitude of the velocity field
    

    velocitySquared = velocityField.^2;

    % Integrate over space and time
    spatialIntegral = (sum(velocitySquared, [1])); % Sum over rows and columns
    totalIntegral = sum(spatialIntegral);             % Sum over time

    % Normalize by the total space and time
    domainSize = numel(velocityField(:, 1)) * p.dx; % Total spatial size
    totalTime = size(velocityField, 2) * p.dt;          % Total time duration
 
    % Compute the L2 norm
    U_c = sqrt(totalIntegral * p.dx*p.dt / (domainSize * totalTime));

end
