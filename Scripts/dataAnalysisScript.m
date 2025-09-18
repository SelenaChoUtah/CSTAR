cd('C:\Users\chose\Box\C-STAR Pilot')
addpath(genpath('Data\'))
addpath(genpath('CSTAR\'))

%%
cd('D:\CSTAR')
addpath(genpath('Data\'))
currentFoldPath = cd;
% CSTAR
preprocessPath = dir(fullfile(currentFoldPath,'\Data\PreProcess'));
% DHI-Lab
% preprocessPath = dir(fullfile(currentFoldPath,'\PreprocessData\Continuous'));
preprocessPath = preprocessPath(~ismember({preprocessPath.name}, {'.', '..'}));
subjectnum = preprocessPath(listdlg('PromptString',{'Select Subjects to Process (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{preprocessPath.name}));

for i = 1:numel(subjectnum)     
    % Save Data into Process
    id = string(subjectnum(i).name);
    disp(id)    
    clearvars data saveData rotate rotate2   
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
            fprintf("%s\n", daynum{j});
            try
            sensor = fieldnames(data.(id).(daynum{j}));
            for s = 1:length(sensor)
                try 
                vertAcc = data.(id).(daynum{j}).(sensor{s}).acc;                
                wearTimeStruct = wearTime(vertAcc,100);
                saveData.timeData.(daynum{j}).(sensor{s}) = wearTimeStruct;  
                saveData.timeData.(daynum{j}).(sensor{s}).dayLength = length(vertAcc);
                [~,DayName] = weekday(data.(id).(daynum{j}).(sensor{s}).time(1));
                saveData.timeData.(daynum{j}).(sensor{s}).dayOfWeek = DayName;

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
                gyro = rotate.(id).(daynum{j}).(sensor{s}).gyro(:,3);
                impulseDuration = 1.476;
                filterData = ShahFilter(gyro,impulseDuration,100); 

                amplitudeThreshold = 10; % deg minimum amplitude for head turn
                velocityThreshold = 15; % deg/s peak velocity to quantify as turn
                minima = 5; % Local Minima     
                impulseDuration = 0.2; % Larger value means more smoothed
                turnInfo.(id) = absShahTurn(filterData,gyro,minima,amplitudeThreshold,velocityThreshold,impulseDuration);
                saveData.turnData.(daynum{j}).(sensor{s}) = turnInfo.(id);

                % Calibrate the sensor via largest walking bout
                [~,c] = max(calibrateWindow(:,2)-calibrateWindow(:,1));                
                maxCali = calibrateWindow(c,:);                  

                accData = data.(id).(daynum{j}).(sensor{s}).acc;
                gyroData = data.(id).(daynum{j}).(sensor{s}).gyro;
                maxFull = [1 length(accData)];
                order = 4;
                Fc = 40;
                Fs = 100;

                % Rotating Accelerometer
                [A_data2,Rot_data2] = rotateIMU(accData,4,40,100,maxFull,maxCali);
                % Rotate Gyroscope
                [G_data2] = rotateGyro(gyroData,Rot_data2,order,Fc,Fs,maxFull,maxCali);

                rotate2.(id).(daynum{j}).(sensor{s}).acc = A_data2;
                rotate2.(id).(daynum{j}).(sensor{s}).gyro = G_data2;
                rotate2.(id).(daynum{j}).(sensor{s}).time = data.(id).(daynum{j}).(sensor{s}).time;

                % Turning Algo
                gyro2 = rotate2.(id).(daynum{j}).(sensor{s}).gyro(:,3);
                impulseDuration = 1.476;
                filterData = ShahFilter(gyro2,impulseDuration,100); 

                amplitudeThreshold = 10; % deg minimum amplitude for head turn
                velocityThreshold = 15; % deg/s peak velocity to quantify as turn
                minima = 5; % Local Minima     
                impulseDuration = 0.2; % Larger value means more smoothed
                turnInfo2.(id) = absShahTurn(filterData,gyro2,minima,amplitudeThreshold,velocityThreshold,impulseDuration);
                saveData.turnDataCali.(daynum{j}).(sensor{s}) = turnInfo2.(id);
                
                catch
                    disp(append('Error within Calibration, Sensor: ',sensor{s},' ',daynum{j}))
                end
            end
        
            % Head on Trunk Analysis
            % fprintf("All Head Counts: %f\n", length(saveData.turnData.(daynum{j}).head.amplitude));  
            try
            if ismember({'head', 'neck', 'waist'}, sensor) 
                impulseDuration = 1.476;
                head = abs(data.(id).(daynum{j}).('head').gyro(:,3));
                neck = abs(data.(id).(daynum{j}).('neck').gyro(:,3));
                waist = abs(data.(id).(daynum{j}).('waist').gyro(:,3));
                h = length(head);
                n = length(neck);
                w = length(waist);                
                startstop = saveData.turnData.(daynum{j}).('head').startstop;
                if h < w || h < n
                    % neck
                    hot = ShahFilter(head-neck(1:h),impulseDuration,100);  
                    neckCount = headOnTrunk(hot,startstop,head,neck(1:h));
                    % waist
                    hot = ShahFilter(head-waist(1:h),impulseDuration,100); 
                    waistCount = headOnTrunk(hot,startstop,head,waist(1:h));
                else
                    % neck
                    hot = ShahFilter(head(1:n)-neck,impulseDuration,100); 
                    neckCount = headOnTrunk(hot,startstop,head(1:n),neck);
                    % waist
                    hot = ShahFilter(head(1:w)-waist,impulseDuration,100); 
                    waistCount = headOnTrunk(hot,startstop,head(1:w),waist);
                end  
                 saveData.headOnNeckCount.(daynum{j}) = neckCount;
                 saveData.headOnTrunkCount.(daynum{j}) = waistCount;
                 saveData.individual.(daynum{j}) = length(startstop);
                 
            else
                disp(append('Missing sensor(s) for Head-on-Trunk  Sensor: ',sensor{s},' ',daynum{j}))
            end
            catch 
                fprintf("Da Heck - %s\n", daynum{j});
            end 

            catch
                disp(append("Day did not work ",daynum{j}))
            end
        end             
        % Save 
        try
            % CSTAR
            subIDFold = strcat(currentFoldPath,'\Data\Process\', id,filesep);
            % DHI-Lab
            % subIDFold = strcat(currentFoldPath,'\ProcessData\Continuous\', id,filesep);
            % 
            if ~isfolder(subIDFold)
                mkdir(subIDFold)
            end
            savePath = strcat(subIDFold,'data.mat');
            save(savePath, '-struct','saveData');
            disp(append('Save ', id))
        catch
            disp('didnt save')
        end

    catch
        disp(append('Error with Subject: ', id))
    end
end

