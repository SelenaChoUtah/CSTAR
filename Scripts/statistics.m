% This script does basic descriptive statistic
% averaged across the week and the coefficient of variation (CV) 
% was calculated for the following measures: 
%     (i) number of turns per hour, 
%     (ii) turn angle amplitude, 
%     (iii) turn duration, 
%     (iv) turn peak velocity,
%     (v) number of steps to complete a turn.
% 
% 
%     Created by Selena Cho
%     Last Updated: 7/31/24
%     Better tha normativeStatsScript.m
%--------------------------------------------------------------------------
cd('C:\Users\chose\Box\C-STAR Pilot')
addpath(genpath(pwd))
currentFoldPath = cd;

processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
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

%% Turn Descriptive Statistics

turnMetric = {'amplitude', 'angVelocity','turnDuration'};
id = fieldnames(data);
for i = 1:length(id)
    dayNum = fieldnames(data.(id{i}).turnData);
    for d = 1:length(dayNum)
        sensor = fieldnames(data.(id{i}).turnData.(dayNum{d}));
        for s = 1:length(sensor)
            for t = 1:length(turnMetric)
                turn.dailyAverage.(sensor{s}).(turnMetric{t}){d,i} = mean(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
                turn.dailyStDev.(sensor{s}).(turnMetric{t}){d,i} = std(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
                turn.dailyNumber.(sensor{s}).(turnMetric{t}){d,i} = length(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
                turn.dailyCV.(sensor{s}).(turnMetric{t}){d,i} = std(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}))/mean(data.(id{i}).turnData.(dayNum{d}).(sensor{s}).(turnMetric{t}));
                
            end
        end
    end
end

%%

statistic = fieldnames(turn);
for i = 1:length(statistic)
    disp(statistic{i})
    sensor = fieldnames(turn.(statistic{i}));
    for s  = 1:length(sensor)
        % disp(sensor{s})
        metric = fieldnames(turn.(statistic{i}).(sensor{s}));
        for m = 1:length(metric)
            % disp(metric{m})
            for c = 1:size(turn.(statistic{i}).(sensor{s}).(metric{m}),2)
                averagePerPerson(c,1) = mean(cell2mat(turn.(statistic{i}).(sensor{s}).(metric{m})(:, c)));
            end
            averageAcross.(statistic{i}).(sensor{s}).(metric{m}) = [mean(averagePerPerson), std(averagePerPerson)];
        end
    end
end


%% Figure head turns vs lumbar turns

head = [];
lumbar = [];
id = fieldnames(data);
for i = 1:length(id)
    dayNum = fieldnames(data.(id{i}).turnData);
    for d = 1:length(dayNum)
        number = length(data.(id{i}).turnData.(dayNum{d}).(sensor).amplitude);
        
        try
        sensor = "head";
        number = length(data.(id{i}).turnData.(dayNum{d}).(sensor).amplitude);
        head = [head;number];
        sensor = "waist";
        number = length(data.(id{i}).turnData.(dayNum{d}).(sensor).amplitude);
        lumbar = [lumbar;number];
        catch
        end
    end
end












