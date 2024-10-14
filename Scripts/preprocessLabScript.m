%% Add Paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% addpath(genpath(pwd))
clear
addpath('Data\')
addpath(genpath('RawData\'))
addpath('CSTAR\')
addpath('Analysis\')


%--------------------------------------------------------------------------
% This script preprocesses data for multiple subjects and sessions,
% particularly focusing on APDM OPAL and Bittium data. It involves:
% 1. Selecting sessions and subjects to process.
% 2. Preprocessing the selected data.
% 3. Segmenting Bittium data based on OPAL data timepoints.
% 4. Saving the preprocessed and segmented data into respective folders.
%--------------------------------------------------------------------------
currentPath = cd;
subjectpath = fullfile(currentPath,'RawData');
subfolder = dir(subjectpath);
subfolder = subfolder(~ismember({subfolder.name}, {'.', '..'}));

% Which Subject to preprocess
subjectnum = subfolder(listdlg('PromptString',{'Select Subjects to Process',''},...
        'SelectionMode','multiple','ListString',{subfolder.name}));

% -Preprocess APDM OPAL Data---------------------------------------------%
for i = 1:length(subjectnum)  
    opal.(string(subjectnum(i).name)) = opalPreProcess(subjectnum(i));
    % bittium.(string(subjectnum(i).name)) = bittiumPreProcess(subjectnum(i));    
   % polar.(string(subjectnum(i).name)) = polarPreProcess(subjectnum(i));
end

%% Segment Bittium Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars segmentPolarStruct segmentBit
fn = fieldnames(bittium);
for b = 1:length(fn)
    % Gathering timepoints from opal data
    tasks = fieldnames(opal.(fn{b}));
    for tt = 1:length(tasks)
        timepoint.(tasks{tt}) = opal.(fn{b}).(tasks{tt}).timepoint;
        timeLength.(tasks{tt}) = length(opal.(fn{b}).(tasks{tt}).head.acc);
        sternum = opal.(fn{b}).(tasks{tt}).sternum.acc;
    end

    % Segmenting the bittium data
    segmentBit.(fn{b}) = segmentBittium(bittium.(fn{b}),timepoint,timeLength,sternum);
    % segmentPolarStruct.(fn{b}) = segmentPolar(polar.(fn{b}), timepoint, timeLength);
end

%% Segment Axivity Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Resample data
subject = resampleAxivity(subjectnum);

% Rotate all sensors - Alignment will be done later
axivity = reorientAxivityInitial(subject);

clearvars segmentAxivity
id = fieldnames(opal);
for ii = 1:length(id)
    % Gathering timepoints from opal data
    tasks = fieldnames(opal.(id{ii}));
    clearvars timeLength timepoint
    for tt = 1:length(tasks)
        % timepoints from opal
        timepoint.(tasks{tt}) = opal.(id{ii}).(tasks{tt}).timepoint+seconds(1)/3;
        timeLength.(tasks{tt}) = length(opal.(id{ii}).(tasks{tt}).head.time);     
    end

    % Segment Axivity
    segmentAxivity.(id{ii}) = axivityPreprocess(axivity.(id{ii}), timepoint, timeLength);

end

%% Plot axivity gyro with opal

id = fieldnames(opal);
figure
% close all
for ii = 1:length(id)
    sensor = "head";
    task = "gaitPivot";
    gyroO = opal.(id{ii}).(task).(sensor).gyro(:,3);
    gyroA = segmentAxivity.(id{ii}).(task).(sensor).gyro(:,3);

    nexttile
    hold on
    plot(gyroO)
    plot(gyroA)
    % plot(detrend(gyroA))


end

id = fieldnames(segmentAxivity);
figure
close all
for ii = 1:length(id)
    try
    sensor = "head";
    task = "gaitPivot";
    gyro = segmentAxivity.(id{ii}).(task).(sensor).gyro(:,3);
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


%%
clearvars fn b tasks tt timepoint timeLength sternum 

% Preprocess Folder
prepath = fullfile(currentPath,'Data/preprocess');
preFolder = dir(prepath);

% opal folder 
opalpath = fullfile(prepath,"opal/");
% bittium - full data folder
bitfullpath = fullfile(prepath,"bittium/");
% segmentBit - full data folder
segfullpath = fullfile(prepath,"segmentedBittium/");
% segmentPolar - full data folder
polarfullpath = fullfile(prepath,"segmentedPolar/");
% segmentAxivity - full data folder
axivityfullpath = fullfile(prepath,"axivity/");

id = fieldnames(opal);
for f = 1:length(id)
%     Save opal Data
    savePath = fullfile(opalpath, [char(id(f)) '.mat']);
    save(savePath, '-struct', 'opal', char(id(f)));

% %     Save Full Bittium Data
%     bitPath = fullfile(bitfullpath,[char(id(f)) '.mat']);
%     save(bitPath, '-struct', 'segmentBit', char(id(f)));

% %     Save Segmented Bittium Data
%     segPath = fullfile(segfullpath,[char(id(f)) '.mat']);
%     save(segPath, '-struct', 'segmentBit', char(fn(f)));

%     Save Segmented Polar Data
    % polarFullPath = fullfile(polarfullpath,[char(id(f)) '.mat']);
    % save(polarFullPath, '-struct', 'segmentPolarStruct', char(fn(f)));

    % Save Segmented Axivity Data
    axivityFullPath = fullfile(axivityfullpath,[char(id(f))]);
    save(axivityFullPath, '-struct', 'segmentAxivity', char(id(f)));
end

%% Save Data into each individual folder

prepath = fullfile(currentPath,'Data\preprocess');
preFolder = dir(prepath);
axivityfullpath = fullfile(prepath,"axivity\");
opalpath = fullfile(prepath,"opal\");

id = fieldnames(opal);

for ii = 1:length(id)
    % % Opal
    % subIDFold = strcat(opalpath, id{ii},filesep);
    % if ~isfolder(subIDFold)
    %     mkdir(subIDFold)
    % end
    % savePath = strcat(subIDFold,'data.mat');
    % opalData = opal.(id{ii});
    % save(savePath, '-struct', 'opalData');

    % Axivity
    subIDFold = strcat(axivityfullpath, id{ii},filesep);
    if ~isfolder(subIDFold)
        mkdir(subIDFold)
    end
    savePath = strcat(subIDFold,'data.mat');
    saveData = segmentAxivity.(id{ii});
    save(savePath,'-struct','saveData');
end








