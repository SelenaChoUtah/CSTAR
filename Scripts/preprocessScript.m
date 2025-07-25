%% preprocess Axivity
% addpath(genpath(pwd))
addpath('Data\')
addpath('CSTAR\')
% 
% The point of this script 
%     1) Pull in raw axivity data
%     2) Resample 
%     3) Rotate all sensors to line
%     4) Identify number of days
%     5) Split data into separate days
% 
% filepath ex/ \DHI\Preprocess\S04\day1\data.mat
% data.mat: head, neck, waist

% cd('C:\Users\chose\Box\C-STAR Pilot')
%% 1) Pull in raw axivity data

% Current Folder should be at DHI
% Normative Data Location: \RawData\Normative\S##\...'sensorLocation'.cwa
currentFoldPath = cd;
% CSTAR
% normativeFoldPath = dir(fullfile(currentFoldPath,'\Data\Normative'));

% DHI-LAB: One path for continuous and other for Lab
normativeFoldPath = dir(fullfile(currentFoldPath,'Data\RawData\Continuous'));

% Keep only subject folders
normativeFolder = normativeFoldPath(~ismember({normativeFoldPath.name}, {'.', '..','subject_info.xlsx'}));

% Which Subject to preprocess
subjectnum = normativeFolder(listdlg('PromptString',{'Select Subjects to Process (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{normativeFolder.name}));


for ss = 1:length(subjectnum)
    disp(append("Subject ", subjectnum(ss).name))
    clearvars subject reorient sortData
    % try
    % Resample data
    subject = resampleAxivity(subjectnum(ss));
    
    % 3) Rotate all sensors - Alignment will be done later
    reorient = reorientAxivityInitial(subject);
    
    % 4) Identify number of days and Split data into separate days
    sortData = sortIntoDays(reorient);
    
    % 6) Save data into separate folders
    disp("Saving Subject Data")
    subID = fieldnames(sortData);
    for i = 1:length(subID)    
        % Create preprocessed folder
        % CSTAR
        subIDFolder = strcat(currentFoldPath,'\Data\Preprocess\', subID{i},filesep);
        % DHI
        % subIDFolder = strcat(currentFoldPath,'\PreprocessData\Continuous\', subID{i},filesep);
        if ~isfolder(subIDFolder)
            mkdir(subIDFolder)
        end
        daynum = fieldnames(sortData.(subID{i}));
        for j = 1:length(daynum)
            dayFold = strcat(subIDFolder,daynum{j},filesep);
            if ~isfolder(dayFold)
                % If the folder doesn't exist, create it
                mkdir(dayFold)
            end
            data4 = sortData.(subID{i}).(daynum{j});
            savePath = fullfile(dayFold,'data.mat');
            save(savePath, '-struct','data4'); 
        end
        disp(append("Saved Subject ",subID{i}))
    end
end

