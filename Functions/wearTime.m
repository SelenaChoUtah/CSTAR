function time = wearTime(vertAcc,fs)
%UNTITLED2 Summary of this function goes here

% This function is designed to generate activity counts
% and classify accelerometer wear and nonwear time intervals 
% Based on the following paper:
%     Choi L, Liu Z, Matthews CE, Buchowski MS. Validation of 
%     accelerometer wear and nonwear time classification algorithm. 
%     Med Sci Sports Exerc. 2011 Feb;43(2):357-64. 
%     doi: 10.1249/MSS.0b013e3181ed61a3. 

% General idea: Takes the vert acc signal and resamples it to 30Hz

% Input: 
%     acc: vertical accelerometer signal

% Output: 
%     time.nonwearTime = nonwear time (hours)
%     time.wearTime = wear time (hours)

% By Selena Cho
% Last Updated: Aug 20th, 2024

%-------------------------------------------------------------------------%
    % Simulate ActiGraph Counts Calculation
    fsr = 30;  % Resample
    acc = resample(vertAcc,fsr,fs);  
    % t = 0:1/fsr:(length(acc)-1)/fsr;
    
    % Parameters for count calculation
    epoch_length = 60;  % Epoch length in seconds
    epoch_samples = epoch_length * fsr;  % Number of samples per epoch
    high_pass_cutoff = 0.25;  % High-pass filter cutoff frequency in Hz
    low_pass_cutoff = 10;  % Low-pass filter cutoff frequency in Hz
    
    % 1. Filter the raw acceleration signal
    % Design band-pass filter (Butterworth)
    [b, a] = butter(4, [high_pass_cutoff, low_pass_cutoff] / (fsr / 2), 'bandpass');
    filtered_acceleration = filtfilt(b, a, acc);
    
    % 2. Divide the filtered signal into epochs and calculate counts
    num_epochs = floor(length(filtered_acceleration) / epoch_samples);
    counts = zeros(1, num_epochs);
    
    for i = 1:num_epochs
        % Extract the current epoch data
        epoch_data = filtered_acceleration((i-1)*epoch_samples + 1:i*epoch_samples);
        
        % 3. Calculate the signal magnitude for the epoch
        epoch_magnitude = sum(abs(epoch_data));
        
        % 4. Scale and truncate to get counts (example scaling factor)
        scaling_factor = 1;  % This is an example scaling factor
        epoch_count = epoch_magnitude * scaling_factor;
        
        % 5. Truncate for max acc value
        truncation_level = 32767;  % (16-bit integer max value)
        counts(i) = min(epoch_count, truncation_level);
    end
        
    % % Plot the filtered acceleration data and counts
    % figure
    % subplot(2,1,1);
    % plot(t, filtered_acceleration);
    % title('Filtered Acceleration Data');
    % xlabel('Time (s)');
    % ylabel('Acceleration (g)');
    % 
    % subplot(2,1,2);
    % bar(round(counts./3));
    % title('ActiGraph Counts per Epoch');
    % xlabel('Epoch Number');
    % ylabel('Counts');

    % Calculate wear time    
    finalCounts = round(counts);
    time.nonwearTime = length(find(finalCounts<=1))/60;
    time.wearTime = length(find(finalCounts>1))/60;
    time.activityCounts = finalCounts;

end