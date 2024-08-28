addpath(genpath(pwd))
currentFoldPath = cd('C:\Users\chose\Box\C-STAR Pilot\Data');

processPath = dir(fullfile(currentFoldPath,'\Process'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

% Load Data 

for i = 1:numel(subjectnum)
    % Save Data into Process
    id = string(subjectnum(i).name);
    % disp(id)   
    data.(id) = load(fullfile(subjectnum(i).folder,subjectnum(i).name,'data.mat'));   

end

clearvars -except data