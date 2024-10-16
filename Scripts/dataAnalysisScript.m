addpath(genpath('Data\'))
addpath(genpath('CSTAR\'))
%%
currentFoldPath = cd;

preprocessPath = dir(fullfile(currentFoldPath,'\Data\PreProcess'));
preprocessPath = preprocessPath(~ismember({preprocessPath.name}, {'.', '..'}));
subjectnum = preprocessPath(listdlg('PromptString',{'Select Subjects to Process (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{preprocessPath.name}));

for i = 1:numel(subjectnum)     
    % Save Data into Process
    id = string(subjectnum(i).name);
    disp(id)    
    clearvars data saveData rotate       
    % Load Data
    dayPath = dir(fullfile(subjectnum(i).folder,subjectnum(i).name));
    dayPath = dayPath(~ismember({dayPath.name}, {'.', '..'}));

    % Gonna try all the days
    % remove the first and last day because they're not full 24 hour
    for d = 1:length(dayPath)
        data.(id).(dayPath(d).name) = load(fullfile(dayPath(d).folder,dayPath(d).name,filesep,'data.mat'));
    end            

    % McCamley Step Detection - use waist or else neck    
    daynum = fieldnames(data.(id));   
    try
        for j = 1:length(daynum)
            sensor = fieldnames(data.(id).(daynum{j}));
            for s = 1:length(sensor)
                vertAcceleration = data.(id).(daynum{j}).(sensor{s}).acc(:,3);
                [stepInfo, calibrate] = mcCamleyStepDetection(vertAcceleration);
                stepData.(daynum{j}).(sensor{s}) = stepInfo;
                calibrateData.(daynum{j}).(sensor{s}) = calibrate;
                saveData.stepData.(daynum{j}).(sensor{s}) = stepInfo;                  
            end
        end

        % Apply Rotation Matrix to Long periods of walking        
        daynum = fieldnames(data.(id));        
        for j = 1:length(daynum)          
            try
            sensor = fieldnames(data.(id).(daynum{j}));
            for s = 1:length(sensor)
                try 
                vertAcc = data.(id).(daynum{j}).(sensor{s}).acc;                
                wearTimeStruct = wearTime(vertAcc,100);
                saveData.timeData.(daynum{j}).(sensor{s}) = wearTimeStruct;  
                saveData.timeData.(daynum{j}).(sensor{s}).dayLength = length(vertAcc);

                fullWindow = calibrateData.(daynum{j}).(sensor{s}).fullWindow;
                calibrateWindow = calibrateData.(daynum{j}).(sensor{s}).calibrateWindow;
                accData = data.(id).(daynum{j}).(sensor{s}).acc;
                gyroData = data.(id).(daynum{j}).(sensor{s}).gyro;
                order = 4;
                Fc = 40;
                Fs = 100;

                % Rotating Accelerometer
                [A_data,Rot_data] = rotateIMU(accData,4,40,100,fullWindow,calibrateWindow);
                % Rotate Gyroscope
                [G_data] = rotateGyro(gyroData,Rot_data,order,Fc,Fs,fullWindow,calibrateWindow);

                rotate.(id).(daynum{j}).(sensor{s}).acc = A_data;
                rotate.(id).(daynum{j}).(sensor{s}).gyro = G_data;
                rotate.(id).(daynum{j}).(sensor{s}).time = data.(id).(daynum{j}).(sensor{s}).time;

                % Turning Algo
                rawGyro = rotate.(id).(daynum{j}).(sensor{s}).gyro(:,3);
                m = 30;
                filterData = ShahFilter(rawGyro,m);               
                threshold = 15; % minimum deg/s turning angular velocity for head turn
                minima = 5; % start and end of head turn                
                turnInfo = ShahTurn(filterData,rawGyro,threshold,minima,m);
                saveData.turnData.(daynum{j}).(sensor{s}) = turnInfo;
                catch
                    disp(append('Error within Calibration, Sensor: ',sensor{s},' ',daynum{j}))
                end
            end
        
            % Head on Trunk Analysis
            try
            if ismember({'head', 'waist'}, sensor)                
                head = data.(id).(daynum{j}).('head').gyro(:,3);                
                waist = data.(id).(daynum{j}).('waist').gyro(:,3);
                h = length(head);
                w = length(waist);                
                startstop = saveData.turnData.(daynum{j}).('head').startstop;
                if h < w
                    hot = head-waist(1:h);
                    count = headOnTrunk(hot,startstop);
                else
                    hot = head(1:w)-waist;
                    count = headOnTrunk(hot,startstop);
                end  
                 saveData.headOnTrunkCount.(daynum{j}) = count;
                 saveData.individual.(daynum{j}) = length(startstop);
            else
                disp(append('Missing sensor(s) for Head-on-Trunk  Sensor: ',sensor{s},' ',daynum{j}))
            end
            catch 
            end   

            catch
                disp(append("Day did not work ",daynum{j}))
            end
        end        
        
        % Save 
        try
            subIDFold = strcat(currentFoldPath,'\Data\Process\', id,filesep);
            if ~isfolder(subIDFold)
                mkdir(subIDFold)
            end
            savePath = strcat(subIDFold,'data.mat');
            save(savePath, '-struct','saveData');
        catch
            disp('didnt save')
        end

    catch
        disp(append('Error with Subject: ', id))
    end
end

%%
clc
figure
for d = 1:length(daynum)
    nexttile
    plot(saveData.timeData.(daynum{d}).head.activityCounts)
    title(num2str(d))
    disp(saveData.timeData.(daynum{d}).head.nonwearTime)
end
