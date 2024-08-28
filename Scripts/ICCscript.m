%% Figure out ICC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath(pwd))

currentFoldPath = cd;
processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

% Load Subject Data 
for i = 1:numel(subjectnum)
    % All of subject data saved in data
    id = string(subjectnum(i).name);
    data.(id) = load(fullfile(subjectnum(i).folder,subjectnum(i).name,'data.mat'));   

end

%% ------------------------------------------------------------------------
clearvars compData
task = {'amplitude','angVelocity'};
% With number of head turns, create structure of days x num of subjects
id = fieldnames(data);
j = 1;
for i = 1:length(id)
    try
    dataStruct = 'turnData';
    % check if there is at least 5 
    % subDay(i,1) = length(fieldnames(data.(id{i}).(dataStruct)));
    if length(fieldnames(data.(id{i}).(dataStruct))) >= 5
        for t = 1:length(task)
            dayNum = fieldnames(data.(id{i}).(dataStruct));
            for d = 1:5
                compData.(task{t})(j,d) = mean(data.(id{i}).(dataStruct).(dayNum{d}).head.(task{t}));
                compData.number(j,d) = length(data.(id{i}).(dataStruct).(dayNum{d}).head.(task{t}));
            end
        end
        j = j+1;
    end
    catch
        disp('No sensor')
    end
end

for t = 1:length(task)
    compBaseline.(task{t}) = mean(compData.(task{t}),1);
end

%% Looping through diff day averages
close all
% task = {'amplitude','angVelocity','number'};
taskName = 'number';
fullData =  mean(compData.(taskName),2);
for i = 1:5
    partialData =  mean(compData.(taskName)(:,1:i),2);
    compareData = [partialData,fullData];

    [r(i), LB(i), UB(i),~,~,~] = ICC(compareData, 'A-k');
    % 
    % ICC(i) = computeICC(partialData, fullData, '2-1');
    % 
    % % SDD
    % meanActivity = mean([partialData, fullData]);
    % difference = abs(partialData - fullData);
    % SDD(i) = 1.96 * std(difference) / mean(meanActivity) * 100; % SDD as a percentage of the mean
end

figure
plot(r)
ylim([0 1.2])
yline(0.7,'--')
title(taskName)
xlabel('days')
ylabel('ICC')
saveas(gcf,append(taskName,'_icc'),'emf')

%% Turns per hour ICC
close all

% task = {'amplitude','angVelocity','number'};
turnPerHour = mean(allTurnPerHour,2);
fullData = mean(turnPerHour);
taskName = 'turnsPerHour';

for i = 1:24
    partialData =  mean(turnPerHour(1:i));
    compareData = [partialData,fullData]
    [r(i), LB(i), UB(i),~,~,~] = ICC(compareData, 'A-k');
end

figure
plot(r)
ylim([0 1.2])
yline(0.7,'--')
title(taskName)
xlabel('days')
ylabel('ICC')
saveas(gcf,append(taskName,'_icc'),'emf')

