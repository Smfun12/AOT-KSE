function spectrum = generate_spectrum_1D(soln_hat)

[N] = length(soln_hat);
spectrum = zeros(1, N/2);


for j = 1:N/2
   
    modes = floor(abs(j));
    if modes <= N/2
        spectrum(modes) = spectrum(modes) + abs(soln_hat(j))^2;
    end
   
end
spectrum = sqrt(spectrum)/N^2;
spectrum = max(spectrum, eps);
end