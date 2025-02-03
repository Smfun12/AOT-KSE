clear; clc; close all;
addpath('./brewer/')
r=-3.1:0.09:3.1;



[x,y]=meshgrid(r);

tMax = 0.3;
dt = 0.001;

mu = 0.25;
optimal_x = [];
optimal_y = [];
lagrangian_path = [];

idx = 23;
idxy = 23;
x_pos = x(idx, idxy);
y_pos = y(idx, idxy);
counter = 1;
start_idx = 1;
step = 20;
end_idx = step;
sns = 10;
% lagrangian_sensors = [LagrangianSensor(x_pos, y_pos, [],'r',idx, idxy)];
lagrangian_sensors = [];
accumulator = 1;
lagrangian_error = [];
optimal_error = [];
big_basis = [];
for t = 0:dt:tMax
   
    % Test case

    K1 = 700; % strength of the vortex
    K2 = -15; % speed of the vortex
    offset_x = 0;
    offset_y = 2;

    offset_x_2 = 2;
    offset_y_2 = 0; 


    % offset_x_3 = 2;
    % offset_y_3 = -2; 
    ti = t;
    
    % x_pos = x +offset_x+(K2*ti);
    % rr_standard =((x_pos).^2+(y-offset_y).^2)*10;
    % rr=((x +offset_x).^2+(y-offset_y-(K2*t*0)).^2)*10;
    % rr2=((x + offset_x_2+ K2*t*0).^2+(y+offset_y_2).^2)*10;
    rr=((x +offset_x).^2+(y-offset_y-(K2*t)).^2)*10;
    rr2=((x + offset_x_2+ K2*t).^2+(y+offset_y_2).^2)*10;
    
    % Vertical down
    % U = -K1*(y-offset_y-(K2*t*0))./(rr).*(1-exp((-rr)/(4*mu)))-K1*(y-offset_y_2)./(rr2).*(1-exp((-rr2)/(4*mu)));
    % V = K1*(x +offset_x)./(rr).*(1-exp((-rr)/(4*mu)))+K1*(x +offset_x_2+(K2*t*0))./(rr2).*(1-exp((-rr2)/(4*mu)));
    U = -K1*(y-offset_y-(K2*t))./(rr).*(1-exp((-rr)/(4*mu)))-K1*(y-offset_y_2)./(rr2).*(1-exp((-rr2)/(4*mu)));
    V = K1*(x +offset_x)./(rr).*(1-exp((-rr)/(4*mu)))+K1*(x +offset_x_2+(K2*t))./(rr2).*(1-exp((-rr2)/(4*mu)));


    % Horizontal right
    % U = -K1*(y-offset_y)./(rr_standard).*(1-exp((-rr_standard)/(4*mu)));
    % V = K1*(x_pos)./(rr_standard).*(1-exp((-rr_standard)/(4*mu)));
    
    u = reshape(U, [], 1);
    v = reshape(V, [], 1);
    
    quiver(x,y, U, V , "r", "LineWidth", 1.5) ;
    hold on
    
    for j=1:length(lagrangian_sensors)
    
        x_pos = lagrangian_sensors(j).x;
        y_pos = lagrangian_sensors(j).y;
        plot(x_pos, y_pos, '.', 'Color', 'r', 'MarkerSize', 10);
    end
    
    if counter == fix(end_idx/2)
        bigs = size(big_basis);
        
        start_idx = min(bigs(2)-step, start_idx + step);
        end_idx = min(bigs(2), end_idx + step);
    end
    big_basis = [big_basis, [u.*v]];

    hold off
    axis([-3 3 -3 3]);
    axis equal ;

    title(['Vorticity Contours of Lamb-Oseen Vortex at t = ', num2str(t)]);
    xlabel('x');
    ylabel('y');
    drawnow;
end
save("big_basis_lamb_oseen.mat", "big_basis")
figure(1)
quiver(x,y, U, V , "b" ) ;
title(['Vorticity Contours of Lamb-Oseen Vortex at t = ', num2str(t)]);
xlabel('x');
ylabel('y');