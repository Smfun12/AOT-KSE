function KSE_generatebasis()
close all; clear; close all;
N = 2^10;
Lx = 32*pi;
dx = Lx/N;
x = 0:dx:Lx - dx;

lambda = 1;
datas = [];
T = 30;
dt = 0.01;
% dt = 1.2207e-4;
show = 100;

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

    % u_dealiased = ifft(u_hat.*dealias_mask,'symmetric');
    % u_dealiased = ifft(u_hat,'symmetric');

    nonlin_term = (1i*k/2).*fft(real(ifft(u_hat.*dealias_mask)).^2);
    % nonlin_term = fft(u_dealiased.*real(ifft(1i*k.*u_hat, 'symmetric')));

    u_hat = E.*(u_hat - dt*nonlin_term);

end


% figure;
% for j = 1:M

    % ens_phys = real(ifft(ensembles(j).forecast,'symmetric'));
    % plot(x, ens_phys);
    % hold on;

% end



tol = .1;
reset_times = [];

% AOT (nudging) solution
aot_hat = zeros(size(u_hat));
aot_hat(trunc_index) = u_hat(trunc_index);

n = 1;
for ti = 1:num_timesteps
    u_hat_old = u_hat;
    % u_dealiased = ifft(u_hat.*dealias_mask,'symmetric');
    % u_dealiased = ifft(u_hat,'symmetric');
      nonlin_term = (1i*k/2).*fft(real(ifft(u_hat.*dealias_mask)).^2);
    % nonlin_term = fft(u_dealiased.*real(ifft(1i*k.*u_hat, 'symmetric')));

    u_hat = E.*(u_hat - dt*nonlin_term);
  

    %observe previous timestep for nudging
    aot_obs = u_hat_old;
    %Zero out unobserved modes on observation data
    aot_obs(trunc_index_comp) = 0;

    % aot_obs(trunc_index_comp) = 0;

    %compute nudging feedback term I_h(u-v)
    Ihumv = aot_obs - aot_hat;
    %Zero out all unobserved modes
    Ihumv(trunc_index_comp) = 0;
    
    real_solution = ifft(u_hat, "symmetric");
    datas = [datas; real_solution];
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
        
        max(abs(spec - spec_aot));
        
        
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

save("big_basis_kse.mat", "datas")
figure;
% surf(soln_history);
% surf(soln_history);
% shading interp;
% surf([0,t],x,soln_history), shading interp, lighting phong, axis tight
surf(plot_time,x,soln_history), shading interp, lighting phong, axis tight
view([-90 90]), colormap(autumn);
% colormap(autumn);
light('color',[1 1 0],'position',[-1,2,2])
material([0.30 0.60 0.60 40.00 1.00]);
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

function noisy_obs = generate_noise(variance,N)
% % psi_hat_size = size(psi_hat);
% % phi_v1 = p.noise_level*randn(psi_hat_size);
% % phi_v2 = p.noise_level*randn(psi_hat_size);
%
% % phi_v1_hat = fft2(phi_v1);
% % phi_v2_hat = fft2(phi_v2);
%
% noise = p.noise_level * (randn([N,p.Ny]));% + 1i*randn(size(p.ikx)));
%
% noise = fft2(noise);
%
% % Generate Gaussian white noise for potential field in Fourier space
% % noise = p.noise_level * (randn([N,p.Ny]));% + 1i*randn(size(p.ikx)));
% noise(1,1) = 0;
% noise(p.trunc_array == 1) = 0;

% Define the size of your 1D domain
% N = p.Nx;



% Generate the noise in Fourier space
noise_fourier_space = variance*(randn(N/2,1)+1i*(randn(N/2, 1)));
% noise_fourier_space = settings.noise_level*(randn(N, N/2+1) + 1i * randn(N, N/2+1));

% Set the 0 wave mode to 0
noise_fourier_space(1) = 0 + 0i;

% Create the complex conjugate mirrored version of your noise
noise_fourier_space_full = zeros(N, 1);
% noise_fourier_space_full(:, 1:N/2+1) = noise_fourier_space;
% Flipud function flips the array up down, and fliplr function flips it left to right


noise_fourier_space_full(1:N/2) = noise_fourier_space;
pos_freq = 2:N/2;

noise_fourier_space_full(N - pos_freq + 2) =  conj(noise_fourier_space(pos_freq));
% conj function takes the complex conjugate
% noise_fourier_space_full(:, N/2+2:N) = rot90(conj(noise_fourier_space(:, 2:N/2)),2);

% %Rescale noise based on wave mode (pink noise)
% % Define the wave numbers kx and ky
% % [kx, ky] = meshgrid(-N/2:N/2-1, -N/2:N/2-1);
% % k = sqrt(kx.^2 + ky.^2);
% k = p.kx.^2 + p.ky.^2;
% % Define your scaling function and apply it to the noise
% scaling = (k ~= 0) ./ (k + (k==0));  % avoid division by zero at (0,0), this makes the scaling to 1/k
% noise_fourier_space_full = noise_fourier_space_full .* scaling;
%
% % Inverse Fourier transform the noise back to real space
% noise_real_space = ifft2(noise_fourier_space_full, 'symmetric');

noisy_obs = noise_fourier_space_full;


end
