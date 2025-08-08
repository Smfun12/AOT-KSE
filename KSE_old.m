clear; close all; clc;

addpath("target_sensors_functions/")
L = 32*pi;
Nx = 1024;
dx = L/Nx;
x = 0:dx:L - dx;
% mu = linspace(100, 101, 2);
% mu = logspace(log10(1), log10(1000), 10);
% N = logspace(log10(1), log10(1024), 10);
% mu =359;
mu = 100;

N = 1024;
choice = "Target";
mus = [];
nns = [];
sensor_distance_difference = [];
for i=1:length(mu)
    curr_mu = mu(i);
    for j=1:length(N)
        nsensors = floor(N(j));
        disp("Running mu="+curr_mu+", N="+nsensors)
        [converged] = kse(curr_mu, nsensors, choice);
        if converged
            mus = [mus, mu(i)];
            nns = [nns, N(j)];
            break
        end
    end
end


save("mus", "mus")
save("nns", "nns")

function [converged] = kse(mu, nsensors, choice)
close all;
N = 2^10;
Lx = 32*pi;
dx = Lx/N;
x = 0:dx:Lx - dx;

lambda = 1;

T = 1;
% dt = 0.001;
if mu < 20
    dt = 0.1;
elseif mu < 200
    dt = 0.01;
else
    dt = 0.001;
end
% dt = 1.2207e-4;
show = 1e5;

% mu = 100;

k = [0:N/2-1 0 -N/2+1:-1]*(2*pi/Lx);
E = exp(dt*(lambda*k.^2 - k.^4));

dealias_mask = abs(k) <= floor((2/3)*N);
% [~,dealias_modes] = find(abs(k) > floor(N*2/3));


num_timesteps = ceil(T/dt);
t = dt:dt:dt*num_timesteps;

u_0 = cos(x/16).*(1+sin(x/16));
% u_0 = sin(x/16);
u_hat = fft(u_0);
modes = 1:N/2;


soln_history = zeros(N, ceil(num_timesteps/show)+1);
soln_history(:,1) = u_0;
plot_time = 0;

% ref_fig = figure;
axis([0, Lx, -3,3]);

% spec_fig = figure;
% 
error_fig = figure;

observed_modes = 20;

trunc_array = zeros(N,1);

for i = 1:N
    if(abs(k(i)./(2*pi/Lx)) < observed_modes)
        trunc_array(i) = 1;
    end

end
trunc_array(1) = 0;
trunc_array(N/2+1) = 0;

trunc_index = find(trunc_array == 1);
trunc_index_comp = find(trunc_array == 0);

ramp_up_timesteps = floor(50/dt);



for ti = 1:ramp_up_timesteps
    nonlin_term = (1i*k/2).*fft(real(ifft(u_hat.*dealias_mask)).^2);
    u_hat = E.*(u_hat - dt*nonlin_term);

end

% AOT (nudging) solution
aot_hat = zeros(size(u_hat));
aot_hat(trunc_index) = u_hat(trunc_index);

% error = NaN(1,num_timesteps);
error = norm(abs(u_hat - aot_hat),'fro')/N;
error_aot = error;

p.x = x;
p.N = N;
p.Lx = Lx;
p.dx = dx;
p.dt = dt;
p.num_sensors = nsensors;
p.lambda=1;
n = 1;
aa = NaN(1, num_timesteps);
bracket_values = NaN(1, num_timesteps);
snd_inequality_values = NaN(1, num_timesteps);
sensors = linspace(x(1), x(end), nsensors);
sensor_speed = inf;
% sensors = p.x(1:2:1024);
% mm = NaN(1, num_timesteps);
% mm = [error_aot];
converged = false;
mm = [error_aot];
initial_K = 0;
im = [];
target_sensors = sensors;
for ti = 1:num_timesteps
    disp("Iteration: " + ti + "/" + num_timesteps)
    u_hat_old = u_hat;
    % u_dealiased = ifft(u_hat.*dealias_mask,'symmetric');
    % u_dealiased = ifft(u_hat,'symmetric');
    nonlin_term = (1i*k/2).*fft(real(ifft(u_hat.*dealias_mask)).^2);
    % nonlin_term = fft(u_dealiased.*real(ifft(1i*k.*u_hat, 'symmetric')));

    u_hat = E.*(u_hat - dt*nonlin_term);
  
    ref_solution = ifft(u_hat_old, "symmetric");
    aot_solution = ifft(aot_hat, "symmetric");
    if choice == "Uniform"
        
        h = diff(sensors);
        c = 1/sqrt(12);
        a = 2/lambda - mu + (abs((gradient(ref_solution)))) + 3/4*((mu^4*c.*h(1).^4)/lambda).^(1/3);
        aa(ti) = (max(a));
        bracket_values(ti) = max(a);
        b = c.*mu*h(1).^2 - lambda;
        snd_inequality_values(ti) = b;
    elseif choice == "Target"
        
        K = initial_K;
        p.ref_solution = aot_solution;
        p.mu = mu;
        c = 10;
        h = determineH(p, K, ref_solution);
        u_x_star = abs(gradient(aot_solution));
        p.num_sensors = nsensors;
        if ti ==1 || (norm(target_sensors - sensors) < 1e-6 && error_aot(end) > 1e-13)
            var.K = K;
            [target_sensors] = intervalBasedTargetLocations(p, var, ref_solution);
        end
        sensors = moveSpatialToTargetsPeriodically(target_sensors, sensors, sensor_speed, p);
       
        % M 
        a = 2/lambda - mu + u_x_star + 3/4*((mu^4*c.*h.^4)/lambda).^(1/3);
        aa(ti) = (max(a));
        bracket_values(ti) = max(a);
        b = c.*mu*h(1).^2 - lambda;
        snd_inequality_values(ti) = b;
    end

    %observe previous timestep for nudging
    [ovs, ~] = interpolate_observations(p, ref_solution, sensors);
    % aot_obs = u_hat_old;
    aot_obs = fft(ovs);
    [aot_v, ~] = interpolate_v(p, aot_solution, sensors);
    %Zero out unobserved modes on observation data
    % aot_obs(trunc_index_comp) = 0;

    %compute nudging feedback term I_h(u-v)
    Ihumv = aot_obs - fft(aot_v);
    %Zero out all unobserved modes
    % Ihumv(trunc_index_comp) = 0;
    Ihumv(1) = 0;
    Ihumv = Ihumv.*dealias_mask;
    
    
    nonlin_aot = (1i*k/2).*fft(real(ifft(aot_hat.*dealias_mask)).^2);
    aot_hat = E.*(aot_hat - dt*nonlin_aot + dt*mu*(Ihumv));

    obs = u_hat.';

    


    % error_aot(ti) = norm(abs(u_hat - aot_hat),'fro')/N;
    error_aot = [error_aot, norm(abs(u_hat - aot_hat),'fro')/N];
    
    rate = error_aot(1)*exp(max(a)*t(ti));
    rate(rate <= 10e-17) = 10e-17;
    rate(rate >= 10e10) = NaN;
    % mm(ti)= rate;
    mm = [mm ,rate];
    if (error_aot(ti) < 1e-14)
        converged = true;
        % break;
    end
    if (ti == 1)
        aa(ti) = error_aot(ti);
        % mm(ti) = error_aot(1);
    end
    if mod(ti,show)==0
        % mm(ti-show+1:ti) = error_aot(1)*mm(ti-show+1:ti);
        % u_phys = real(ifft(ensemble(1).forecast,'symmetric'));

        u_phys = real(ifft(u_hat,'symmetric'));

        soln_history(:,n+1) = u_phys;
        plot_time = [plot_time; ti*dt];
        n = n+1;

        spec = generate_spectrum_1D(u_hat);
        % figure(spec_fig);
        set(0, "CurrentFigure", spec_fig)
        loglog(modes, spec);
        hold on

        spec_aot = generate_spectrum_1D(aot_hat);
        loglog(modes, spec_aot);

        max(abs(spec - spec_aot));

        hold off;


        title(sprintf('Energy spectrum at t = %1.2f',t(ti)));


        % figure(ref_fig);
        set(0, "CurrentFigure", ref_fig)
        hold off;
        plot(x, ifft(u_hat,'symmetric'), "LineWidth",3);
        % set(ref_fig, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
        F = griddedInterpolant(x, ref_solution);
        hold on
        scatter(sensors, 0*F(sensors), 100, "filled", "red")
        

        % scatter(target_sensors, zeros(length(sensors)), 100, "filled", "red")
        title(sprintf('Reference solution at t = %1.2f',t(ti)));
        axis([0, Lx, -3,3]);
        plot(x, ifft(aot_hat,'symmetric'), "LineWidth", 3);
        l = legend(["$u$", "Sensors. $\#$"+length(sensors), "$\hat{u}$"], "Interpreter","latex", "FontSize",24);
        % set(gcf, 'Position', get(0, 'Screensize'));
        % plot(x, ifft(abs(aot_hat - u_hat), 'symmetric'));
        % plotBoundariesForSegments(h, ref_solution, sensors);
        % l.String(6:end) = [];
        % l.String(6:end) = [];
        % l.String(4) = {"Designed sensor location"};
        % l.String(5) = {"Distance"};
        xlabel("$X$",Interpreter="latex")
        fontsize(30, "points")
        hold off;
        
        % ylabel("$$", "Interpreter","latex")
        frame = getframe(ref_fig);
        im{ti} = frame2im(frame);


        % drawnow;

        % figure(error_fig);
        set(0, "CurrentFigure", error_fig)
        semilogy(dt:dt:dt*length(error), error, "LineWidth",3);
        hold on;

        semilogy(0:dt:dt*(length(error_aot)-1), error_aot, "LineWidth", 6, "Marker","o");
        semilogy(0:dt:dt*(length(error_aot)-1), mm, "LineWidth", 6, "Color", "black");
        % legend(["", "$e_t$, AOT error. Type=" + choice + ". " + "$N=$ " + length(sensors)+ ". $\kappa=$" + mu], "Interpreter","latex", "Location","best")
        % l = legend(["", "Nonpehysical target sensors, algorithm 2. $N=$ " + length(sensors)+ ". $\kappa=$" + mu + ".", "Designed error decay, $e^{r(h,x)\cdot t}$" ], "Interpreter","latex", "Location","best");
        % legend(["", "Actual error decay, $\epsilon_t.\ N=$ " + length(sensors)+ ". $\kappa=$" + mu, "Designed error decay, $e^{r(\kappa, h)\cdot t}$" ], "Interpreter","latex", "Location","best")
        % legend(["", "$e_t$, AOT error. N=" + length(sensors)+ ". $\kappa=$" + mu, "$e^{M(\kappa, N)\cdot t}$" ], "Interpreter","latex", "Location","best")
        % xlabel("Time, $t$", "Interpreter","latex")
        % ylabel("AOT error, $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex")
        % fontsize(48, "points")
        hold off;
        drawnow;



    end

end
set(0, "CurrentFigure", error_fig)
semilogy(dt:dt:dt*length(error), error, "LineWidth",6);
hold on;
semilogy(0:dt:dt*(length(error_aot)-1), error_aot, "LineWidth", 6, "Marker","o");
semilogy(0:dt:dt*(length(error_aot)-1), mm, "LineWidth", 6, "Color", "black");
% semilogy(0:dt:dt*(length(error_aot)-1), mm, "LineWidth", 3, "Color", "black");
% legend(["", "$e_t$, AOT error. Type=" + choice + ". " + "$N=$ " + length(sensors)+ ". $\kappa=$" + mu], "Interpreter","latex", "Location","best")
l = legend(["", "$N=$ " + length(sensors)+ ", $v_p=$" + sensor_speed, "Designed error decay, $e^{r(h,x)\cdot t}$" ], "Interpreter","latex", "Location","best");
% legend(["", "Actual error decay, $\epsilon_t.\ N=$ " + length(sensors)+ ". $\kappa=$" + mu, "Designed error decay, $e^{r(\kappa, h)\cdot t}$" ], "Interpreter","latex", "Location","best")
% legend(["", "$e_t$, AOT error. N=" + length(sensors)+ ". $\kappa=$" + mu, "$e^{M(\kappa, N)\cdot t}$" ], "Interpreter","latex", "Location","best")
xlabel("Time (simulated)", "Interpreter","latex")
ylabel("Error $\frac{1}{N} \|u-\hat{u}\|_F$","Interpreter","latex")
fontsize(84, "points")
% l.FontSize = 40;
set(findall(gcf,'-property','Interpreter'),'Interpreter','latex') 
set(findall(gcf,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(findall(gcf,'-property','Box'),'Box','off') 

% filename = "sensors_movement.gif"; % Specify the output file name
% total_frames = (length(im));
% for idx = 1:total_frames
%     if isempty(im{idx})
%         continue
%     end
%     [A,map] = rgb2ind(im{idx},256);
%     if idx == show
%         imwrite(A,map,filename,"gif",LoopCount=Inf, ...
%                 DelayTime=.5)
%     else
%         imwrite(A,map,filename,"gif",WriteMode="append", ...
%                 DelayTime=.5)
%     end
% end


set(error_fig, 'Position', get(0, 'Screensize'));
filename_error = choice + "_" + length(sensors) + "_mu_" + mu;
filename_error = replace(filename_error, ".", ",");
savefig(error_fig, "/Users/oleksandr/Documents/AOT_clean/KSE/plots/"+choice + "/" + filename_error)
saveas(error_fig, "/Users/oleksandr/Documents/AOT_clean/KSE/plots/"+choice + "/" + filename_error + ".jpg")

% slope = gradient(log(error_aot), t(1:length(error_aot)));  
% slope_2 = gradient(log(mm), t(1:length(mm)));  % Compute numerical derivative
% slope_fig = figure(80);
% hold on;
% time_axis = dt:dt:dt*length(error_aot);
% semilogy(time_axis, slope, "LineWidth",10)
% semilogy(time_axis, slope_2, "LineWidth",10)
% xlabel("Time, $t$", "Interpreter","latex")
% ylabel("Rate, $r(\kappa, h)$", "Interpreter","latex")
% scatter(dt, slope(1), 300, "filled", "blue", "DisplayName", "")
% scatter(dt, slope_2(1), 300, "filled", "red", "DisplayName", "")
% legend([choice+", $N=$ " + length(sensors) + ". $\kappa = $" + mu, "Designed rate", "",""], Interpreter="latex", Location="best")
% fontsize(48, "points")
% 
% plotAndSaveFigure(error_fig)

% % inequalities_fig = figure(90);
% plot(dt:dt:dt*length(error), bracket_values, "LineWidth", 3)
% hold on
% plot(dt:dt:dt*length(error), snd_inequality_values, "LineWidth",3)
% xlabel("Time")
% ylabel("Value")
% fontsize(36, "points")
% legend(["$M(\mu=" + mu + ", N=" + length(sensors) + ")$", "$\mu ch^2 - \nu$"], "Interpreter","latex")
% 
% if(plot_time(end)~= t(end))
%     u_phys = real(ifft(u_hat,'symmetric'));
% 
%     soln_history(:,end) = u_phys;
%     plot_time = [plot_time; t(end)];
% 
% 
% end


% % set(inequalities_fig, 'Position', get(0, 'Screensize'));
% set(slope_fig, 'Position', get(0, 'Screensize'));
% % filename_inq = choice + "_" + length(sensors) + "_mu_" + mu + "_inequalities";
% filename_slope = choice + "_" + length(sensors) + "_mu_" + mu + "_rate";
% % filename_inq = replace(filename_inq, ".", ",");
% filename_slope = replace(filename_slope, ".", ",");
% % savefig(inequalities_fig, "/Users/oleksandr/Documents/AOT_clean/KSE/plots/"+choice + "/" + filename_inq)
% savefig(slope_fig, "/Users/oleksandr/Documents/AOT_clean/KSE/plots/"+choice + "/" + filename_slope)
% % saveas(inequalities_fig, "/Users/oleksandr/Documents/AOT_clean/KSE/plots/"+choice + "/" + filename_inq + ".jpg")
% saveas(slope_fig, "/Users/oleksandr/Documents/AOT_clean/KSE/plots/"+choice + "/" + filename_slope + ".jpg")


% figure;
% % surf(soln_history);
% % surf(soln_history);
% % shading interp;
% % surf([0,t],x,soln_history), shading interp, lighting phong, axis tight
% surf(plot_time,x,soln_history), shading interp, lighting phong, axis tight
% view([-90 90]), colormap(autumn);
% % colormap(autumn);
% light('color',[1 1 0],'position',[-1,2,2])
% material([0.30 0.60 0.60 40.00 1.00]);
end

function plotBoundariesForSegments(h, u, sensors)
    % Sample h values
    
    N = 33;  % Number of points x_i
    
    % Compute x values from h
    
    x = zeros(1, N);
    x(1) = sensors(1);
    for i = 2:N
        x(i) = x(i-1) + h(i-1);
    end
    
    % Plot the boundaries (intervals between x_i and x_{i+1})
    figure(1);
    hold on;
    
    % Draw vertical lines or boxes for each interval
    for i = 1:N-1
        % Draw a rectangle or vertical line to represent boundary
        % Option 1: Vertical lines
        line([x(i), x(i)], [0, 1], 'Color', 'b', 'LineStyle', '--', "LineWidth", 2);
        
        % Option 2: Horizontal line showing the interval
        plot([x(i), x(i+1)], [0.5, 0.5], 'k', 'LineWidth', 2);
        % annotation('arrow', ...
        %     [(x(i) - x(1)) / (x(end) - x(1)), (x(i+1) - x(1)) / (x(end) - x(1))], ...
        %     [0.5, 0.5], 'LineWidth', 1.5);
        % 
        % Optional: annotate the x values
        if mod(i, 2) == 0
            text((x(i)+x(i+1))/2, 0.4, sprintf('h_{%d}', i), 'HorizontalAlignment', 'center');
        else
            text((x(i)+x(i+1))/2, 0.8, sprintf('h_{%d}', i), 'HorizontalAlignment', 'center');
        end
        
    end
end
function makeMovieFromRefining(mesh, segments, p, h)
fig = figure(1);
colors = summer(length(segments));
set(gcf, 'Position', get(0, 'Screensize'));
xlabel("X")
ylabel("Y")
title("Sensor distribution")
plot(p.x, h, "LineWidth", 3, "DisplayName", "$x^2+0.1$")
xlim([0, p.Lx]);
fontsize(36, "points")

hold on
[~, idx] = sort([segments.a]);
segments = segments(idx);
for i=1:length(segments)
    segment_i = segments(i);
    
    points = linspace(segment_i.a, segment_i.b, 100);
    plot(points, mean(h), '.', 'Color', colors(i, :), 'MarkerSize', 10, "DisplayName", "Local domains");
    line([segment_i.a segment_i.a], [min(h) max(h)], "Color", "black", "LineWidth", 2)
    line([segment_i.b segment_i.b], [min(h) max(h)], "Color", "black", "LineWidth", 2)
    if mod(i, 2) == 1
        text((segment_i.a+segment_i.b)/2, mean(h)+0.0002, "$r_{"+i + "}$",'VerticalAlignment', 'bottom' , 'HorizontalAlignment', 'center', 'FontSize', 25, "Interpreter","latex","Color","black", "FontWeight","bold");
    else
        text((segment_i.a+segment_i.b)/2, min(h), "$r_{"+i + "}$",'VerticalAlignment', 'bottom' , 'HorizontalAlignment', 'center', 'FontSize', 25, "Interpreter","latex","Color","black", "FontWeight","bold");
    end
    % l = legend();
    % l.Interpreter = "latex";
    % legendUnq;
    % l.String(3:end) = [];
    frame = getframe(fig);
    im{i} = frame2im(frame);
end

n = length(im);
sensors = mesh;
for i=1:length(sensors)
    scatter(sensors(i), 3.005556, 100,"black", "filled", "DisplayName", "Sensor")
    frame = getframe(fig);
    im{n+i} = frame2im(frame);
   
end
% legendUnq;
% l = legend();
% l.Interpreter = "latex";
% l.String(4:end) = [];
filename = "testAnimated.gif"; % Specify the output file name
total_frames = length(im);
for idx = 1:total_frames
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,"gif",LoopCount=Inf, ...
                DelayTime=.1)
    else
        imwrite(A,map,filename,"gif",WriteMode="append", ...
                DelayTime=.1)
    end
end
end

function spectrum = generate_spectrum_1D(soln_hat)

[N] = length(soln_hat);
spectrum = zeros(1, N/2);


for j = 1:N/2
    % for i = 1:Nx/2
    modes = floor(abs(j));
    if modes <= N/2
        spectrum(modes) = spectrum(modes) + abs(soln_hat(j))^2;
    end
    % end
end
modes = 1:N/2;
spectrum = sqrt(spectrum)/N^2;

spectrum = max(spectrum, eps);
end

function [vq1, bsv_data] = interpolate_observations(p, ref_solution, spatial_sensors)
    F_temp = griddedInterpolant(p.x, ref_solution);
    bsv_data = F_temp(spatial_sensors);

    x_pts = spatial_sensors';

    u_data1 = [bsv_data(end), bsv_data, bsv_data(1)];

    x_pts_per = x_pts;
    x_pts_per = [x_pts_per(end) - p.Lx; x_pts_per; x_pts_per(1) + p.Lx];

    F1 = griddedInterpolant(x_pts_per, u_data1.', "linear");
    vq1 = F1(p.x);
end

function [vq2, aot_sensors] = interpolate_v(p, aot_sol, spatial_sensors)

    F2 = griddedInterpolant(p.x, aot_sol);
    aot_sensors = F2(spatial_sensors);
    x_pts = spatial_sensors';
    
    u_data2 = [aot_sensors(end),aot_sensors, aot_sensors(1)];
    
    x_pts_per = [x_pts(end) - p.Lx; x_pts; x_pts(1) + p.Lx];

    F1 = griddedInterpolant(x_pts_per, u_data2.', "linear");
    vq2 = F1(p.x);
end


function [mesh,segments]= mesh_refine_greedy(h_func, a, b, N, x, dx)
    % Start with one segment
    segments = struct('a', a, 'b', b, 'weight', compute_weight(h_func, a, b, x, dx));
    
    % Keep splitting until we have N segments
    while length(segments) < N
        % Find the segment with the highest weight
        [~, idx] = max([segments.weight]);
        seg = segments(idx);
        
        % Split it in half
        mid = (seg.a + seg.b) / 2;
        
        left.weight = compute_weight(h_func, seg.a, mid, x, dx);
        left.a = seg.a;
        left.b = mid;
        
        right.weight = compute_weight(h_func, mid, seg.b, x, dx);
        right.a = mid;
        right.b = seg.b;
        
        % Replace the selected segment with its two children
        segments(idx) = [];  % remove the old one
        segments(end+1) = left;
        segments(end+1) = right;
    end
    
    % Extract mesh points
    % mesh = sort(unique([segments.a, segments.b]));
    mesh = sort(unique(([segments.a] + [segments.b]) / 2));
end

function w = compute_weight(h_func, a, b, x, dx)
    % Weight is the integral of 1/h(x) over [a, b]
    F = griddedInterpolant(x, h_func);
    h = @(x) F(x);
    w = integral(@(x) 1 ./ h(x), a, b);
    % w = sum(1./h_func)*dx;
end


function mesh = mesh_refinement(h_func, a, b, N, x)
    F = griddedInterpolant(x, h_func);
    h = @(x) F(x);
    mesh = refine_recursive(h, a, b, N);
end

function segments = refine_recursive(h_func, a, b, N)
    if N < 1
        % If less than one sensor is needed in this subdomain, stop
        segments = [a, b];
        return;
    end

    % Midpoint of current domain
    mid = (a + b) / 2;

    % Compute integrals to split sensor count
    total_integral = integral(@(x) 1 ./ h_func(x), a, b);
    left_integral = integral(@(x) 1 ./ h_func(x), a, mid);
    right_integral = total_integral - left_integral;

    % Assign number of sensors proportionally
    N_left = N * (left_integral / total_integral);
    N_right = N - N_left;

    % Recurse on each half
    left_segments = refine_recursive(h_func, a, mid, N_left);
    right_segments = refine_recursive(h_func, mid, b, N_right);

    % Merge subsegments, remove duplicate midpoint
    segments = [left_segments(1:end-1), right_segments];
end



function [spatial_sensors] = moveSpatialToTargetsPeriodically(target_sensors, sensors, speed, p)
    targets = target_sensors;
    points = sensors;
    if norm(targets-points) == 0
        spatial_sensors = points;
        return
    end
    mean_flow = speed*1.3;
    domain_length = p.Lx;

    for i = 1:length(targets)
        if i > length(points)
            break;
        end
        % Compute distance to target
        % min_index = mapping(i);
        min_index = i;
        % [~, min_index] = min(targets(i) - points);
        dist_to_target = targets(i) - points(min_index);
        
        % Account for periodic boundary conditions
        if dist_to_target > domain_length / 2
            dist_to_target = dist_to_target - domain_length;
        elseif dist_to_target < -domain_length / 2
            dist_to_target = dist_to_target + domain_length;
        end
        
        % Update position towards the target
        if (abs(dist_to_target) > mean_flow * p.dt)
            
            points(min_index) = points(min_index) + mean_flow * p.dt * sign(dist_to_target);
        else
            points(min_index) = targets(i);
        end
        
        
        % Enforce periodic boundary conditions
        if points(min_index) > domain_length
            points(min_index) = points(min_index) - domain_length;
        elseif points(min_index) < 0
            points(min_index) = points(min_index) + domain_length;
        end
    end
    spatial_sensors = (points);
end


function [sensors] = convertNToH(N, x)
low = 0;
high = 1024;
mid = (low+high)/2;
n = size(1:mid:1024, 2);
while (n ~= N)
    if n > N
        low = mid;
    else
        high = mid;
    end
    mid = (low+high)/2;
    n = size(1:mid:1024, 2);
end
sensors = x(1:mid:1024);
end

function [spatial_sensors] = getSimpleTargetSensors(h, p, start_idx)
    F_temp = griddedInterpolant(p.x, h);
    dir = 2;
    n = p.num_sensors;
    spatial_sensors = p.x(start_idx);
    while true
        if length(spatial_sensors) == n
            break;
        end
        % Get location for next sensor h^(i)
       
        % Going in the left direction
        if dir == 1
            % distance_for_next_sensor = polyval(F_temp, spatial_sensors(1));
            distance_for_next_sensor = F_temp(spatial_sensors(1));
            next_pt = spatial_sensors(1) - distance_for_next_sensor;
        % Going in the right direction
        else
            distance_for_next_sensor = F_temp(spatial_sensors(end));
            % distance_for_next_sensor = polyval(F_temp, spatial_sensors(end));
            next_pt = spatial_sensors(end) + distance_for_next_sensor;
        end
    
        % sensors = [sensors, idx];
        % Change direction when reaches end of domain
        if next_pt > p.x(end)
            dir = 1;
            continue;
            % next_pt = next_pt - Lx;
        elseif next_pt < 0
            break;
        end
        if dir == 1
            spatial_sensors = [next_pt, spatial_sensors];
        else
            spatial_sensors = [spatial_sensors, next_pt];
        end
    end
end


function plotAndSaveFigure(hfig)
fname = "myfigure";
    
picturewidth = 45; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',48) % adjust fontsize to your document

set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig,fname,'-dpdf','-vector','-fillpage')
print(hfig,fname,'-dpng','-vector')

end