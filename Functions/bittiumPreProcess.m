function bittium = bittiumPreProcess(subjectnum)

% The bittiumPreProcess function is designed to process data from 
% the Bittium Faros 180. The edf reader pulls it in a timetable
% where every second has the 250 samples (aka fs=250hz) which 
% makes it difficult to use. It then concatenates all the data to
% one variable for better processing. It also rotates the 
% acceleration vector to face down so it is consistent with the 
% opal sensors. 

% Input: 
%     subjectnum: A structure representing information about 
%     the subject's folder. It is typically obtained using 
%     the dir function.

% Example input directory structure:
%     'DHI001'	'C:\Users\chose\DHI\subjects'	'24-Jan-2024 13:24:27'	0	true	739275.558645833
%     'DHI002'	'C:\Users\chose\DHI\subjects'	'24-Jan-2024 14:22:57'	0	true	739275.599270833

% Output: 
%     bitium: A structured data format containing preprocessed 
%     sensor data.

% Example output structure:
%     opal."subjectID"."condition"."sensorLocation". "data"
%     "subjectID" = DHI001
%     "condition" = i.e., supine2stand, sit2stand
%     "sensorLocation" = head, sternum, lumbar, timepoint
%         **IT CONTAINS THE START TIME OF THE TASK!!!!!**
%     "data" = acc, gyro, time(array of time with length of trial)


% By Selena Cho
% Last Updated: Jan 31st, 2024


%%

    % Find .edf files
    edfFiles = dir(fullfile(subjectnum.folder, subjectnum.name, '*.EDF'));
    bitPath = fullfile(edfFiles.folder,edfFiles.name);

    bitInfo = edfinfo(bitPath);
    time = datetime(bitInfo.StartTime, 'InputFormat', 'HH.mm.ss', 'Format', 'HH:mm:ss');    
    bitraw = edfread(bitPath);

    % Rotate Axes to align with global frame
    ecg = [];  
    accX = [];
    accY = [];
    accZ = [];
    for i = 1:height(bitraw)
        ecg = [ecg;bitraw.ECG{i,:}];
        accX = [accX;-bitraw.Accelerometer_Z{i,:}];
        accY = [accY;-bitraw.Accelerometer_Y{i,:}];
        accZ= [accZ;bitraw.Accelerometer_X{i,:}];
    end

    fsAcc = length(bitraw.Accelerometer_X{1,1});
    acc = [accX accY accZ];
    accR = resample(acc, fsAcc, fsAcc);
    bittium.acc = alignBittiumAcc(accR);
    bittium.fsAcc = fsAcc;
    
    bittium.startTime = datetime(bitInfo.StartTime,'InputFormat','HH.mm.ss', 'Format', 'HH:mm:ss','TimeZone','America/Denver');
    bittium.accTime = string(bittium.startTime + seconds(1/fsAcc:1/fsAcc:height(bitraw)))';

    fsEcg = length(bitraw.ECG{1,1});
    bittium.ecg = ecg;
    bittium.ecgTime = string(bittium.startTime + seconds(1/fsEcg:1/fsEcg:height(bitraw)))'; 
    bittium.fsEcg = fsEcg;

    fsr = 100;
    bittium.ecgDS = resample(ecg,fsr,fsEcg);

end



