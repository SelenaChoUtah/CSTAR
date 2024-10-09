%% Testing head turns on simple in-lab

currentFoldPath = cd;

processPath = dir(fullfile(currentFoldPath,'\Data\preprocess\axivity'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

% Load Data 
for ii = 1:numel(subjectnum)
    id = string(subjectnum(ii).name);
    % disp(id)   
    data.(id) = load(fullfile(subjectnum(ii).folder,subjectnum(ii).name,'data.mat'));   
end

clearvars -except data currentFoldPath


%% Using head turn filters to detect head turn


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

