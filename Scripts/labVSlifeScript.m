%--------------------------------------------------------------------------
%   
%     Script for comparing daily head turns and in-lab head turns
%     between healthy controls and individuals with mTBI
%
%     1. Load in the preprocessed life data
%     2. Normative Stats on head turns
% 
% Compare score and rating with head turn metrics, confirmation on other papers
% Are daily head turns different between group
% Compare effect sizes
% Speed of minibest compare to daily living
% Is daily useful? Clinical test may not show or it offers more comprehension
%--------------------------------------------------------------------------

% cd('C:\Users\chose\Box\DHI-Lab')
cd('D:\CSTAR\DHI_data')
addpath(genpath('Data\'))
addpath(genpath('RawData\'))
addpath(genpath('PreprocessData\'))
addpath(genpath('CSTAR\'))

% 1. Preprocess the lab data
currentPath = cd;
subjectpath = fullfile(currentPath,'RawData','Lab');
subfolder = dir(subjectpath);
subfolder = subfolder(~ismember({subfolder.name}, {'.', '..'}));

% Which Subject to preprocess
subjectnum = subfolder(listdlg('PromptString',{'Select Subjects to Process',''},...
        'SelectionMode','multiple','ListString',{subfolder.name}));

% -Preprocess APDM OPAL Data---------------------------------------------%
for i = 1:length(subjectnum)  
    opal.(string(subjectnum(i).name)) = opalPreProcess(subjectnum(i));
end

% Segment Axivity Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%% 2. Save Preprocess data

currentPath = 'D:\CSTAR\DHI_data';

% Saving Opal Data
disp("Saving Opal Data")
subID = fieldnames(opal);
for i = 1:length(subID)    
    % Create preprocessed folder
    subIDFolder = strcat(currentPath,'\PreprocessData\Lab\Opal\', subID{i},filesep);
    if ~isfolder(subIDFolder)
        mkdir(subIDFolder)
    end

    data = opal.(subID{i});
    savePath = fullfile(subIDFolder,'data.mat');
    save(savePath, '-struct','data'); 
    disp(append("Saved Subject ",subID{i}))
end

% Saving Segmented Axivity Data
disp("Saving Segmented Axivity Data")
subID = fieldnames(segmentAxivity);
for i = 1:length(subID)    
    % Create preprocessed folder
    subIDFolder = strcat(currentPath,'\PreprocessData\Lab\Axivity\', subID{i},filesep);
    if ~isfolder(subIDFolder)
        mkdir(subIDFolder)
    end

    data = segmentAxivity.(subID{i});
    savePath = fullfile(subIDFolder,'data.mat');
    save(savePath, '-struct','data'); 
    disp(append("Saved Subject ",subID{i}))
end

%% 3. Pull in preprocess axivity lab data

currentPath = cd;
dataPath = dir(fullfile(currentPath,'\PreprocessData\Lab\Axivity\'));

% Keep only subject folders
axivityFolder = dataPath(~ismember({dataPath.name}, {'.', '..','subject_info.xlsx'}));

% Which Subject to preprocess
subjectnum = axivityFolder(listdlg('PromptString',{'Select subjects to load (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{axivityFolder.name}));

% Load in data
for ss = 1:length(subjectnum)
    labData.(subjectnum(ss).name) = load(fullfile(subjectnum(ss).folder,subjectnum(ss).name,filesep,'data.mat'));
end 

% 4. Task - Horizontal Head Turns

% subID = fieldnames(data);
% figure
% for ss = 1:length(subID)
%     nexttile
%     plot(data.(subID{ss}).gaitHori.head.gyro)
%     title(subID{ss})
% end

subID = fieldnames(labData);
for ss = 1:length(subID)
    horiHead.(subID{ss}) = labData.(subID{ss}).gaitHori.head.gyro;
end

% Use Shah turn to detect head turns
% Turning Algo
subID = fieldnames(horiHead);
for ss = 1:length(subID) 
    if ss == 6
        turnInfo.(subID{ss}).amplitude = 0;
        turnInfo.(subID{ss}).angVelocity = 0;
    else
        gyro = horiHead.(subID{ss})(:,3);
        impulseDuration = 1.476;
        filterData = ShahFilter(gyro,impulseDuration,100); 
    
        amplitudeThreshold = 10; % deg minimum amplitude for head turn
        velocityThreshold = 15; % deg/s peak velocity to quantify as turn
        minima = 5; % Local Minima     
        impulseDuration = 0.2; % Larger value means more smoothed
        turnInfo.(subID{ss}) = absShahTurn(filterData,gyro,minima,amplitudeThreshold,velocityThreshold,impulseDuration);
    
    end
end

% subID = fieldnames(data);
% figure
% for ss = 1:length(subID)
%     try
%     nexttile
%     plot(horiHead.(subID{ss})(:,3))
%     hold on
%     plot(turnInfo.(subID{ss}).startstop(:,1),horiHead.(subID{ss})(turnInfo.(subID{ss}).startstop(:,1),3),'r*')
%     plot(turnInfo.(subID{ss}).startstop(:,2),horiHead.(subID{ss})(turnInfo.(subID{ss}).startstop(:,2),3),'g*')
%     title(subID{ss})
%     catch
%     end
% end

%% Normative Stats

subID = fieldnames(turnInfo);
for ss = 1:length(subID)    
    vars = fieldnames(turnInfo.(subID{ss}));
    for vv = 1:2
        stats.(vars{vv})(ss,1) = mean(turnInfo.(subID{ss}).(vars{vv})(:));
    end
end

% Pull in subInfo
subInfo = readtable("DHIsubjectInfo.xlsx");

healthyStat.amplitude = stats.amplitude(subInfo.ConcussLabel==0);
healthyStat.angVelocity = stats.angVelocity(subInfo.ConcussLabel==0);
concussStat.amplitude = stats.amplitude(subInfo.ConcussLabel==1);
concussStat.angVelocity = stats.angVelocity(subInfo.ConcussLabel==1);

subInfo.labAmplitude = stats.amplitude;
subInfo.labAngVelocity = stats.angVelocity;
%%
clc
vars = fieldnames(turnInfo.(subID{ss}));
for vv = 1:2
    disp(sprintf("Healthy Mean %s : %f", vars{vv}, mean(nonzeros(healthyStat.(vars{vv})))));
    disp(sprintf("Concuss Mean %s : %f", vars{vv}, mean(nonzeros(concussStat.(vars{vv})))));

end

for vv = 1:2
    disp(sprintf("Comparing %s ", vars{vv}))
    [h,p,ci,stats] = ttest2(nonzeros(healthyStat.(vars{vv})),nonzeros(concussStat.(vars{vv})))

end

%% Pull in process Daily Head Turn

currentPath = cd;
dataPath = dir(fullfile(currentPath,'\ProcessData\Continuous\'));

% Keep only subject folders
axivityFolder = dataPath(~ismember({dataPath.name}, {'.', '..','subject_info.xlsx'}));

% Which Subject to preprocess
subjectnum = axivityFolder(listdlg('PromptString',{'Select subjects to load (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{axivityFolder.name}));

% Load in data
for ss = 1:length(subjectnum)
    lifeData.(subjectnum(ss).name) = load(fullfile(subjectnum(ss).folder,subjectnum(ss).name,filesep,'data.mat'));
end 

%% Normative Stats for Daily Head Turn

variables = {'amplitude','angVelocity'};

subID = fieldnames(lifeData);
for ii = 1:length(subID)
    dayNum = fieldnames(lifeData.(subID{ii}).turnData); 
    clearvars placeAmp
    for dd = 1:length(dayNum)
        try
        for vv = 1:length(variables)
            placeAmp.(variables{vv})(dd) = mean(lifeData.(subID{ii}).turnData.(dayNum{dd}).head.(variables{vv}));
        end
        catch
        end
    end
    for vv = 1:length(variables)
        lifeHeadTurn.(variables{vv})(ii,1) = mean(placeAmp.(variables{vv}));
    end    
end


subInfo.lifeAmplitude = lifeHeadTurn.amplitude;
subInfo.lifeAngVelocity = lifeHeadTurn.angVelocity;

%% Step Count

subID = fieldnames(lifeData);
for ii = 1:length(subID)
    dayNum = fieldnames(lifeData.(subID{ii}).stepData); 
    clearvars placeAmp
    for dd = 1:length(dayNum)
        
        try
            placeAmp.stepCount(dd) = lifeData.(subID{ii}).stepData.(dayNum{dd}).waist.stepCount;
        catch
        end
    end
    fprintf("SubID: %s StepCount: \n",string(subID{ii}))
    nonzeros(placeAmp.stepCount)
    lifeHeadTurn.stepCount(ii,1) = mean(nonzeros(placeAmp.stepCount)); 
end

subInfo.stepCount = lifeHeadTurn.stepCount;


%% scatter plot of daily living head turn velocity vs. in-lab head turn velocity (FGA-3)
close all

% Plot for control group (ConcussLabel == 0)
ctrlIdx = subInfo.ConcussLabel == '0';
scatter(subInfo.lifeAngVelocity(ctrlIdx), subInfo.labAngVelocity(ctrlIdx), 'b')
hold on

% Add labels for control group
for i = find(ctrlIdx)'
    text(subInfo.lifeAngVelocity(i), subInfo.labAngVelocity(i), subInfo.ID{i}, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'blue')
end

% Plot for concussed group (ConcussLabel == 1)
concussIdx = subInfo.ConcussLabel == '1';
scatter(subInfo.lifeAngVelocity(concussIdx), subInfo.Age(concussIdx), 'r')

% Add labels for concussed group
for i = find(concussIdx)'
    text(subInfo.lifeAngVelocity(i), subInfo.Age(i), subInfo.ID{i}, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'red')
end

title('Life vs Lab Angular Velocity')
xlabel('Life Angular Velocity')
ylabel('Lab Angular Velocity')
legend({'Control', 'Concussed'})

%%%% scatter plot of daily living head turn velocity vs. in-lab head turn velocity (FGA-3)
close all

% Plot for control group (ConcussLabel == 0)
ctrlIdx = subInfo.ConcussLabel == '0';
scatter(subInfo.lifeAngVelocity(ctrlIdx), subInfo.Age(ctrlIdx), 'b')
hold on

% Add labels for control group
for i = find(ctrlIdx)'
    text(subInfo.lifeAngVelocity(i), subInfo.Age(i), subInfo.ID{i}, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'blue')
end

% Plot for concussed group (ConcussLabel == 1)
concussIdx = subInfo.ConcussLabel == '1';
scatter(subInfo.lifeAngVelocity(concussIdx), subInfo.Age(concussIdx), 'r')

% Add labels for concussed group
for i = find(concussIdx)'
    text(subInfo.lifeAngVelocity(i), subInfo.Age(i), subInfo.ID{i}, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'red')
end

title('Life vs Lab Angular Velocity')
xlabel('Life Angular Velocity')
ylabel('Age')
legend({'Control', 'Concussed'})

%%
close all
% Plot for control group (ConcussLabel == 0)
ctrlIdx = subInfo.ConcussLabel == 0;
scatter(subInfo.lifeAmplitude(ctrlIdx), subInfo.labAmplitude(ctrlIdx), 'b')
hold on

% Add labels for control group
for i = find(ctrlIdx)'
    text(subInfo.lifeAmplitude(i), subInfo.labAmplitude(i), subInfo.ID{i}, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'blue')
end

% Plot for concussed group (ConcussLabel == 1)
concussIdx = subInfo.ConcussLabel == 1;
scatter(subInfo.lifeAmplitude(concussIdx), subInfo.labAmplitude(concussIdx), 'r')

% Add labels for concussed group
for i = find(concussIdx)'
    text(subInfo.lifeAmplitude(i), subInfo.labAmplitude(i), subInfo.ID{i}, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'red')
end

xlabel('Life Amplitude')
ylabel('Lab Amplitude')
legend({'Control', 'Concussed'})


%% Stats 
% 
% Generalized linear regression model:
%     fgaScore ~ 1 + Age + sexCat + concussionCat
subInfo.Sex = categorical(subInfo.Sex);
subInfo.ConcussLabel = categorical(subInfo.ConcussLabel);
subInfo.adjustedAge = subInfo.Age - mean(subInfo.Age);

glm = fitglm(subInfo, 'lifeAngVelocity ~ 1 + Sex + Age*ConcussLabel')
glm = fitglm(subInfo, 'labAngVelocity ~ 1 + Sex + Age*ConcussLabel')
%%
clc
glm = fitglm(subInfo, 'lifeAngVelocity ~ 1 + Sex + adjustedAge*ConcussLabel')
glm = fitglm(subInfo, 'labAngVelocity ~ 1 + Sex + adjustedAge*ConcussLabel')

%%
fprintf("T-Test MiniBEST")
[h,p] = ttest2(subInfo.MiniBEST(subInfo.ConcussLabel=='0'), ...
               subInfo.MiniBEST(subInfo.ConcussLabel=='1'))

glm_turns = fitglm(subInfo, 'MiniBEST ~ labAngVelocity')
glm_steps = fitglm(subInfo, 'MiniBEST ~ stepCount')
glm_full = fitglm(subInfo, 'MiniBEST ~ lifeAngVelocity + stepCount + Age + Sex + ConcussLabel')
glm_full = fitglm(subInfo, 'MiniBEST ~ lifeAngVelocity + stepCount + Sex + Age*ConcussLabel')

%%

medsmallTurnVel ~ 1 + sexCat + Age*concussionCat

medVel ~ 1 + Age + sexCat
 medVel ~ 1 + sexCat + Age*concussionCat
Try transforming age to be adjustedAge = age-mean(age);
medsmallTurnAmp ~ 1 + sexCat + concussionCat*adjustedAge

%% life v step count
% Plot for control group (ConcussLabel == 0)
ctrlIdx = subInfo.ConcussLabel == '0';
scatter(subInfo.lifeAngVelocity(ctrlIdx), subInfo.stepCount(ctrlIdx), 'b')
hold on

% Add labels for control group
for i = find(ctrlIdx)'
    text(subInfo.lifeAngVelocity(i), subInfo.stepCount(i), subInfo.ID{i}, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'blue')
end

% Plot for concussed group (ConcussLabel == 1)
concussIdx = subInfo.ConcussLabel == '1';
scatter(subInfo.lifeAngVelocity(concussIdx), subInfo.stepCount(concussIdx), 'r')

% Add labels for concussed group
for i = find(concussIdx)'
    text(subInfo.lifeAngVelocity(i), subInfo.stepCount(i), subInfo.ID{i}, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'red')
end

title('Life vs Step')
xlabel('Life Angular Velocity')
ylabel('Step Count')
legend({'Control', 'Concussed'})

%% scatter plot of daily living head turn velocity vs. in-lab head turn velocity (FGA-3)
figure
ctrlIdx = subInfo.ConcussLabel == '0';

scatter(subInfo.labAngVelocity(ctrlIdx), subInfo.stepCount(ctrlIdx), 'b')
hold on

% Add labels for control group
for i = find(ctrlIdx)'
    text(subInfo.labAngVelocity(i), subInfo.stepCount(i), subInfo.ID{i}, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'blue')
end

% Plot for concussed group (ConcussLabel == 1)
concussIdx = subInfo.ConcussLabel == '1';
scatter(subInfo.labAngVelocity(concussIdx), subInfo.stepCount(concussIdx), 'r')

% Add labels for concussed group
for i = find(concussIdx)'
    text(subInfo.labAngVelocity(i), subInfo.stepCount(i), subInfo.ID{i}, ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'Color', 'red')
end

title('Lab vs Step')
xlabel('Lab Angular Velocity')
ylabel('Step Count')
legend({'Control', 'Concussed'})

%% scatter3
figure
ctrlIdx = subInfo.ConcussLabel == '0';
scatter3(subInfo.labAngVelocity(ctrlIdx),subInfo.lifeAngVelocity(ctrlIdx), subInfo.stepCount(ctrlIdx), 'b')
hold on
concussIdx = subInfo.ConcussLabel == '1';
scatter3(subInfo.labAngVelocity(concussIdx), subInfo.lifeAngVelocity(concussIdx), subInfo.stepCount(concussIdx), 'r')
xlabel('lab')
ylabel('life')


%% try doing LME with head turn and step count

lme = fitlme(T, 'HeadTurns ~ StepCount + (1|SubjectID)');
