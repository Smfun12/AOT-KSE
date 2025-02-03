clear; clc; close all;
% Define scattered points in a periodic domain
x = linspace(0, 2*pi, 64);  % x-coordinates (assumed periodic over 5)
Lx = 2*pi;
N = 2^8;
dx = Lx/N;
x = 0:dx:(Lx-dx);
y = sin(x);  % Corresponding y-values

% Extend data for periodicity
x_extended = [x(end) - Lx,x, x(1) + Lx];  % Append first x at end
y_extended = [y(end), y, y(1)];      % Append first y to enforce periodicity

% Create gridded interpolant with spline method
F = griddedInterpolant(x_extended, y_extended, 'spline');

% Generate interpolation points (make sure they are within the periodic domain)
xx = linspace(0, 2*pi, 128);  
yy = F(xx);  % Use modulo to enforce periodicity in interpolation

% Plot
figure;
plot(x, y, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); hold on;
plot(xx, yy, 'b-', 'LineWidth', 2);
xlabel('x');
ylabel('y');
title('Periodic Spline Interpolation using griddedInterpolant');
grid on;
