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

id = fieldnames(data);
figure
close all
for ii = 1:length(id)
    try
    sensor = "head";
    task = "gaitPivot";
    gyro = data.(id{ii}).(task).(sensor).gyro(:,3);
    impulseDuration = 1.476;
    filterData = ShahFilter(gyro,impulseDuration,100);    
    % break
    amplitudeThreshold = 10; % minimum amplitude for head turn
    velocityThreshold = 15; % deg/s peak velocity to quantify as turn
    minima = 5; % Local Minima     
    impulseDuration = 0.2; % Larger value means more smoothed
    turnInfo.(id{ii}) = absShahTurn(filterData,gyro,minima,amplitudeThreshold,velocityThreshold,impulseDuration);
    nexttile
    hold on
    plot(gyro)
    plot(turnInfo.(id{ii}).startstop,gyro(turnInfo.(id{ii}).startstop),'*')
    title(id{ii})
    % disp(height(turnInfo.(id{ii}).startstop))
    % disp(append("Turn Amplitude: ", num2str(abs(180-turnInfo.(id{ii}).amplitude))))
    disp(append("Turn Amplitude: ", num2str(turnInfo.(id{ii}).amplitude(end))))
    catch
    end
end

