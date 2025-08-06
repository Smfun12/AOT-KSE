function [var] = matchTargetLocationsToDirectedSensors(var, p)
    var = calculateMappingBetweenPhysicalAndTargetSensors(var, p);
end

function [var] = calculateMappingBetweenPhysicalAndTargetSensors(var, p)
    mapping = zeros(size(var.target_sensors));
    remainingPoints = var.sensors;
    assigned = false(1, length(var.target_sensors));
    for i = 1:length(var.target_sensors)
        % Compute distances from array1(i, :) to all remaining points in array2
        distances = abs(var.sensors - var.target_sensors(i));
        distances = min(distances, p.Lx - distances);
        
        distances(assigned) = Inf;
        % Find the closest point
        [~, idx] = min(distances);

        % Store the mapping
        mapping(i) = idx;

        % Remove the matched point from remainingPoints
        % remainingPoints(idx) = [1e3];
        assigned(idx) = true;
    end
    var.mapping = mapping;
end

function var = greedy_unique_periodic_match(var, p)
    % A, B: 1D arrays of points in [0, L)
    % L: length of periodic domain
    % Output: indicesB(i) is index in B matched to A(i), uniquely
    A = var.target_sensors;
    B = var.sensors;
    L = p.Lx;
    nA = length(A);
    nB = length(B);
    assert(nA <= nB, 'Set B must have at least as many points as A.');

    indicesB = zeros(size(A));       % Final output
    assigned = false(1, nB);         % Keep track of assigned B points

    for i = 1:nA
        % Compute periodic distances from A(i) to all B
        dists = abs(A(i) - B);
        dists = min(dists, L - dists);

        % Invalidate distances for already assigned points
        dists(assigned) = Inf;

        % Assign to closest unassigned point
        [~, idx] = min(dists);
        indicesB(i) = idx;
        assigned(idx) = true;
    end
    var.mapping = indicesB;
end
