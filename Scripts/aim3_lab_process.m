cd('C:\Users\chose\Box\DHI-Lab\')
addpath(genpath('CSTAR\'))

% This is my hard drive - makes data load much faster
cd('D:\CSTAR')
addpath(genpath('CSTAR\'))
addpath(genpath('DHI_data\'))

% Loading Lab Data
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
