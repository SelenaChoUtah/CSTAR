function filtData = ShahFilter(vertGyro,m)
%UNTITLED Summary of this function goes here

%    Shah, V. V., et al. (2021). "Inertial Sensor Algorithms to 
%    Characterize Turning in Neurological Patients With Turn Hesitations.
%    " Ieee Transactions on Biomedical Engineering 68(9): 2615-2625.

    M = m; % Half-width of the filter

    % Generate the Epanechnikov kernel impulse response
    n = -M:M; % Discrete-time index
    h = (1 - (n/M).^2) .* (abs(n) <= M); % Epanechnikov kernel filter

    % Normalize the kernel so that it sums to 1
    h = h / sum(h);

    % Apply the weighted moving average filter to the signal
    filtData = conv(vertGyro, h, 'same');
    % % Plot the original and filtered gyro data for comparison
    % figure;
    % plot(vertGyro, 'b', 'LineWidth', 1.5);
    % hold on;
    % plot(filtData, 'r', 'LineWidth', 1.5);
    % ylabel('Angular Velocity (deg/s)');
    % legend('Original Gyro Data', 'Filtered Gyro Data');
    % title('Effect of FIR Lowpass Filtering on Gyro Data');
    % 
    % Step 2: Calculate Absolute Smoothed Rotational Rate: Calculate the 
    % smoothed vertical rotational rate with the detection filter
    % and take the absolute value. This results in a signal that contains
    % a smoothed increase that does not depend on the direction of the
    % turn. **This can turn into switch case to define left and right turns

    % absFiltData = abs(filtData);    
    
end