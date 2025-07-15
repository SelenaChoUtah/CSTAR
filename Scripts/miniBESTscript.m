%--------------------------------------------------------------------------
%   
%     Script for processing miniBEST data, more specifically
%     Gait with horizontal head turns and Gait with Pivot Turns
%     with the APDM Opal Data
% 
% 
%     1. Gait with Horizontal Head Turns
%     2. Gait with Pivot Turns
% 
%     By Selena Cho
%     Last updated June 25th, 2025
%--------------------------------------------------------------------------

cd('C:\Users\chose\Box\C-STAR Pilot')
addpath(genpath('Data\'))
addpath(genpath('CSTAR\'))

cd('C:\Users\chose\Box\DHI-Lab')
addpath(genpath('CSTAR\'))

cd('D:\DHI')
addpath(genpath('Data\'))

%% Pull-in Raw Opal and Preprocess

% Pathway
currentFoldPath = cd;
rawOpalPath = dir(fullfile('C:\Users\chose\Box\Digital Health Pilot - Multimodal Sensing\Analysis\Pilot Data\Lab'));
rawOpalPath = rawOpalPath(~ismember({rawOpalPath.name}, {'.', '..'}));
subjectnum = rawOpalPath(listdlg('PromptString',{'Select Subjects to Process (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{rawOpalPath.name}));

% Preprocess raw Opal Data
disp("Processing Raw Opal Data")
for i = 1:length(subjectnum)  
    disp(string(subjectnum(i).name))
    opal.(string(subjectnum(i).name)) = opalPreProcess(subjectnum(i));
end

% Saving Opal Data
disp("Saving Opal Data")
subID = fieldnames(opal);
for i = 1:length(subID)    
    % Create preprocessed folder
    subIDFolder = strcat(currentFoldPath,'\Data\In-Lab\Preprocess\', subID{i},filesep);
    if ~isfolder(subIDFolder)
        mkdir(subIDFolder)
    end

    data = opal.(subID{i});
    savePath = fullfile(subIDFolder,'data.mat');
    save(savePath, '-struct','data'); 
    disp(append("Saved Subject ",subID{i}))
end

clearvars opal

%% Loading In Preprocess data and selecting tasks

% What data to load 
answer = questdlg('Do you want to load all data', ...
	'Loading Data', 'Yes', 'Select Subjects','bye');

opalPath = fullfile(currentFoldPath, '\Data\In-Lab\preprocess');
opalFolder = dir(opalPath);
opalFolder = opalFolder(~ismember({opalFolder.name},{'.','..'}));

subID = listdlg('PromptString',{'Select Subjects to Process (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{opalFolder.name});

select = opalFolder(subID);
for i = 1:length(select)
    [~,name,~] = fileparts(select(i).name);
    % Loading Opal Data
    data.(select(i).name) = load([select(i).folder filesep select(i).name filesep 'data.mat']);
    opal.(name) = data.(name);
end

% Allocating another structure of interests
subID = fieldnames(opal);
tasks = fieldnames(opal.(subID{1}));
select = tasks(listdlg('PromptString',{'Select Subjects to Process (can select multiple)',''},...
        'SelectionMode','multiple','ListString',fieldnames(opal.(subID{1}))));

for ii = 1:length(subID)
    for tt = 1:length(select)
        interest.(subID{ii}).(select{tt}) = opal.(subID{ii}).(select{tt});
        fn = fieldnames(opal.(subID{ii}).(select{tt}));
        for ff = 1:length(fn)
            interest.(subID{ii}).(select{tt}).(fn{ff}) = opal.(subID{ii}).(select{tt}).(fn{ff});
        end
    end
end


%% Gait with Pivot Turns

subID = fieldnames(interest);
figure
for tt = 1:length(subID)
    task = 'gaitPivot';
    sensor = 'head';
    headGyroYaw = interest.(subID{tt}).(task).(sensor).gyro(:,1);
    amplitudeThreshold = 10; % deg minimum amplitude for head turn
    velocityThreshold = 15; % deg/s peak velocity to quantify as turn
    minima = 5; % Local Minima     
    impulseDuration = 0.3; % Larger value means more smoothed
    disp(subID{tt})
    turnInfo.gaitPivot.(subID{tt}) = gaitWithPivotTurns(headGyroYaw,impulseDuration,amplitudeThreshold,velocityThreshold,minima,1);
    title(subID{tt})
end


%% Gait with Horizontal Head Turns

subID = fieldnames(interest);
figure
for tt = 1:length(subID)
    task = 'gaitHori';
    sensor = 'head';
    headGyroYaw = interest.(subID{tt}).(task).(sensor).gyro(:,1);
    amplitudeThreshold = 10; % deg minimum amplitude for head turn
    velocityThreshold = 15; % deg/s peak velocity to quantify as turn
    minima = 5; % Local Minima     
    impulseDuration = 0.2; % Larger value means more smoothed
    turnInfo.gaitHori.(subID{tt}) = gaitWithPivotTurns(headGyroYaw,impulseDuration,amplitudeThreshold,velocityThreshold,minima,1);
    title(subID{tt})
end


%% Statistic 

% Load in the excel data
subInfo = readtable("C:\Users\chose\Box\C-STAR Pilot\CSTAR\subject_info.xlsx",'sheet','DHI');

tasks = fieldnames(turnInfo);
for tt = 1:length(tasks)
    subID = fieldnames(turnInfo.(tasks{tt}));
    for ss = 1:length(subID)
        vari = fieldnames(turnInfo.(tasks{tt}).(subID{ss}));
        for vv = 1:2
            rowNumber = find(strcmp(subInfo.ID, subID{ss}));
            colName = append(tasks{tt},'_',vari{vv});
            subInfo.(colName)(rowNumber) = mean(nonzeros(turnInfo.(tasks{tt}).(subID{ss}).(vari{vv}))); 
            
        end
    end
end

%% Plotting freely scatter plot

varName = subInfo.Properties.VariableNames;

% Ask user to select X variable
[xIdx, okX] = listdlg('PromptString','Select X variable:', ...
                      'SelectionMode','single', ...
                      'ListString', varName);

% Ask user to select Y variable
[yIdx, okY] = listdlg('PromptString','Select Y variable:', ...
                      'SelectionMode','single', ...
                      'ListString', varName);

% plot
xVar = varName{xIdx};
yVar = varName{yIdx};

xData = subInfo.(xVar);
yData = subInfo.(yVar);

% Plot
figure
hold on
scatter(xData(subInfo.ConcussLabel==0), yData(subInfo.ConcussLabel==0), 'filled');
scatter(xData(subInfo.ConcussLabel==1), yData(subInfo.ConcussLabel==1), 'filled');

offset = 0.01 * range(xData);
for i = 1:height(subInfo)
    text(xData(i) + offset, yData(i), subInfo.ID(i), 'FontSize', 8);
end

xlabel(strrep(xVar, '_', '\_'));
ylabel(strrep(yVar, '_', '\_'));
legend("HC","mTBI")
title(sprintf('Scatter plot of %s vs %s', yVar, xVar), 'Interpreter', 'none');
saveas(gcf,append(xVar,'_',yVar),'svg')

%% T-Test

varName = subInfo.Properties.VariableNames;
% Ask user to select X variable
[xIdx, okX] = listdlg('PromptString','Select Variable for ttest (You can select Multiple):', ...
                      'SelectionMode','multiple', ...
                      'ListString', varName);

% plot
for xx = 1:length(xIdx)
    xVar = varName{xIdx(xx)};
    xData = subInfo.(xVar);
    
    [h,p,ci,stats] = ttest2(xData(subInfo.ConcussLabel==0),xData(subInfo.ConcussLabel==1));
    fprintf("Stats for variable: %s\n",xVar)
    fprintf("\t H: %d p: %d\n",h,p)
end

% %% Plotting Violin Plots
% 
% varName = subInfo.Properties.VariableNames';
% 
% % Ask user to select X variable
% [xIdx, okX] = listdlg('PromptString','Select Variables for Violin Plot (You can select Multiple):', ...
%                       'SelectionMode','Multiple', ...
%                       'ListString', varName);

% Plot violin
for xx = 1:length(xIdx)
    figure
    xVar = varName{xIdx(xx)};
    xData = subInfo.(xVar);
    Violin2(xData(subInfo.ConcussLabel==0),1,'Showdata',true,'Sides','Left','ShowMean',true);
    Violin2(xData(subInfo.ConcussLabel==1),1,'Showdata',true,'Sides','Right','ShowMean',true);
    title(sprintf('Violin Plot %s', xVar), 'Interpreter', 'none');
    % ylim([2000 9000])
    saveas(gcf,sprintf('Violin Plot %s', xVar),'svg')
    
end

%% Random mean and std

varName = subInfo.Properties.VariableNames;
% Ask user to select X variable
[xIdx, okX] = listdlg('PromptString','Select Variable for ttest (You can select Multiple):', ...
                      'SelectionMode','multiple', ...
                      'ListString', varName);

% plot
for xx = 1:length(xIdx)
    xVar = varName{xIdx(xx)};
    xData = subInfo.(xVar);

    mtbi.mean = round(mean(xData(subInfo.ConcussLabel==1),'omitnan'),2);
    mtbi.std = round(std(xData(subInfo.ConcussLabel==1),'omitnan'),2);
    hc.mean = round(mean(xData(subInfo.ConcussLabel==0),'omitnan'),2);
    hc.std = round(std(xData(subInfo.ConcussLabel==0),'omitnan'),2);

    % Extract data for each group
    mtbi_data = xData(subInfo.ConcussLabel == 1);
    hc_data   = xData(subInfo.ConcussLabel == 0);
    
    % Group sizes
    n_mtbi = sum(subInfo.ConcussLabel == 1);
    n_hc   = sum(subInfo.ConcussLabel == 0);
    
    % Standard deviations
    std_mtbi = std(mtbi_data, 'omitnan');
    std_hc   = std(hc_data, 'omitnan');
    
    % Pooled standard deviation
    s_pooled = sqrt( ((n_mtbi - 1)*std_mtbi^2 + (n_hc - 1)*std_hc^2) / (n_mtbi + n_hc - 2) );
    
    % Group means
    mean_mtbi = mean(mtbi_data, 'omitnan');
    mean_hc   = mean(hc_data, 'omitnan');
    
    % Cohen's d (unpaired)
    cohens_d = (mean_mtbi - mean_hc) / s_pooled;

    % calc effect size
    ES = meanEffectSize(mtbi_data,hc_data,"Effect","robustcohen")

    fprintf("Cohen's d (unpaired) for %s: %.3f\n", varName{xIdx(xx)}, cohens_d);
    fprintf("HC %s Mean (StDev): %d  (%d)\n",varName{xIdx(xx)},hc.mean,hc.std)
    fprintf("mTBI %s Mean (StDev): %d  (%d)\n",varName{xIdx(xx)},mtbi.mean,mtbi.std)
    
    % [h,p,ci,stats] = ttest2(xData(subInfo.ConcussLabel==0),xData(subInfo.ConcussLabel==1));
    % fprintf("Stats for variable: %s\n",xVar)
    % fprintf("\t H: %d p: %d\n",h,p)
end

%% Scatter with jitter

varName = subInfo.Properties.VariableNames;

% Ask user to select Y variable
[yIdx, okY] = listdlg('PromptString','Select Variables for Scatter jitter (You can select Multiple):', ...
                      'SelectionMode','Multiple', ...
                      'ListString', varName);

% plot


for yy = 1:length(yIdx)
    figure
    yVar = varName{yIdx(yy)};
    xData = (subInfo.ConcussLabel+1).*rand(length(subInfo.ConcussLabel),1)/4;
    yData = subInfo.(yVar);
    hold on
    scatter(xData(subInfo.ConcussLabel==0)-1, yData(subInfo.ConcussLabel==0), 'filled');
    scatter(xData(subInfo.ConcussLabel==1), yData(subInfo.ConcussLabel==1), 'filled');
    xlim([-2 2])
    title(sprintf('ScatterJitter %s', yVar), 'Interpreter', 'none');
    saveas(gcf,sprintf('ScatterJitter %s', yVar),'svg')
end