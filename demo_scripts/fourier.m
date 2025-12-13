function fourierAnalysis(func, p)
    T = p.T;
    dt = 1/T;
    fs = 1 / dt;     % Sampling frequency
    N = T / dt;      % Number of samples
    t = 0:dt:T; % Time vector
    
    % Example signal (replace with your function)
    % Example: A combination of two sine waves
    f1 = 5;          % Frequency 1 (Hz)
    f2 = 20;          % Frequency 2 (Hz)
    % signal = sin(2*pi*f1*t) + sin(2*pi*f2*t);
    signal = func;
    N = length(signal);
    % Fourier Transform
    fftSignal = fft(signal);
    P2 = abs(fftSignal / N);       % Two-sided spectrum
    P1 = P2(1:ceil(N/2));              % Single-sided spectrum
    P1(2:end-1) = 2*P1(2:end-1);   % Adjust for symmetry
    frequencies = fs * (0:(N/2)) / N;
    % frequencies = fftshift(frequencies);
    % Find the dominant frequency
    [~, idx] = max(P1);            % Index of maximum magnitude
    dominantFrequency = frequencies(idx);
    
    
    % Plot
    figure;
    subplot(2,1,1);
    plot(t, signal, "LineWidth", 2);
    title('Original Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    fontsize(24, "points")
    subplot(2,1,2);
    plot(frequencies, P1, "LineWidth",2);
    title('Single-Sided Amplitude Spectrum');
    xlabel('Frequency (Hz)');
    ylabel('|P1(f)|');
    % xlim([0, 10]); % Adjust as needed
    grid on;
    fontsize(24, "points")
    
    % Display dominant frequency
    disp(['Dominant Frequency: ', num2str(dominantFrequency), ' Hz']);

end