%-------------------------------------------------------------------------%
function opal = opalPreProcess(subjectnum)

% The opalPreProcess function is designed to process data from 
% Moveo sensors for a given subject. It takes a subjectnum input, 
% which is expected to be a structure containing information about
% the subject's folder. The processed data is organized into a 
% structured format named opal, which includes acceleration and
% gyroscope readings from different body locations for various conditions.

% Input: 
%     subjectnum: A structure representing information about 
%     the subject's folder. It is typically obtained using 
%     the dir function.

% Example input directory structure:
%     'DHI001'	'C:\Users\chose\DHI\subjects'	'24-Jan-2024 13:24:27'	0	true	739275.558645833
%     'DHI002'	'C:\Users\chose\DHI\subjects'	'24-Jan-2024 14:22:57'	0	true	739275.599270833

% Output: 
%     opal: A structured data format containing processed 
%     sensor data organized by condition, body location, 
%     and sensor type.

% Example output structure:
%     opal."subjectID"."condition"."sensorLocation"."data"

%     "subjectID" = DHI001
%     "condition" = i.e., supine2stand, sit2stand
%     "sensorLocation" = head, sternum, lumbar, timepoint
%         **IT CONTAINS THE START TIME OF THE TASK!!!!!**
%     "data" = acc, gyro, time(array of time with length of trial)

% By Selena Cho
% Last Updated: Jan 24th, 2024

%-------------------------------------------------------------------------%

    % Obtain subfolder information
    subfolder = dir([subjectnum.folder filesep subjectnum.name]);
    ind = find(contains({subfolder.name},'Moveo'));

    % find csv files
    csvpath = [subfolder(ind).folder filesep subfolder(ind).name filesep];
    
    % Get a list of all CSV files in the folder
    filePattern = fullfile(csvpath, '*.csv');
    csvFiles = dir(filePattern);

    % Initialize an empty table to store the combined data
    combinedCsv = table();

    % Loop through each CSV file and concatenate its data
    for i = 1:length(csvFiles)
        filename = fullfile(csvpath, csvFiles(i).name);
        opts = detectImportOptions(filename); % Detect the options (including variable names)
        opts.VariableNamesLine = 1; % Specify that the first row contains variable names
        opts.Delimiter = ',';
    
        data = readtable(filename, opts); % Read the CSV file
        select = data(:,1:8);
        
        % Concatenate the data to the combinedData table
        combinedCsv = [combinedCsv; select];
    end
    
    combinedCsv = sortrows(combinedCsv,"RecordDate_Time_UTC_","ascend"); 

    % Define Conditions for DHI
    LL = 1;
    RR = 1;
    OO = 1;
    CC = 1;
    TT = 1;
    SP = 1;
    SC = 1;
    VOR = 1;
    
    for c = 1:height(combinedCsv.Condition)
        condition = char(combinedCsv.Condition{c});
    
        switch condition
            case 'StandOnLeftLeg'
                order = {'left1','left2'};
                combinedCsv.Condition{c} = order{LL};
                LL = LL + 1;
            case 'StandOnRightLeg'
                order = {'right1','right2'};
                combinedCsv.Condition{c} = order{RR};
                RR = RR + 1;
            case 'CompensatoryOpen'
                order = {'openfront', 'openback', 'openleft', 'openright'};
                combinedCsv.Condition{c} = order{OO};
                OO = OO + 1;
            case 'CompensatoryClosed'
                order = {'closefront', 'closeback', 'closeleft', 'closeright'};
                combinedCsv.Condition{c} = order{CC};
                CC = CC + 1;
            case '3m Walkway'
                order = {'singletug','dualtug'};
                combinedCsv.Condition{c} = order{TT};
                TT = TT + 1;
            case 'SmoothPursuits'
                order = {'spHori','spVert'};
                combinedCsv.Condition{c} = order{SP};
                SP = SP+1;
            case 'Saccades'
                order = {'scHori','scVert'};
                combinedCsv.Condition{c} = order{SC};
                SC = SC+1;
            case 'Vestibular-Ocular Reflex (VOR) Test'
                order = {'vorHori','vorVert'};
                combinedCsv.Condition{c} = order{VOR};
                VOR = VOR+1;
            case ' Visual Motion Sensitivity'
                combinedCsv.Condition{c} = {'VMS'};
            case 'One-TIme'
                combinedCsv.Condition{c} = {'sit2stand'};
        end
    end    

    % Load the data
    moveopath = [subfolder(ind).folder filesep subfolder(ind).name filesep 'rawData' filesep];
    moveofolder = dir([subfolder(ind).folder filesep subfolder(ind).name filesep 'rawData' filesep]);
    moveofolder = moveofolder(~ismember({moveofolder.name}, {'.', '..'}));    

    for t = 1:height(combinedCsv)
        % Convert datetime to hours:minutes:seconds
        time = datetime(combinedCsv.RecordDate_Time_UTC_(t), 'InputFormat', 'yyyyMMdd-HHmmss','TimeZone','UTC','Format','HH:mm:ss');
        time.TimeZone = 'America/Denver';
        opal.(string(combinedCsv.Condition(t))).timepoint = time;
        
        fsr = 100;
        % read data
        raw = readOpalData_v2([moveopath moveofolder(t).name]);
        % align data *accelerometer structure make sure saved correctly
        rrData = alignOpals_v2(raw,fsr);    
        

        for i = 1:length(raw.sensor)
            if strncmp(rrData.sensor(i).monitorLabel,"Forehead",4)
                sens = "head";        
            elseif strncmp(rrData.sensor(i).monitorLabel,"Lumbar",4)
                sens = "lumbar";
            elseif strncmp(rrData.sensor(i).monitorLabel,"Sternum",4)
                sens = "sternum";
            end            
            opal.(string(combinedCsv.Condition(t))).(sens).acc = [rrData.sensor(i).acceleration];
            opal.(string(combinedCsv.Condition(t))).(sens).gyro = [rrData.sensor(i).rotation];
            opal.(string(combinedCsv.Condition(t))).(sens).time = (0:1/fsr:(length(opal.(string(combinedCsv.Condition(t))).(sens).acc)-1)/fsr);            
            
            % Rotate Correctly for supine2stand, it starts lying down
            % unlike other trials
            if strcmp(string(combinedCsv.Condition(t)),"supine2stand")
                opal.(string(combinedCsv.Condition(t))).(sens).acc = SelectRotateVector(opal.(string(combinedCsv.Condition(t))).(sens).acc);
            end
        end
    end

end
