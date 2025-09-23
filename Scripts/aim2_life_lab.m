%% Loading life data

cd('D:\CSTAR')
addpath(genpath('CSTAR\'))
addpath(genpath('Data\'))

% Load in the excel data
subInfo = readtable("CSTAR\subject_info.xlsx",'sheet','All');

% Load Life Data

currentFoldPath = cd;
processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));


% Load Life Data 
for ii = 1:numel(subjectnum)
    % Save Data into Process
    id = string(subjectnum(ii).name);
    % disp(id)   
    data.(id) = load(fullfile(subjectnum(ii).folder,subjectnum(ii).name,'data.mat'));   
end

% Remove duplicate data
subID = fieldnames(data);
rowsToKeep = ismember(subID, subInfo.ID);

% Remove rows where data.name does not exist in subInfo.ID
subID = subID(rowsToKeep);

for i = 1:length(subID)
    dataClean.(subID{i}) = data.(subID{i});
end

% Generating a lot of daily life stats and saving to subInfo

samplingRate = 100;
samplesPerHour = 3600 * samplingRate;
variables = ["amplitude", "angVelocity"];

subID = fieldnames(dataClean);

for v = 1:length(variables)
    varName = variables(v);
    
    for ii = 1:length(subID)
        dayNum = fieldnames(dataClean.(subID{ii}).turnData);
        
        for dd = 1:length(dayNum)
            sensors = {'head','neck'};
            % sensors = fieldnames(dataClean.(subID{ii}).turnData.(dayNum{dd}));
            
            for ss = 1%:length(sensors)
                thisSensor = sensors{ss};

                if ~isfield(dataClean.(subID{ii}).turnData.(dayNum{dd}), thisSensor)
                    continue
                end

                % wear time check
                if isfield(dataClean.(subID{ii}), 'timeData') && ...
                   isfield(dataClean.(subID{ii}).timeData.(dayNum{dd}), thisSensor) && ...
                   dataClean.(subID{ii}).timeData.(dayNum{dd}).(thisSensor).wearTime < 10
                    continue
                end                

                if ~isfield(dataClean.(subID{ii}).turnData.(dayNum{dd}).(thisSensor), varName)
                    continue
                end

                dataVec = dataClean.(subID{ii}).turnData.(dayNum{dd}).(thisSensor).(varName);
                startstop = dataClean.(subID{ii}).turnData.(dayNum{dd}).(thisSensor).startstop;
                timeIdx = startstop(:,1);

                % Initialize hourly stats
                hourlyMean = nan(1, 24);
                hourlyMedian = nan(1, 24);
                hourlyP95 = nan(1, 24);
                hourlyCount = nan(1, 24);

                for hr = 0:23
                    hrStart = hr * samplesPerHour;
                    hrEnd = (hr + 1) * samplesPerHour;
                    inHour = timeIdx >= hrStart & timeIdx < hrEnd;
                    if any(inHour)
                        hourlyData = dataVec(inHour);
                        hourlyMean(hr + 1) = mean(hourlyData);
                        hourlyMedian(hr + 1) = median(hourlyData);
                        hourlyP95(hr + 1) = prctile(hourlyData, 95);
                        hourlyCount(hr + 1) = sum(inHour);
                    end
                end

                % Store daily summary stats
                allStats.(subID{ii}).(thisSensor).(varName).hourlyMean(dd, :) = hourlyMean;
                allStats.(subID{ii}).(thisSensor).(varName).hourlyMedian(dd, :) = hourlyMedian;
                allStats.(subID{ii}).(thisSensor).(varName).hourlyP95(dd, :) = hourlyP95;
                allStats.(subID{ii}).(thisSensor).(varName).hourlyTurnCount(dd, :) = hourlyCount;

                allStats.(subID{ii}).(thisSensor).(varName).dailyMean(dd) = mean(dataVec, 'omitnan');
                allStats.(subID{ii}).(thisSensor).(varName).dailyMedian(dd) = median(dataVec, 'omitnan');
                allStats.(subID{ii}).(thisSensor).(varName).dailyP95(dd) = prctile(dataVec, 95);
                allStats.(subID{ii}).(thisSensor).(varName).dailyTurnCount(dd) = length(dataVec);

                validHour = ~isnan(hourlyMean);
                if any(validHour)
                    allStats.(subID{ii}).(thisSensor).(varName).intraDayCV(dd) = ...
                        std(hourlyMean(validHour)) / mean(hourlyMean(validHour));
                else
                    allStats.(subID{ii}).(thisSensor).(varName).intraDayCV(dd) = NaN;
                end

                % Small vs Large Turns
                isSmall = dataVec < 45;
                isLarge = dataVec >= 45;
                
                % Initialize containers
                turnTypes = {'Small', 'Large'};
                turnMasks = {isSmall, isLarge};
                
                for tt = 1:2
                    turnLabel = turnTypes{tt};
                    mask = turnMasks{tt};
                    dataSubset = dataVec(mask);
                    timeSubset = timeIdx(mask);
                
                    hourlyMean = nan(1, 24);
                    hourlyMedian = nan(1, 24);
                    hourlyP95 = nan(1, 24);
                    hourlyCount = nan(1, 24);
                
                    for hr = 0:23
                        hrStart = hr * samplesPerHour;
                        hrEnd = (hr + 1) * samplesPerHour;
                        inHour = timeSubset >= hrStart & timeSubset < hrEnd;
                
                        if any(inHour)
                            hourlyData = dataSubset(inHour);
                            hourlyMean(hr + 1) = mean(hourlyData);
                            hourlyMedian(hr + 1) = median(hourlyData);
                            hourlyP95(hr + 1) = prctile(hourlyData, 95);
                            hourlyCount(hr + 1) = sum(inHour);
                        end
                    end
                
                    % Store stats for Small/Large turns
                    allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'HourlyMean'])(dd, :) = hourlyMean;
                    allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'HourlyMedian'])(dd, :) = hourlyMedian;
                    allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'HourlyP95'])(dd, :) = hourlyP95;
                    allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'HourlyCount'])(dd, :) = hourlyCount;
                
                    allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'DailyMean'])(dd) = mean(dataSubset, 'omitnan');
                    allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'DailyMedian'])(dd) = median(dataSubset, 'omitnan');
                    allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'DailyP95'])(dd) = prctile(dataSubset, 95);
                    allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'DailyStd'])(dd) = std(dataSubset, 'omitnan');
                    allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'TurnCount'])(dd) = length(dataSubset);
                
                    validHour = ~isnan(hourlyMean);
                    if any(validHour)
                        allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'IntraDayCV'])(dd) = ...
                            std(hourlyMean(validHour)) / mean(hourlyMean(validHour));
                    else
                        allStats.(subID{ii}).(thisSensor).(varName).([turnLabel 'IntraDayCV'])(dd) = NaN;
                    end
                end
            end
        end
    end
end

subID = fieldnames(allStats);
for ii = 1:length(subID)
    sensors = fieldnames(allStats.(subID{ii}));
    for ss = 1:length(sensors)
        thisSensor = sensors{ss};   
        varName = fieldnames(allStats.(subID{ii}).(thisSensor));
        for vv = 1:length(varName)
            statsVar = fieldnames(allStats.(subID{ii}).(thisSensor).(varName{vv}));
            for sv = 1:length(statsVar)
                theStat = nonzeros(allStats.(subID{ii}).(thisSensor).(varName{vv}).(statsVar{sv})(:));

                % save info to subINFO
                rowNumber = find(strcmp(subInfo.DHI_ID, subID{ii}));
                colName = append(thisSensor,'_',varName{vv},statsVar{sv});
                subInfo.(colName)(rowNumber) = mean(theStat,'omitnan'); 

            end
        end
    end
end

%% Loading Lab Data
dataPath = dir(fullfile(currentFoldPath,'\DHI_data\PreprocessData\Lab\Axivity\'));

% Keep only subject folders
axivityFolder = dataPath(~ismember({dataPath.name}, {'.', '..','subject_info.xlsx'}));

% Which Subject to preprocess
subjectnum = axivityFolder(listdlg('PromptString',{'Select subjects to load (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{axivityFolder.name}));

% Load in data
for ss = 1:length(subjectnum)
    labData.(subjectnum(ss).name) = load(fullfile(subjectnum(ss).folder,subjectnum(ss).name,filesep,'data.mat'));
end 

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

subID = fieldnames(turnInfo);
for ii = 1:length(subID)
    stats = fieldnames(turnInfo.(subID{ii}));
    for ss = 1:2
        theStat = turnInfo.(subID{ii}).(stats{ss});
        % save info to subINFO
        rowNumber = find(strcmp(subInfo.DHI_ID, subID{ii}));
        colName = stats{ss};
        subInfo.(colName)(rowNumber) = mean(theStat,'omitnan'); 
    end
end

%% Scatterplot

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

%% T-Test and Violin

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
    % saveas(gcf,sprintf('Violin Plot %s', xVar),'svg')
    
end