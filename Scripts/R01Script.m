%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     Script for Melissa Cortez's R01 grant 
%     This script analyzes IMU and bittium data for all
%     of the entropy stuff. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath(pwd))

%% subject path
currentPath = fullfile(cd,'Data');
segmentedBittiumPath = fullfile(currentPath,'preprocess','segmentedBittium');
bittiumFolder = dir(segmentedBittiumPath);
bittiumFolder = bittiumFolder(~ismember({bittiumFolder.name}, {'.', '..'}));

opalPath = fullfile(currentPath,'preprocess','opal');
opalFolder = dir(opalPath);
opalFolder = opalFolder(~ismember({opalFolder.name},{'.','..'}));

polarPath = fullfile(currentPath,'preprocess','segmentedPolar');
polarFolder = dir(polarPath);
polarFolder = polarFolder(~ismember({polarFolder.name},{'.','..'}));

% What data to load 
answer = questdlg('Do you want to load all data', ...
	'Loading Data', 'Yes', 'Select Subjects','bye');

switch answer
    case 'Yes'
        bittium = [];
        for i = 1:length(bittiumFolder)
            % Loading Bittium Folder
            [~,name,~] = fileparts(bittiumFolder(i).name);
            bittium.(name) = load([bittiumFolder(i).folder filesep bittiumFolder(i).name filesep 'data.mat']);
            % Loading Opal Data
            [~,name,~] = fileparts(opalFolder(i).name);
            opal.(name) = load([opalFolder(i).folder filesep opalFolder(i).name filesep 'data.mat']);
            % % Loading Polar Data
            % [~,name,~] = fileparts(polarFolder(i).name);
            % polar.(name) = load([polarFolder(i).folder filesep polarFolder(i).name filesep 'data.mat']);
        end
    case 'Select Subjects'
        subID = listdlg('PromptString',{'Select Subjects to Process (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{bittiumFolder.name});
        select = bittiumFolder(subID);
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

% clearvars -except opal bittium polar

%% Tasks of Interests

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

%% Physionet - turn data into *.dat files
original = pwd;
subjects = fieldnames(interest);
for s = 1:length(subjects)
    recordName = subjects{s};
    folderName = fullfile(currentPath,'physionetFormat');
    for ff = 1:length(folderVariable)
        fs = interest.(subjects{s}).(folderVariable{ff}).fsEcg;
        ecgData = interest.(subjects{s}).Buffalo.ecg;
        turnDatFile(recordName,fs,ecgData,folderName,folderVariable{ff})
    end
end
cd(original)

%% Pull out the ECG markers and save to struct with everyone

for ss = 1:length(subjects)    
    folderName = fullfile(currentPath,'physionetFormat');
    folderVariable = fieldnames(interest.(subjects{ss}));
    for ff = 1:length(folderVariable)
    % folderVariable = 'YOYO';
        filename = dir(fullfile(folderName, folderVariable{ff}, subjects{ss}, '*.mat'));
        ecg.(folderVariable{ff}).(subjects{ss}) = load(fullfile(filename.folder, filename.name));
    end
end


%% figure to check how well R peaks are detected

folderVariable = 'Buffalo';

figure
tiledlayout('flow')
for ss = 1:length(subjects)
    nexttile
    plot(ecg.(folderVariable).(subjects{ss}).time, ecg.(folderVariable).(subjects{ss}).signal)
    hold on 
    plot(ecg.(folderVariable).(subjects{ss}).time(ecg.(folderVariable).(subjects{ss}).ann), ecg.(folderVariable).(subjects{ss}).signal(ecg.(folderVariable).(subjects{ss}).ann),'*')
    title(subjects{ss})
end

%% Cross-Fuzzy Entropy

folderVariable = fieldnames(interest.(subjects{ss}));
for ff = 1:length(folderVariable)
    for ss = 1:length(subjects)    
        irregularTime = [];
        uniform = [];
    
        hrData = ecg.(folderVariable{ff}).(subjects{ss}).heartRate;
        irregularTime = ecg.(folderVariable{ff}).(subjects{ss}).hrTime;
    
        uniform(:,1) = linspace(0, max(irregularTime),length(irregularTime));
        uniformHrData = interp1(irregularTime, hrData, uniform, 'spline');
    
        newEcg = resample(uniformHrData,10,2);
        newAcc = resample(interest.(subjects{ss}).(folderVariable{ff}).head.acc,10,100); 
    
        for j = 1:3
            CFEnBCTT(ss,j) = CFuzzyEn(newAcc(:,j),newEcg);
        end
    end
    crossFuzzyStat.(folderVariable{ff}) = CFEnBCTT;
end

%% Plotting for CFuzzyEN
close all
% 0 - healthy control
% 1 - exercise tolerant
% 2 - exercise intolerant
subInfo = readtable("subjectInfo.xlsx");

accTitle = string({'AP','ML','Vert'});
for ff = 1:length(folderVariable)
    figure
    for i = 1:3
        nexttile
        scatter(subInfo.Type(1:length(crossFuzzyStat.(folderVariable{ff}))),crossFuzzyStat.(folderVariable{ff})(:,i))
        title(append("CrossFuzEN ",folderVariable{ff},accTitle(i)))
        xlim([-1 2])
        % ylim([0.7 2.5])
    end
end

%% Cross-Fuzzy Entropy for Resultant Acc

folderVariable = fieldnames(interest.(subjects{ss}));
for ff = 1:length(folderVariable)
    for ss = 1:length(subjects)    
        irregularTime = [];
        uniform = [];
    
        hrData = ecg.(folderVariable{ff}).(subjects{ss}).heartRate;
        irregularTime = ecg.(folderVariable{ff}).(subjects{ss}).hrTime;
    
        uniform(:,1) = linspace(0, max(irregularTime),length(irregularTime));
        uniformHrData = interp1(irregularTime, hrData, uniform, 'spline');
    
        newEcg = resample(uniformHrData,10,2);
        resultant = sqrt(interest.(subjects{ss}).(folderVariable{ff}).head.acc(:,1).^2 + interest.(subjects{ss}).(folderVariable{ff}).head.acc(:,2).^2 + interest.(subjects{ss}).(folderVariable{ff}).head.acc(:,3).^2);
        newAcc = resample(resultant,10,100); 
    
        CFEnBCTT_resultant(ss) = CFuzzyEn(newAcc,newEcg);
        
    end
    crossFuzzyStatResultant.(folderVariable{ff}) = CFEnBCTT_resultant;
end

%% Plotting for CFuzzyEN
close all
% 0 - healthy control
% 1 - exercise tolerant
% 2 - exercise intolerant
subInfo = readtable("subjectInfo.xlsx");

accTitle = string({'AP','ML','Vert'});
for ff = 1:length(folderVariable)
    figure
    nexttile
    scatter(subInfo.Type(1:length(crossFuzzyStatResultant.(folderVariable{ff}))),crossFuzzyStatResultant.(folderVariable{ff}))
    title(append("CrossFuzEN Resultant ",folderVariable{ff},accTitle(i)))
    xlim([-1 2])
    % ylim([0.7 2.5])
end


%%
% can you do a scatter plot where the x axis is the age, y is the xEn measure, and the different groups are different symbols / colors?

accTitle = string({'AP','ML','Vert'});
for ff = 1:length(folderVariable)
    figure
    for i = 1:3
        nexttile
        gscatter(subInfo.Age(1:length(crossFuzzyStat.(folderVariable{ff}))),crossFuzzyStat.(folderVariable{ff})(:,i),subInfo.Type(1:length(crossFuzzyStat.(folderVariable{ff}))))
        title(append("CrossFuzEN ",folderVariable{ff},accTitle(i)))
        % xlim([-1 2])
        % ylim([0.7 2.5])
    end
end

%% ok, can you do a quick exploration, plot the same as before 
% (different colors on scatter), but change x axis to the xFuz 
% of a different direction. (e.g., y axis is vertical, x axis is ML)


accTitle = string({'AP','ML','Vert'});
for ff = 1:length(folderVariable)
    figure
    for i = 1
        nexttile
        gscatter(crossFuzzyStat.(folderVariable{ff})(:,1),crossFuzzyStat.(folderVariable{ff})(:,2),subInfo.Type(1:length(crossFuzzyStat.(folderVariable{ff}))))
        title(append("CrossFuzEN ",folderVariable{ff},accTitle(i)))        
        xlabel(accTitle{1})
        ylabel(accTitle{2})
        % xlim([-1 2])
        % ylim([0.7 2.5])

         % Get the x and y data points
        xData = crossFuzzyStat.(folderVariable{ff})(:,1);
        yData = crossFuzzyStat.(folderVariable{ff})(:,2);

        % Define labels (e.g., subject ID or index numbers)
        pointLabels = string(1:length(xData)); % Example: Using index numbers

        % Add text labels to each point
        for k = 1:length(xData)
            text(xData(k), yData(k), pointLabels(k), 'FontSize', 10, 'Color', 'black', 'HorizontalAlignment', 'left');
        end

    end
end

%% Questionnaire Figure plots
close all

% questionnaire = readtable("subjectInfo.xlsx",'Sheet','Questionnaires');
variable = fieldnames(questionnaire);
xx = listdlg('PromptString',{'Select X Variable',''},...
        'SelectionMode','single','ListString',variable);

accTitle = string({'AP','ML','Vert'});
for ff = 1:length(folderVariable)
    figure
    for i = 1:3
        nexttile
        gscatter(questionnaire.(variable{xx})(1:length(crossFuzzyStat.(folderVariable{ff}))),crossFuzzyStat.(folderVariable{ff})(:,i),questionnaire.Type(1:length(crossFuzzyStat.(folderVariable{ff}))))
        title(append((variable{xx})," vs CrossFuzEN ",folderVariable{ff},' ',accTitle(i)))
        % xlim([-1 2])
        % ylim([0.7 2.5])
    end
end
