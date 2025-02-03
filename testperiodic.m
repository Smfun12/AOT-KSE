clear; clc; close all;
% Set the parameters
target_points = [0, 10, 19];  % Set of target points
reference_points = [18, 3, 8];  % Set of reference points (heading towards targets)
L = 20;  % Length of the 1D domain (for periodic boundaries)
v = 1;  % Velocity of the points
dt = 0.1;  % Time step for each frame
num_frames = 100;  % Number of frames for the animation

% Create a figure for the animation
figure;
hold on;
xlim([0, L]);
ylim([0, 2]);  % Just enough space for the points and visualization
xlabel('Position');
ylabel('Point ID');
title('1D Movement with Periodic Boundaries');

% Loop over the number of frames
for frame = 1:num_frames
    % Move each reference point with some velocity towards the target
    for i = 1:length(reference_points)
        % Compute the direction towards the target
        direction = target_points(i) - reference_points(i);
        if direction > L / 2
            direction = direction - L;
        elseif direction < -L / 2
            direction = direction + L;
        end
        
        % Update the reference point position based on velocity and dt
        if abs(direction) > v * dt
            % Move towards the target but do not overshoot
            reference_points(i) = reference_points(i) + sign(direction) * v * dt;
        else
            % If the point is about to overshoot the target, stop at the target
            reference_points(i) = target_points(i);
        end
        
        % Apply periodic boundary conditions
        if reference_points(i) >= L
            reference_points(i) = reference_points(i) - L;  % Wrap around
        elseif reference_points(i) < 0
            reference_points(i) = reference_points(i) + L;  % Wrap around
        end
    end
    
    % Clear the plot and redraw
    clf;
    hold on;
    xlim([0, L]);
    ylim([0, 2]);
    
    % Plot the target and reference points
    scatter(target_points, ones(size(target_points)), 100, 'r', 'filled');  % Target points
    scatter(reference_points, ones(size(reference_points)) * 1.5, 100, 'b', 'filled');  % Reference points
    
    % Display the target and reference points labels
    for i = 1:length(target_points)
        text(target_points(i), 1, sprintf('Target %d', i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        text(reference_points(i), 1.5, sprintf('Ref %d', i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
    title("Frame="+ frame + "/" + num_frames)
    % Pause to create animation effect
    pause(0.05);
end
