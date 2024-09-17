% Table of Contents
%     1) Load Data
%     2) Head/Neck/Lumbar Turns
%     3) Wear time
%     4) Steps 
%     5) Head on Trunk Turns
%     6) Mean/StDev/CV
%     7) Ribbon Plots

%% 1) Load Data IN
addpath(genpath(pwd))
currentFoldPath = cd('C:\Users\chose\Box\C-STAR Pilot\Data');

processPath = dir(fullfile(currentFoldPath,'\Process'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

% Load Data 

for ii = 1:numel(subjectnum)
    % Save Data into Process
    id = string(subjectnum(ii).name);
    % disp(id)   
    data.(id) = load(fullfile(subjectnum(ii).folder,subjectnum(ii).name,'data.mat'));   

end

clearvars -except data

%% 2) Head/Neck/Lumbar Turns ---------------------------------------------%
clearvars placeData
metrics = {'amplitude','angVelocity','turnDuration'};

% go in and extract amp, angVel, number
id = fieldnames(data);
for ii = 1:length(id)
    dayNum = fieldnames(data.(id{ii}).turnData);
    for dd = 1:length(dayNum)
        sensor = fieldnames(data.(id{ii}).turnData.(dayNum{dd}));
        for ss = 1:length(sensor)
            for mm = 1:length(metrics)                
                placeData.(sensor{ss}).(metrics{mm}){dd,ii} = mean(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(metrics{mm}));
                placeData.(sensor{ss}).frequency{dd,ii} = length(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(metrics{mm}));
            end
        end
    end
end

% Turns per hour
id = fieldnames(data);
for ii = 1:length(id)
    dayNum = fieldnames(data.(id{ii}).turnData);
    for dd = 1:length(dayNum)
        sensor = fieldnames(data.(id{ii}).turnData.(dayNum{dd}));
        for ss = 1:length(sensor)
            dayLength = data.(id{ii}).timeData.(dayNum{dd}).(sensor{ss}).dayLength;
            numHoursIdx = linspace(1,dayLength,25);
            index = data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).startstop(:,1);
            for nn = 2:length(numHoursIdx)
                turnPerHour(nn-1) = length(find(index>numHoursIdx(nn-1) & index<numHoursIdx(nn)));
                % stepsPerHour(nn-1) = 
            end
            placeData.(sensor{ss}).turnsPerHourMean{dd,ii} = mean(turnPerHour);
            placeData.(sensor{ss}).turnsPer24hr(:,dd) = turnPerHour';
            placeData.(sensor{ss}).turnsPerHourSD{dd,ii} = std(turnPerHour);
        end
    end
end

%% 3) Wear time

id = fieldnames(data);
for ii = 1:length(id)
    dayNum = fieldnames(data.(id{ii}).timeData);
    for dd = 1:length(dayNum)
        sensor = fieldnames(data.(id{ii}).timeData.(dayNum{dd}));
        for ss = 1:length(sensor)
            placeData.(sensor{ss}).wearTime{dd,ii} = data.(id{ii}).timeData.(dayNum{dd}).(sensor{ss}).wearTime;
        end
    end
end


%% 4) Steps 

id = fieldnames(data);
for ii = 1:length(id)
    dayNum = fieldnames(data.(id{ii}).stepData);
    for dd = 1:length(dayNum)
        sensor = 'waist';
        placeData.(sensor).stepCount{dd,ii} = data.(id{ii}).stepData.(dayNum{dd}).(sensor).stepCount;
        placeData.(sensor).boutAverage{dd,ii} = mean(data.(id{ii}).stepData.(dayNum{dd}).(sensor).stepPerBout);
        if isnan(placeData.(sensor).boutAverage{dd,ii})
            placeData.(sensor).boutAverage{dd,ii} = [];
        end
    end
end

%% 5) Head on Trunk Turns

id = fieldnames(data);
for ii = 1:length(id)
    dayNum = fieldnames(data.(id{ii}).headOnTrunkCount);
    for dd = 1:length(dayNum)
        placeData.head.ratio{dd,ii} = data.(id{ii}).headOnTrunkCount.(dayNum{dd})/data.(id{ii}).individual.(dayNum{dd});
        placeData.head.individual{dd,ii} = data.(id{ii}).headOnTrunkCount.(dayNum{dd});
    end
end


%% 6) Mean/StDev/CV

% cell2mat
sensor = fieldnames(placeData);
for ss = 1:length(sensor)
    metrics = fieldnames(placeData.(sensor{ss}));
    for mm = 1:length(metrics)
        for dd = 1:length(placeData.(sensor{ss}).(metrics{mm}))
            average(dd) = mean(cell2mat(placeData.(sensor{ss}).(metrics{mm})(:,dd)));
            sd(dd) = std(cell2mat(placeData.(sensor{ss}).(metrics{mm})(:,dd)));
        end
        statsMean.(sensor{ss}).(metrics{mm}) = average;
        statsSD.(sensor{ss}).(metrics{mm}) = sd;
    end
end


sensor = fieldnames(statsMean);
for ss = 1:length(sensor)
    metrics = fieldnames(placeData.(sensor{ss}));
    for mm = 1:length(metrics)
        statData.(sensor{ss}).(metrics{mm}).mean = mean(statsMean.(sensor{ss}).(metrics{mm}));
        statData.(sensor{ss}).(metrics{mm}).stDev = mean(statsSD.(sensor{ss}).(metrics{mm}));
        statData.(sensor{ss}).(metrics{mm}).cv = mean(statsSD.(sensor{ss}).(metrics{mm})./statsMean.(sensor{ss}).(metrics{mm}));
        statData.(sensor{ss}).(metrics{mm}).cvSD = std(statsSD.(sensor{ss}).(metrics{mm})./statsMean.(sensor{ss}).(metrics{mm}));
    end
end

%% 7) Ribbon Plot Days vs Hours
close all
[day,hr] = meshgrid(1:6,1:24);
figure
plot3(day,hr,placeData.head.turnsPer24hr,'LineWidth',5)
xlabel("day number")
ylabel("hour in day")
zlabel("Number of turns per hour")
set(gca, 'YDir', 'reverse');
grid on





