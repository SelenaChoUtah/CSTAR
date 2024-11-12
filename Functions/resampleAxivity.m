function subject = resampleAxivity(subjectnum)

%   resampleAxivity Resamples Axivity CWA data and organizes it into a structured format.
%
%   SUBJECT = RESAMPLEAXIVITY(SUBJECTNUM) processes Axivity CWA data for each subject 
%   specified in SUBJECTNUM and organizes it into a structured format. The function 
%   resamples the data to a specified sampling frequency (100 Hz in this case) and 
%   stores it in a hierarchical structure where data is organized by subject ID and 
%   sensor location.
%
%   Input:
%       SUBJECTNUM: A structure array containing information about each subject's folder
%                   and name, typically obtained using the dir function.
%
%   Output:
%       SUBJECT: A structured data format containing resampled sensor data for each 
%                subject. Data is organized by subject ID and sensor location.
%
%   Example input directory structure:
%       'DHI001'	'C:\Users\chose\DHI\subjects'	'24-Jan-2024 13:24:27'	0	true	739275.558645833
%       'DHI002'	'C:\Users\chose\DHI\subjects'	'24-Jan-2024 14:22:57'	0	true	739275.599270833
%
%   Example output structure:
%       subject."subjectID"."sensorLocation"."data"
%           - "subjectID" : e.g., 'S01'
%           - "sensorLocation" : e.g., 'head', 'neck', 'waist'
%           - "data" : time information, Resampled sensor data (tri-acceleration, tri-gyroscope) 
%
%   By Selena Cho
%   Last Updated: April 1st, 2024

%-------------------------------------------------------------------------%
    
    % fprintf("Loading and resampling raw data\n")
    
    % Initialize the subject structure
    subject = struct();

    % Loop through each subject
    for i = 1:length(subjectnum)    
        % Get the list of CWA files in the subject's folder
        subFolder = dir(fullfile(subjectnum(i).folder,subjectnum(i).name,'*.cwa'));
        
        % Loop through each CWA file
        for j = 1:length(subFolder)
            % Extract Sensor Location for naming
            imuLocation = extractBetween(subFolder(j).name, 13, '.cwa');
            
            % Resample Data
            imuPath = fullfile(subFolder(j).folder,subFolder(j).name);
            imuData = resampleCWA(imuPath, 100);   
            
            % Store data in the subject structure
            subject.(string(subjectnum(i).name)).(string(imuLocation)) = imuData; 
        end
    end
end