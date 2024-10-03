function turnDatFile(recordName,fs,ecgData,folderName,folderVariable)

% Converts timeseries ECG data into a PhysioNet-compatible format by 
% generating a .dat file for signal data and a .hea file for header information.
% The files are saved in the 'physionetFormat' directory.

% Input: 

% Output: 
%       Produces *.dat, *.hea, *.wqrs file in a folder called folderName
%       and inside another folder called folderVariable


% Example:
%   subjects = fieldnames(interest);
%   for s = 1:length(subjects)
%       recordName = subjects{s};
%       folderName = 'physionetFormat'
%       folderVariable = 'Buffalo';
%       fs = 250;
%       ecgData = interest.(subjects{s}).Buffalo.ecg;
%       turnDatFile(recordName,fs,ecgData,folderVariable)
%   end

% By Selena Cho
% Last Updated: July 30th, 2024
    
    % Ensure recordName is a character array
    if isstring(recordName)
        recordName = char(recordName);
    end
    
    % Directory for saving files
    outputDir = fullfile(folderName,folderVariable,recordName);
    
    % Create the output directory if it doesn't exist
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Write header file
    numSamples = length(ecgData);
    numSignals = 1; % only one lead with Bittium
    headerFilePath = fullfile(outputDir, [recordName, '.hea']);
    
    fid = fopen(headerFilePath, 'w');
    if fid == -1
        error('Could not open file for writing: %s', headerFilePath);
    end
    fprintf(fid, '%s %d %d %d\n', recordName, numSignals, fs, numSamples);
    fprintf(fid, '%s.dat 16+24 1000/mV 16 0 0 0 0 ECG\n', recordName);
    fclose(fid);
    
    % Write signal data file
    dataFilePath = fullfile(outputDir, [recordName, '.dat']);
    fid = fopen(dataFilePath, 'w');
    if fid == -1
        error('Could not open file for writing: %s', dataFilePath);
    end
    fwrite(fid, ecgData, 'int16');
    fclose(fid);
    
    [signal, ~, ~] = rdsamp(fullfile(outputDir,recordName));
    N = length(signal);

    % wavelet instead of gqrs bc it's better for analyzing non-stationary signals,
    wqrs(fullfile(outputDir,recordName),N); % writes annotates *.wqrs

end