function KSE()
close all;
N = 2^10;
Lx = 32*pi;
dx = Lx/N;
x = 0:dx:Lx - dx;

lambda = 1;

T = 100;
dt = 0.01;
% dt = 1.2207e-4;
show = 1e2;

mu = 100;

k = [0:N/2-1 0 -N/2+1:-1]*(2*pi/Lx);
E = exp(dt*(lambda*k.^2 - k.^4));

dealias_mask = abs(k) <= floor((2/3)*N);
% [~,dealias_modes] = find(abs(k) > floor(N*2/3));


num_timesteps = ceil(T/dt);
t = dt:dt:dt*num_timesteps;

u_hat = zeros(N,1);

u_0 = cos(x/16).*(1+sin(x/16));

u_hat = fft(u_0);


spec = generate_spectrum_1D(u_hat);
modes = 1:N/2;


soln_history = zeros(N, ceil(num_timesteps/show)+1);
soln_history(:,1) = u_0;
plot_time = [0];

ref_fig = figure;
ref_soln_plot = scatter(x, ifft(u_hat,'symmetric'));
axis([0, Lx, -3,3]);

spec_fig = figure;
spec_plot = loglog(modes, spec);

error_fig = figure;

var = [];
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

error = NaN(1,num_timesteps);
error_aot = error;

for ti = 1:ramp_up_timesteps
    nonlin_term = (1i*k/2).*fft(real(ifft(u_hat.*dealias_mask)).^2);
    u_hat = E.*(u_hat - dt*nonlin_term);
end

% AOT (nudging) solution
aot_hat = zeros(size(u_hat));
aot_hat(trunc_index) = u_hat(trunc_index);
p.x = x;
p.Lx = Lx;
p.N = N;
p.dx = dx;
p.lambda = 1;
p.mu = mu;
p.num_sensors = 33;
n = 1;
for ti = 1:num_timesteps
    u_hat_old = u_hat;
    % u_dealiased = ifft(u_hat.*dealias_mask,'symmetric');
    % u_dealiased = ifft(u_hat,'symmetric');
      nonlin_term = (1i*k/2).*fft(real(ifft(u_hat.*dealias_mask)).^2);
    % nonlin_term = fft(u_dealiased.*real(ifft(1i*k.*u_hat, 'symmetric')));

    u_hat = E.*(u_hat - dt*nonlin_term);
  

    %observe previous timestep for nudging
    % aot_obs = u_hat_old;
    ref_old_solution = ifft(u_hat_old, 'symmetric');
    
    sensors = intervalBasedTargetLocations(determineH(p, p.num_sensors , 0, ref_old_solution), p);
    [aot_obs] = fft(interpolateOntoobservationalGridAndBack(p, ref_old_solution, sensors));
    [aot_hat_obs] = fft(interpolateOntoobservationalGridAndBack(p, ifft(aot_hat, 'symmetric'), sensors));
    
    aot_hat_obs(trunc_index_comp) = 0;
    %Zero out unobserved modes on observation data
    aot_obs(trunc_index_comp) = 0;

    % aot_obs(trunc_index_comp) = 0;

    %compute nudging feedback term I_h(u-v)
    Ihumv = aot_obs - aot_hat_obs;
    %Zero out all unobserved modes
    Ihumv(trunc_index_comp) = 0;
    


    nonlin_aot = (1i*k/2).*fft(real(ifft(aot_hat.*dealias_mask)).^2);
    aot_hat = E.*(aot_hat - dt*nonlin_aot + dt*mu*(Ihumv));

    error_aot(ti) = norm(abs(u_hat - aot_hat),'fro')/N;


 





    if mod(ti,show)==0
        % u_phys = real(ifft(ensemble(1).forecast,'symmetric'));
        u_phys = real(ifft(u_hat,'symmetric'));

        soln_history(:,n+1) = u_phys;
        plot_time = [plot_time; ti*dt];
        n = n+1;

        spec = generate_spectrum_1D(u_hat);
        figure(spec_fig);
        spec_plot = loglog(modes, spec);
        hold on

        spec_aot = generate_spectrum_1D(aot_hat);
        loglog(modes, spec_aot);
        
        max(abs(spec - spec_aot))
        
        hold off;


        title(sprintf('Energy spectrum at t = %1.2f',t(ti)));


        figure(ref_fig);
        hold off;
        ref_soln_plot = plot(x, ifft(u_hat,'symmetric'));
        hold on;

        aot_soln_plot = plot(x, ifft(aot_hat,'symmetric'));
        % plot(x, ifft(abs(aot_hat - u_hat), 'symmetric'));
        
        hold off;

        title(sprintf('Reference solution at t = %1.2f',t(ti)));
        axis([0, Lx, -3,3]);
        
        % drawnow;

        figure(error_fig);
        semilogy(dt:dt:dt*length(error), error);
        hold on;
        semilogy(dt:dt:dt*length(error_aot), error_aot);
        hold off;
        title("Error computed over time");
        drawnow;
    end

end

if(plot_time(end)~= t(end))
    u_phys = real(ifft(u_hat,'symmetric'));

    soln_history(:,end) = u_phys;
    plot_time = [plot_time; t(end)];


end


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

function [vq1] = interpolateOntoobservationalGridAndBack(p, ref_solution, spatial_sensors)
    F_temp = griddedInterpolant(p.x, ref_solution);
    bsv_data = F_temp(spatial_sensors);
    x_pts = spatial_sensors';
    
    u_data1 = [bsv_data(end), bsv_data, bsv_data(1)];
    x_pts_per = [x_pts(end) - p.Lx; x_pts; x_pts(1) + p.Lx];

    F1 = griddedInterpolant(x_pts_per, u_data1.');
    vq1 = F1(p.x);
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
