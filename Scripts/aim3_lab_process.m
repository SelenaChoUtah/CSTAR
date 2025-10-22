
%--------------------------------------------------------------------------
% 
% 
%     Script for Aim 3 Lab Process
% 
%     This script pulls in the preprocess OPAL and BITTIUM data
%     aka the motion and ECG data. The goal here is to pull in 
%     the YOYO data, identify the transitions, and create the 
%     HRRS responses similar to this paper:
%         Combining 24-Hour Continuous Monitoring of Time-Locked Heart Rate, Physical Activity and Gait in Older Adults: Preliminary Findings
%         https://www.mdpi.com/1424-8220/25/6/1945
% 
% 
%     Created by Selena Cho
%     Last Updated 10/22/2025
% 
%--------------------------------------------------------------------------

cd('C:\Users\chose\Box\DHI-Lab\')
addpath(genpath('CSTAR\'))

% This is my hard drive - makes data load much faster
cd('D:\CSTAR')
addpath(genpath('CSTAR\'))
addpath(genpath('DHI_data\'))

%% Loading Lab Data
currentFoldPath = cd;
dataPath = dir(fullfile(currentFoldPath,'\DHI_data\PreprocessData\Lab\Bittium\'));

% Keep only subject folders
bittiumFolder = dataPath(~ismember({dataPath.name}, {'.', '..','subject_info.xlsx'}));

% Which Subject to preprocess
subjectnum = bittiumFolder(listdlg('PromptString',{'Select subjects to load (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{bittiumFolder.name}));
opalPath = dir(fullfile(currentFoldPath,'\DHI_data\PreprocessData\Lab\Opal\'));

% Load in data
for ss = 1:length(subjectnum)
    bittiumData.(subjectnum(ss).name) = load(fullfile(subjectnum(ss).folder,subjectnum(ss).name,filesep,'data.mat'));
    opalData.(subjectnum(ss).name) = load(fullfile(opalPath(ss).folder,subjectnum(ss).name,filesep,'data.mat'));
end 

taskNames = {'supine2stand'	'sit2stand'	'Rise2Toes'	'left1'	'right1'	'left2'	'right2'	'openfront'	'openback'	'openleft'	'openright'	'closefront'	'closeback'	'closeleft'	'closeright'	'FTEOIS'	'FTECOS'	'InclineEyesClosed'	'ChangeGaitSpeed'	'gaitHori'	'gaitPivot'	'WalkObstacle'	'singletug'	'dualtug'	'YOYO'	'Buffalo'	'spHori'	'spVert'	'scHori'	'scVert'	'Convergence'	'vorHori'	'vorVert'	'VMS'	'WalkHeadVert'	'WalkHeel2Toe'	'WalkEyesClosed'	'WalkBackward'	'Stairs'};
task = taskNames(listdlg('PromptString',{'Select tasks to work with (can select multiple)',''},...
        'SelectionMode','multiple','ListString',taskNames));

subID = fieldnames(bittiumData);
for ss = 1:length(subID)
    for tt = 1:length(task)
        taskData.(subID{ss}).(task{tt}).bittium = bittiumData.(subID{ss}).(task{tt});
        taskData.(subID{ss}).(task{tt}).lumbar = opalData.(subID{ss}).(task{tt}).lumbar;
    end
end

%% Summarizing Beat-to-Beat Heart Rate

% identify QRS Complex
subID = fieldnames(taskData);
figure
for ss = 2%1:length(subID)
    for tt = 1:length(task)
        recordName = subID{ss};
        folderName = 'DHI_data\PreprocessData\Lab\physionetFormat';
        folderVariable = task{tt};
        fs = taskData.(subID{ss}).(task{tt}).bittium.fsEcg;
        ecgData = taskData.(subID{ss}).(task{tt}).bittium.ecg;
        taskData.(subID{ss}).(task{tt}).HR = turnDatFile(recordName,fs,ecgData,folderName,folderVariable);
    end
    nexttile
    plot(taskData.(subID{ss}).(task{tt}).HR.time,taskData.(subID{ss}).(task{tt}).HR.signal(:,1))
    hold on
    plot(taskData.(subID{ss}).(task{tt}).HR.time(taskData.(subID{ss}).(task{tt}).HR.ann),taskData.(subID{ss}).(task{tt}).HR.signal(taskData.(subID{ss}).(task{tt}).HR.ann,1),'ro')
end

% The Hilbert transform [11] was applied to extract the envelope of each 
% QRS complex, with the area under the curve used as a signal-to-noise ratio measure

% The beat-to-beat HR was computed from these identified complexes and 
% smoothed over a 5-beat rolling window to account for potential 
% irregularities (e.g., atrial fibrillation). 

%%
figure
subID = fieldnames(taskData);
for ss = 1:length(subID)
    nexttile
    plot(taskData.(subID{ss}).(task{tt}).HR.time,taskData.(subID{ss}).(task{tt}).HR.signal(:,1))
    hold on
    plot(taskData.(subID{ss}).(task{tt}).HR.time(taskData.(subID{ss}).(task{tt}).HR.ann),taskData.(subID{ss}).(task{tt}).HR.signal(taskData.(subID{ss}).(task{tt}).HR.ann,1),'ro')
end

%%
figure
subID = fieldnames(taskData);
for ss = 1:length(subID)
    nexttile
    plot(taskData.(subID{ss}).(task{tt}).HR.heartRate)
    % hold on
    % plot(taskData.(subID{ss}).(task{tt}).HR.time(taskData.(subID{ss}).(task{tt}).HR.ann),taskData.(subID{ss}).(task{tt}).HR.signal(taskData.(subID{ss}).(task{tt}).HR.ann,1),'ro')
end

% figure
    % plot(tm,signal(:,1));hold on;grid on
    % plot(tm(ann),signal(ann,1),'ro')
%% Turn into Dat, Header, WQRS files - wfbd toolbox

subjects = fieldnames(interest);
for s = 1:length(subjects)
    recordName = subjects{s};
    folderName = 'physionetFormat';
    folderVariable = 'Buffalo';
    fs = interest.(subjects{s}).(folderVariable).fs;
    ecgData = interest.(subjects{s}).Buffalo.ecg;
    turnDatFile(recordName,fs,ecgData,folderName,folderVariable)
end

%% figure
for i = 1:length(subjects)
    figure
    recordName = fullfile('physionetFormat',folderVariable,subjects{i},subjects{i});
    [signal, ~, tm] = rdsamp(recordName);
    N = length(signal);
    ann = rdann(recordName,'wqrs',[],N);
    buffaloTask.(subjects{i}).rrIntervals = ann;
    fs = interest.(subjects{s}).(folderVariable).fs;
    [heartRate, time] = rr2bpm(ann, fs);
    buffaloTask.(subjects{i}).heartRate = heartRate;
    buffaloTask.(subjects{i}).hrTime = time;

    plot(tm,signal(:,1));hold on;grid on
    plot(tm(ann),signal(ann,1),'ro')
    % bpm = rr2bpm(diff(ann));
    % plot(bpm)
    % % Plot the heart rate
    % plot(time/60,heartRate);
    % % plot(time, heartRate, '-o');
    % xlabel('Time (min)');
    % ylabel('Heart Rate (beats per minute)');
    % title(string(subjects{i}));
    % axis tight
    % grid on;
    % ylim([60 200])
end