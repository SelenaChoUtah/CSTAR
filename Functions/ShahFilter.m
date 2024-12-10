function filtData = ShahFilter(vertGyro,duration,fs)
%UNTITLED Summary of this function goes here

%    Shah, V. V., et al. (2021). "Inertial Sensor Algorithms to 
%    Characterize Turning in Neurological Patients With Turn Hesitations.
%    " Ieee Transactions on Biomedical Engineering 68(9): 2615-2625.

    % M = 75.5; % Half-width of the filter
    % impDuration = (2*M)/100;
    % disp(impDuration)
    % 
    % % Generate the Epanechnikov kernel impulse response
    % n = -M:M; % Discrete-time index
    % h = (1 - (n/M).^2) .* (abs(n) <= M); % Epanechnikov kernel filter
    % 
    % % Normalize the impulse response to ensure it sums to 1
    % h = h / sum(h);

    
    % Calculate M (half-width of the filter)
    M = round((duration * fs) / 2);
    
    % Create the impulse response
    n = -M:M;
    h = (1 - (n/M).^2) .* (abs(n) <= M);%1 - (n/M).^2;
    h = h / sum(h);  % Normalize to ensure unity gain at DC


    % % Plot the impulse response
    % figure;
    % stem(n, h, 'filled');
    % title('Epanechnikov Kernel Impulse Response');
    % xlabel('n (samples)');
    % ylabel('h[n]');
    % grid on;

    % Apply the weighted moving average filter to the signal
    filtData = conv(vertGyro, h, 'same');

    % % Plot the original and filtered gyro data for comparison
    % figure
    % plot(vertGyro, 'b', 'LineWidth', 1.5);
    % hold on;
    % plot(filtData, 'r', 'LineWidth', 1.5);
    % ylabel('Angular Velocity (deg/s)');
    % legend('Original Gyro Data', 'Filtered Gyro Data');
    % title('Effect of FIR Lowpass Filtering on Gyro Data');

    
end