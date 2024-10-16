% Table of Contents
%     1) Load Data
%     2) Head/Neck/Lumbar Turns
%     3) Wear time
%     4) Steps 
%     5) Head on Trunk Turns
%     6) Mean/StDev/CV
%     7) Ribbon Plots
%     8) Number of Turns per hour ICC
%     9) ICC
cd('C:\Users\chose\Box\Digital Health Pilot - Multimodal Sensing')
addpath('Data\')
addpath('CSTAR\')
cd('C:\Users\chose\Box\C-STAR Pilot')

%% 1) Load Data IN
% addpath(genpath(pwd))
currentFoldPath = cd;

processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
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
        try
        sensor = 'waist';
        placeData.(sensor).stepCount{dd,ii} = data.(id{ii}).stepData.(dayNum{dd}).(sensor).stepCount;
        placeData.(sensor).boutAverage{dd,ii} = mean(data.(id{ii}).stepData.(dayNum{dd}).(sensor).stepPerBout);
        if isnan(placeData.(sensor).boutAverage{dd,ii})
            placeData.(sensor).boutAverage{dd,ii} = [];
        
        end
        catch
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
        try
        for dd = 1:length(placeData.(sensor{ss}).(metrics{mm}))
            average(dd) = mean(cell2mat(placeData.(sensor{ss}).(metrics{mm})(:,dd)));
            sd(dd) = std(cell2mat(placeData.(sensor{ss}).(metrics{mm})(:,dd)));
        end
        catch
            disp(append(sensor{ss},metrics{mm}))
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


%% 
close all

sens = 'head';
metricA = 'amplitudeCV';
metricB = 'angVelocityCV';
% 
% figure
% plot(statsSD.(sens).(metricA)(1:6),statsSD.(sens).angVelocity(1:6),'*')
% hold on
% plot(statsSD.(sens).(metricA)(7:end),statsSD.(sens).angVelocity(7:end),'*')
% xlabel(metricA)
% ylabel('Peak Velocity')
% title(append(sens,' SD'))

figure
plot(statsMean.(sens).(metricA)(1:6),statsMean.(sens).(metricB)(1:6),'*')
hold on
plot(statsMean.(sens).(metricA)(7:end),statsMean.(sens).(metricB)(7:end),'*')
xlabel(metricA)
ylabel(metricB)
title(append(sens,' Mean'))

%%
% cell2mat
sensor = fieldnames(turn.dailyCV);
for ss = 1:length(sensor)
    metrics = fieldnames(turn);
    for mm = 1:length(metrics)
        try
        for dd = 1:length(turn.(sensor{ss}).(metrics{mm}))
            average(dd) = mean(cell2mat(turn.(sensor{ss}).(metrics{mm})(:,dd)));
            sd(dd) = std(cell2mat(turn.(sensor{ss}).(metrics{mm})(:,dd)));
        end
        catch
            disp(append(sensor{ss},metrics{mm}))
        end
        statsMean.(sensor{ss}).(metrics{mm}) = average;
        statsSD.(sensor{ss}).(metrics{mm}) = sd;
    end
end

%%

for i = 1:length(turn.dailyCV.head.amplitude)

    statsMean.head.amplitudeCV(i) = mean(nonzeros(turn.dailyCV.head.amplitude(:,i)));
end

%%
figure
id = fieldnames(data);
for ii = 1:length(id)
    nexttile
    plot(data.(id{ii}).turnData.day2.head.amplitude,data.(id{ii}).turnData.day2.head.angVelocity,'*')
    title(id{ii})
    xlim([0 400])
    ylim([0 600])
end
%%
figure
id = fieldnames(data);
for ii = 1:length(id)
    nexttile
    histogram(data.(id{ii}).turnData.day2.head.amplitude,40,'Normalization','percentage')
    title(id{ii})
    xlim([0 400])
    ylim([0 40])
end

figure
id = fieldnames(data);
for ii = 1:length(id)
    nexttile
    histfit(data.(id{ii}).turnData.day2.head.angVelocity,60,'kernel')
    title(id{ii})
    xlim([0 600])
end

%% 8A) Number of Turns per hour ICC
clearvars headCount

% 1) Check for weartime >10 hours based on paper Melissa rec
% 2) Pull out length of day + populate 24 x 1-hour epoch
nn = 1;
sensor = 'head';
id = fieldnames(data);
for ii = 1:length(id)
    dayNum = fieldnames(data.(id{ii}).timeData);
    for dd = 1:length(dayNum)
        try
        numOfHours = data.(id{ii}).timeData.(dayNum{dd}).(sensor).wearTime;
        dayLength = data.(id{ii}).timeData.(dayNum{dd}).(sensor).dayLength;
        if dayLength > 8630000 && numOfHours > 10
            % dayLength = data.(id{ii}).timeData.(dayNum{dd}).(sensor).dayLength;
            hourLength = round(dayLength/100/60/60); % convert to hours recorded
            hourIndex = hourLength*100*60*60;
            oneHourEpoch = linspace(0,hourIndex,hourLength+1);

            % within each epoch detect number of turns
            % Check index and translate to other measures
            startstop = data.(id{ii}).turnData.(dayNum{dd}).(sensor).startstop;
            
            for ee = 1:length(oneHourEpoch)-1                
                headCount(ee,nn) = length(find(startstop>oneHourEpoch(ee) & startstop<oneHourEpoch(ee+1)));
            end
            nn = nn+1;
        end        
        
        catch
        end        
    end
end

%% 8B) Number of Turns per hour ICC
clearvars avgHeadKin

% 1) Check for weartime >10 hours based on paper Melissa rec
% 2) Pull out length of day + populate 24 x 1-hour epoch
nn = 1;
sensor = 'head';
id = fieldnames(data);
for ii = 1:length(id)
    dayNum = fieldnames(data.(id{ii}).timeData);
    for dd = 1:length(dayNum)
        try
        numOfHours = data.(id{ii}).timeData.(dayNum{dd}).(sensor).wearTime;
        dayLength = data.(id{ii}).timeData.(dayNum{dd}).(sensor).dayLength;
        if dayLength > 8630000 && numOfHours > 10
            % dayLength = data.(id{ii}).timeData.(dayNum{dd}).(sensor).dayLength;
            hourLength = round(dayLength/100/60/60); % convert to hours recorded
            hourIndex = hourLength*100*60*60;
            oneHourEpoch = linspace(0,hourIndex,hourLength+1);

            % within each epoch detect number of turns
            % Check index and translate to other measures
            startstop = data.(id{ii}).turnData.(dayNum{dd}).(sensor).startstop;
            amplitude = data.(id{ii}).turnData.(dayNum{dd}).(sensor).angVelocity;
            
            for ee = 1:length(oneHourEpoch)-1       
                testVar =  find(startstop(:,1)>oneHourEpoch(ee) & startstop(:,1)<oneHourEpoch(ee+1));
                avgHeadKin(ee,nn) = mean(amplitude(testVar));
            end
            nn = nn+1;
        end        
        
        catch
        end        
    end
end

%% 9) ICC

close all
avgHeadKin(isnan(avgHeadKin))=0;
turnPerHour = headCount;
turnPerHour(1:8,:) = [];
fullData = mean(turnPerHour);
taskName = 'turnsPerHour';

for i = 2:height(turnPerHour)
    partialData =  mean(turnPerHour(1:i,:));
    compareData = [partialData',fullData'];
    [r(i-1), LB(i), UB(i),~,~,~] = ICC(compareData, 'A-k');
end

figure
plot(r)
ylim([0 1.2])
xlim([0 24])
yline(0.7,'--')
title(taskName)
xlabel('hour in day')
ylabel('ICC')
saveas(gcf,append(taskName,'_icc'),'emf')

%% Find the awake periods

sensor = 'head';
id = fieldnames(data);
for ii = 6%1:length(id)
    dayNum = fieldnames(data.(id{ii}).timeData);
    figure
    for dd = 1:length(dayNum)
        counts = data.(id{ii}).timeData.(dayNum{dd}).(sensor).activityCounts;
        consecutive_count = 0;
        below_threshold = counts<3;
        nexttile
        plot(below_threshold,'*')
        % for i = 1:length(counts)
        %     if ~below_threshold(i)
        %         consecutive_count = consecutive_count + 1; % Increment count if below threshold
        %     elseif ~below_threshold(i+1)
        %         consecutive_count = consecutive_count + 1; % Reset count if above threshold
        %     else
        %         consecutive_count = 0;
        %     end
        % 
        %     if consecutive_count >= 90
        %         % Mark the indices as part of the period
        %         awake = (i-consecutive_count+1:i);
        %         break
        %     end
        % end
        % 
        % for i = length(counts):-1:1
        %     if below_threshold(i)
        %         consecutive_count = consecutive_count + 1; % Increment count if below threshold
        %     elseif below_threshold(i-1)
        %         consecutive_count = consecutive_count + 1; % Reset count if above threshold
        %     else
        %         consecutive_count = 0;
        %     end
        % 
        %     if consecutive_count >= 90
        %         % Mark the indices as part of the period
        %         beforeBed = (i:i+consecutive_count-1);
        %         break
        %     end
        % end

    end
end

% find first period of 90min to detect that it's awake








