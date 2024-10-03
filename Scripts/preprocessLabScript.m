%% Add Paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath(pwd))

%--------------------------------------------------------------------------
% This script preprocesses data for multiple subjects and sessions,
% particularly focusing on APDM OPAL and Bittium data. It involves:
% 1. Selecting sessions and subjects to process.
% 2. Preprocessing the selected data.
% 3. Segmenting Bittium data based on OPAL data timepoints.
% 4. Saving the preprocessed and segmented data into respective folders.
%--------------------------------------------------------------------------
currentPath = cd;
subjectpath = fullfile(currentPath,'Pilot Data');
subfolder = dir(subjectpath);
subfolder = subfolder(~ismember({subfolder.name}, {'.', '..'}));

% Select Session
sessionnum = subfolder(listdlg('PromptString',{'Select Session Type',''},...
        'SelectionMode','multiple','ListString',{subfolder.name}));

% Filter only directories
sessionpath = fullfile(subjectpath,sessionnum.name);
sessionfolder = dir(sessionpath);
sessionfolder = sessionfolder(~ismember({sessionfolder.name}, {'.', '..'}));

% Which Subject to preprocess
subjectnum = sessionfolder(listdlg('PromptString',{'Select Subjects to Process (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{sessionfolder.name}));


% -Preprocess APDM OPAL Data---------------------------------------------%
for i = 1:length(subjectnum)    
    opal.(string(subjectnum(i).name)) = opalPreProcess(subjectnum(i));
   %bittium.(string(subjectnum(i).name)) = bittiumPreProcess(subjectnum(i));    
   % polar.(string(subjectnum(i).name)) = polarPreProcess(subjectnum(i));
end

% Segment Bittium Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% clearvars segmentPolarStruct segmentBit
% fn = fieldnames(polar);
% for b = 1:length(fn)
%     % Gathering timepoints from opal data
%     tasks = fieldnames(opal.(fn{b}));
%     for tt = 1:length(tasks)
%         timepoint.(tasks{tt}) = opal.(fn{b}).(tasks{tt}).timepoint;
%         timeLength.(tasks{tt}) = length(opal.(fn{b}).(tasks{tt}).head.acc);
%         sternum = opal.(fn{b}).(tasks{tt}).sternum.acc;
%     end
% 
%     % Segmenting the bittium data
%     % segmentBit.(fn{b}) = segmentBittium(bittium.(fn{b}),timepoint,timeLength,sternum);
%     segmentPolarStruct.(fn{b}) = segmentPolar(polar.(fn{b}), timepoint, timeLength);
% end

clearvars fn b tasks tt timepoint timeLength sternum 

% Preprocess Folder
prepath = fullfile(currentPath,'preprocess');
preFolder = dir(prepath);

% opal folder 
opalpath = fullfile(prepath,"opal/");
% bittium - full data folder
bitfullpath = fullfile(prepath,"fullBittium/");
% segmentBit - full data folder
segfullpath = fullfile(prepath,"segmentedBittium/");
% segmentPolar - full data folder
polarfullpath = fullfile(prepath,"segmentedPolar/");

fn = fieldnames(opal);
for f = 1:length(fn)
%     Save opal Data
    savePath = fullfile(opalpath, [char(fn(f)) '.mat']);
    save(savePath, '-struct', 'opal', char(fn(f)));

%     Save Full Bittium Data
    % bitPath = fullfile(bitfullpath,[char(fn(f)) '.mat']);
    % save(bitPath, '-struct', 'bittium', char(fn(f)));

% %     Save Segmented Bittium Data
%     segPath = fullfile(segfullpath,[char(fn(f)) '.mat']);
%     save(segPath, '-struct', 'segmentBit', char(fn(f)));

%     Save Segmented Polar Data
    % polarFullPath = fullfile(polarfullpath,[char(fn(f)) '.mat']);
    % save(polarFullPath, '-struct', 'segmentPolarStruct', char(fn(f)));
end










