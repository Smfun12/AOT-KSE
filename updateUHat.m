
function [u_hat] = updateUHat(p, u_hat)
    ramp_up_timesteps = floor(50/p.dt);
    
    
    for ti = 1:ramp_up_timesteps
    
        nonlin_term = (1i*p.k/2).*fft(real(ifft(u_hat.*p.dealias_mask)).^2);
        u_hat = p.E.*(u_hat - p.dt*nonlin_term);
    
    end
end
