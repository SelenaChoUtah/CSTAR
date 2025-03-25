%--------------------------------------------------------------------------
%   
%     Script for comparing daily head turns and in-lab head turns
%     between healthy controls and individuals with mTBI
%
%     1. Load in the preprocessed life data
%     2. Normative Stats on head turns
%--------------------------------------------------------------------------


%% 1. Load in the preprocessed life data

currentFoldPath = cd;

processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

% Load Data 
for ii = 1:numel(subjectnum)
    % Save Data into Process
    id = string(subjectnum(ii).name);
    % disp(id)   
    data.(id) = load(fullfile(subjectnum(ii).folder,subjectnum(ii).name,'data.mat'));   
end



%% 2. Normative Stats on head turns