cd('C:\Users\chose\Box\DHI-Lab\')
addpath(genpath('CSTAR\'))

% This is my hard drive - makes data load much faster
cd('D:\CSTAR')
addpath(genpath('CSTAR\'))
addpath(genpath('DHI_data\'))

%% 1. Preprocess the lab data

% ex/ D:\CSTAR\DHI_data\RawData\Lab\DHI001
currentPath = cd;
subjectpath = fullfile(currentPath,'DHI_data','RawData','Lab');
subfolder = dir(subjectpath);
subfolder = subfolder(~ismember({subfolder.name}, {'.', '..'}));

% Which Subject to preprocess
subjectnum = subfolder(listdlg('PromptString',{'Select Subjects to Process',''},...
        'SelectionMode','multiple','ListString',{subfolder.name}));

% -Preprocess APDM OPAL Data---------------------------------------------%
fprintf("Preprocess Opal and Bittium Raw Data\n")
for i = 1:length(subjectnum)  
    % fprintf("Subject: %s\n",subjectnum(i).name)
    opal.(string(subjectnum(i).name)) = opalPreProcess(subjectnum(i));
    bittium.(string(subjectnum(i).name)) = bittiumPreProcess(subjectnum(i)); 
end

% Segment Bittium Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf("Segment Bittium Data\n")
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
end

%% 2. Save Preprocess data

currentPath = 'D:\CSTAR\DHI_data';

% Saving Opal Data
disp("Saving Opal Data")
subID = fieldnames(opal);
for i = 1:length(subID)    
    % Create preprocessed folder
    subIDFolder = strcat(currentPath,'\PreprocessData\Lab\Opal\', subID{i},filesep);
    if ~isfolder(subIDFolder)
        mkdir(subIDFolder)
    end

    data = opal.(subID{i});
    savePath = fullfile(subIDFolder,'data.mat');
    save(savePath, '-struct','data'); 
    disp(append("Saved Subject ",subID{i}))
end

% Saving Segmented Bittium Data
disp("Saving Segmented Bittium Data")
subID = fieldnames(segmentBit);
for i = 1:length(subID)    
    % Create preprocessed folder
    subIDFolder = strcat(currentPath,'\PreprocessData\Lab\Bittium\', subID{i},filesep);
    if ~isfolder(subIDFolder)
        mkdir(subIDFolder)
    end

    data = segmentBit.(subID{i});
    savePath = fullfile(subIDFolder,'data.mat');
    save(savePath, '-struct','data'); 
    disp(append("Saved Subject ",subID{i}))
end