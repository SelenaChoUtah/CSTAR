clear all
addpath(genpath('Data\'))
addpath(genpath('CSTAR\'))
currentPath = cd;

% Load in opal and segmented bittium data 

bitPath = fullfile(currentPath,'Data/preprocess/bittium');
bitFolder = dir(bitPath);
bitFolder = bitFolder(~ismember({bitFolder.name},{'.','..'}));

opalPath = fullfile(currentPath,'Data/preprocess/opal');
opalFolder = dir(opalPath);
opalFolder = opalFolder(~ismember({opalFolder.name},{'.','..'}));

% What data to load 
answer = questdlg('Do you want to load all data', ...
	'Loading Data', 'Yes', 'Select Subjects','bye');

switch answer
    case 'Yes'
        bittium = [];
        for i = 1:length(opalFolder)
            % Loading Bittium Folder
            [~,name,~] = fileparts(bitFolder(i).name);
            data = load([bitFolder(i).folder filesep bitFolder(i).name]);
            bittium.(name) = data.(name);
            % Loading Opal Data
            [~,name,~] = fileparts(opalFolder(i).name);
            data = load([opalFolder(i).folder filesep opalFolder(i).name]);
            opal.(name) = data.(name);
        end
    case 'Select Subjects'
        subID = listdlg('PromptString',{'Select Subjects to Process (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{bitFolder.name});
        select = bitFolder(subID);
        opalSelect = opalFolder(subID);
        for i = 1:length(select)
            [~,name,~] = fileparts(select(i).name);
            % Loading Bittium Data
            data = load([select(i).folder filesep select(i).name]);
            bittium.(name) = data.(name);
            % Loading Opal Data
            data = load([opalSelect(i).folder filesep opalSelect(i).name]);
            opal.(name) = data.(name);
        end
end

% Tasks of Interests

% Allocating another structure of interests
subjects = fieldnames(bittium);
tasks = fieldnames(bittium.(subjects{1}));
select = tasks(listdlg('PromptString',{'Select Subjects to Process (can select multiple)',''},...
        'SelectionMode','multiple','ListString',fieldnames(bittium.(subjects{1}))));

for ss = 1:length(subjects)
    for tt = 1:length(select)
        interest.(subjects{ss}).(select{tt}) = bittium.(subjects{ss}).(select{tt});
        fn = fieldnames(opal.(subjects{ss}).(select{tt}));
        for ff = 1:length(fn)
            interest.(subjects{ss}).(select{tt}).(fn{ff}) = opal.(subjects{ss}).(select{tt}).(fn{ff});
        end
    end
end

clearvars -except interest bittium opal polar currentPath


%% Turn into Dat, Header, WQRS files - wfbd toolbox

id = fieldnames(interest);

for ii = 2%:length(id)
    task = fieldnames(interest.(id{ii}));
    for tt = 1:length(task)
        recordName = id{ii};
        fs = interest.(id{ii}).(task{tt}).fsEcg;
        ecgData = interest.(id{ii}).(task{tt}).ecg;        
        folderPath = fullfile(currentPath,'Data/Lab/physionetFormat');
        folderVariable = task{tt};        

        turnDatFile(recordName,fs,ecgData,folderPath,folderVariable)
    end
end



