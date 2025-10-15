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
for i = 1:length(subjectnum)  
    opal.(string(subjectnum(i).name)) = opalPreProcess(subjectnum(i));
    bittium.(string(subjectnum(i).name)) = bittiumPreProcess(subjectnum(i)); 
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

%% plot

figure
id = fieldnames(segmentBit);
for ii = 1:length(id)
    nexttile
    plot(segmentBit.(id{ii}).YOYO.acc)
    title(id{ii})
    ylim([-200 200])
end
%%
figure
id = fieldnames(opal);
for ii = 1:length(id)
    nexttile
    plot(opal.(id{ii}).YOYO.lumbar.acc)
    title(id{ii})
    % ylim([-200 200])
end

%% Segment Axivity Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

