%--------------------------------------------------------------------------
% 
%
%     Script for ISPGR 2025
%     Measuring Head Movements During Free-Living Daily Life 
%     This script takes the daily metrics of head turn kinematics
%     and other continuous monitoring metrics and compares it
%     to in-lab metrics. Maybe there's some correlations, maybe
%     there isn't. But we're just taking a looksies.
% 
% 
%     Last updated 6/1/2025
% 
%--------------------------------------------------------------------------


% Path for HC
% cd('C:\Users\chose\Box\C-STAR Pilot')
cd('D:\CSTAR')
addpath(genpath('CSTAR\'))
addpath(genpath('Data\'))

currentFoldPath = cd;
processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

clearvars data

% Load CSTAR Data 
for ii = 1:numel(subjectnum)
    % Save Data into Process
    id = string(subjectnum(ii).name);
    % disp(id)   
    data.(id) = load(fullfile(subjectnum(ii).folder,subjectnum(ii).name,'data.mat'));   
end


% % Path for mTBI data
% cd('C:\Users\chose\Box\DHI-Lab')
% addpath(genpath('CSTAR\'))
% addpath(genpath('ProcessData\'))
% 
% currentFoldPath = cd;
% processPath = dir(fullfile(currentFoldPath,'\ProcessData\Continuous'));
% processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
% subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
%         'SelectionMode','multiple','ListString',{processPath.name}));
% 
% % Load DHI Data 
% for ii = 1:numel(subjectnum)
%     % Save Data into Process
%     id = string(subjectnum(ii).name);
%     % disp(id)   
%     data.(id) = load(fullfile(subjectnum(ii).folder,subjectnum(ii).name,'data.mat'));   
% end

% Load in the excel data

subInfo = readtable("CSTAR\subject_info.xlsx",'sheet','All');

subInfo(subInfo.ID == "DHI022", :) = [];
subInfo(subInfo.ID == "DHI023", :) = [];
subInfo(subInfo.ID == "S20", :) = [];

% Remove duplicate data
subID = fieldnames(data);
rowsToKeep = ismember(subID, subInfo.ID);

% Remove rows where data.name does not exist in subInfo.ID
subID = subID(rowsToKeep);

for i = 1:length(subID)
    dataClean.(subID{i}) = data.(subID{i});
end

%% Stride Time 

subID = fieldnames(dataClean);
stepTime = table();

for ii = 1:length(subID)
    dayNum = fieldnames(dataClean.(subID{ii}).stepData);
    avgStepTimeAll = [];
    for dd = 1:length(dayNum)
        try
        avgStepTimeAll(end+1) = mean(dataClean.(subID{ii}).stepData.(dayNum{dd}).waist.strideTimeAll(find(dataClean.(subID{ii}).stepData.(dayNum{dd}).waist.strideTimeAll<1)));
        catch
            warning('Stride time data not available for %s on day %s', subID{ii}, dayNum{dd});
        end
    end

    rowNumber = find(strcmp(subInfo.ID, subID{ii}));
    % subInfo.ID(rowNumber) = string(subID{ii});
    subInfo.meanStepTime(rowNumber) = mean(avgStepTimeAll,'omitnan');
    subInfo.stdStepTime(rowNumber) = std (avgStepTimeAll,'omitnan');
end

% mean()

%% Average Daily Head Turns

% Calculate average daily head turns for each subject
subID = fieldnames(dataClean);
for ii = 1:length(subID)
    clearvars placeholder
    dayNum = fieldnames(dataClean.(subID{ii}).turnData);
    for dd = 1:length(dayNum)
        try
            sensor = {'head', 'neck', 'waist'};
            for ss = 1:length(sensor)
                vari = fieldnames(dataClean.(subID{ii}).turnData.(dayNum{dd}).(sensor{ss}));
                if length(nonzeros(dataClean.(subID{ii}).turnData.(dayNum{dd}).(sensor{ss}).amplitude)) > 1000
                for vv = 1:length(vari)
                    placeholder.(sensor{ss}).(vari{vv})(dd, 1) = mean(nonzeros(dataClean.(subID{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{vv})));
                end
                placeholder.(sensor{ss}).count(dd, 1) = length(nonzeros(dataClean.(subID{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{vv})));
                end
            end
        catch
            % warning('Data not available for %s on day %s', subID{ii}, dayNum{dd});
        end
    end

    % Save data into table
    for ss = 1:length(sensor)
        vari = fieldnames(placeholder.(sensor{ss}));
        for vv = 1:length(vari)
            rowNumber = find(strcmp(subInfo.ID, subID{ii}));
            colName = append(sensor{ss},'_',vari{vv});
            subInfo.(colName)(rowNumber) = mean(nonzeros(placeholder.(sensor{ss}).(vari{vv})),'omitnan'); 
            % fprintf("sensor: %s, variable:, %s, mean: %2.2f\n",sensor{ss},vari{vv},mean(placeholder.(sensor{ss}).(vari{vv})))
            % meanStats.(sensor{ss}).(vari{vv})(ii,1) = mean(placeholder.(sensor{ss}).(vari{vv})); 
        end
    end  
end

%% Small And Large Head Turns
clc
clearvars placeholder2
subID = fieldnames(dataClean);
for ii = 1:length(subID)
    dayNum = fieldnames(dataClean.(subID{ii}).turnData);
    for dd = 1:length(dayNum)
        try
            sensor = {'head', 'neck'};
            for ss = 1:length(sensor)
                if length(nonzeros(dataClean.(subID{ii}).turnData.(dayNum{dd}).(sensor{ss}).amplitude)) > 1000
                variT = 'amplitude';
                threshold = 30;
                turns = dataClean.(subID{ii}).turnData.(dayNum{dd}).(sensor{ss}).(variT);
                keep = turns>threshold;

                % Manual 
                if strcmp(variT,'amplitude')
                    placeholder2.(sensor{ss}).amplitudeThresh(dd, 1) = mean(nonzeros(turns(keep)));
                    other = dataClean.(subID{ii}).turnData.(dayNum{dd}).(sensor{ss}).angVelocity;
                    placeholder2.(sensor{ss}).angVelocityThresh(dd, 1) = mean(nonzeros(other(keep)));
                    placeholder2.(sensor{ss}).countThreshold(dd,1) = length(other(keep));
                else
                    placeholder2.(sensor{ss}).angVelocityThresh(dd, 1) = mean(nonzeros(turns(keep)));
                    other = dataClean.(subID{ii}).turnData.(dayNum{dd}).(sensor{ss}).amplitude;
                    placeholder2.(sensor{ss}).amplitudeThresh(dd, 1) = mean(nonzeros(other(keep)));
                    placeholder2.(sensor{ss}).countThreshold(dd,1) = length(other(keep));
                end
                end

            end
        catch
            % warning('Data not available for %s on day %s', subID{ii}, dayNum{dd});
        end
    end

    % Save data into table
    for ss = 1:length(sensor)
        vari = fieldnames(placeholder2.(sensor{ss}));
        for vv = 1:length(vari)
            rowNumber = find(strcmp(subInfo.ID, subID{ii}));
            colName = append(sensor{ss},'_',vari{vv},num2str(threshold));
            subInfo.(colName)(rowNumber) = mean(nonzeros(placeholder2.(sensor{ss}).(vari{vv}))); 
            % fprintf("sensor: %s, variable:, %s, mean: %2.2f\n",sensor{ss},vari{vv},mean(placeholder2.(sensor{ss}).(vari{vv})))
            % meanStats.(sensor{ss}).(vari{vv})(ii,1) = mean(placeholder.(sensor{ss}).(vari{vv})); 
        end
    end  
end

%% Stabilization vs Volitional Head Turns
clc
% Calculate average daily head turns for each subject
subID = fieldnames(dataClean);
for ii = 1:length(subID)
    % clearvars placeholder2
    dayNum = fieldnames(dataClean.(subID{ii}).headOnTrunkCount);
    for dd = 1:length(dayNum)
        try
            % it's not sensor
            sensor = {'stabilization','volitional'};
            for ss = 1:length(sensor)
                 vari = fieldnames(dataClean.(subID{ii}).headOnTrunkCount.(dayNum{dd}).(sensor{ss}));
                 for vv = 1:2
                    placeholder2.(sensor{ss}).(vari{vv})(dd, 1) = mean(nonzeros(dataClean.(subID{ii}).headOnTrunkCount.(dayNum{dd}).(sensor{ss}).(vari{vv})));          
                 end
                 placeholder2.(sensor{ss}).count(dd,1) = length(dataClean.(subID{ii}).headOnTrunkCount.(dayNum{dd}).(sensor{ss}).(vari{vv}));
            end
        catch
            % warning('Data not available for %s on day %s', id{ii}, dayNum{dd});
        end
    end
    % placeholder2.(sensor{ss}).angVel

    % fprintf('Subject: %s',subID{ii})
    % placeholder.(sensor{ss}).(vari{vv})

    % Save data into table
    for ss = 1:length(sensor)
        vari = fieldnames(placeholder2.(sensor{ss}));
        for vv = 1:length(vari)
            rowNumber = find(strcmp(subInfo.ID, subID{ii}));
            colName = append(sensor{ss},'_',vari{vv});
            subInfo.(colName)(rowNumber) = mean(nonzeros(placeholder2.(sensor{ss}).(vari{vv})),'omitnan'); 
            % fprintf("sensor: %s, variable:, %s, mean: %2.2f\n",sensor{ss},vari{vv},mean(placeholder.(sensor{ss}).(vari{vv})))
            % meanStats.(sensor{ss}).(vari{vv})(ii,1) = mean(placeholder.(sensor{ss}).(vari{vv})); 
        end
    end  
end

%% Threshold Stabilization vs Volitional Head Turns
clc
% Calculate average daily head turns for each subject
subID = fieldnames(dataClean);
for ii = 1%:length(subID)
    % clearvars placeholder2
    dayNum = fieldnames(dataClean.(subID{ii}).headOnTrunkCount);
    for dd = 1:length(dayNum)
        try
            % it's not sensor
            sensor = {'stabilization','volitional'};
            for ss = 1:2%length(sensor)
                 vari = fieldnames(dataClean.(subID{ii}).headOnTrunkCount.(dayNum{dd}).(sensor{ss}));
                 for vv = 2
                    v1 = dataClean.(subID{ii}).headOnTrunkCount.(dayNum{dd}).(sensor{ss}).(vari{vv});
                    threshold = 0;
                    placeholder2.(sensor{ss}).(vari{vv})(dd, 1) = mean(nonzeros(v1(v1<threshold)));          
                 end
                 placeholder2.(sensor{ss}).count(dd,1) = length(dataClean.(subID{ii}).headOnTrunkCount.(dayNum{dd}).(sensor{ss}).(vari{vv}));
            end
        catch
            % warning('Data not available for %s on day %s', id{ii}, dayNum{dd});
        end
    end
    % placeholder2.(sensor{ss}).angVel

    % fprintf('Subject: %s',subID{ii})
    % placeholder.(sensor{ss}).(vari{vv})

    % Save data into table
    for ss = 1:length(sensor)
        vari = fieldnames(placeholder2.(sensor{ss}));
        for vv = 1:length(vari)
            rowNumber = find(strcmp(subInfo.ID, subID{ii}));
            colName = append(sensor{ss},'_',vari{vv});
            subInfo.(colName)(rowNumber) = mean(nonzeros(placeholder2.(sensor{ss}).(vari{vv})),'omitnan'); 
            % fprintf("sensor: %s, variable:, %s, mean: %2.2f\n",sensor{ss},vari{vv},mean(placeholder.(sensor{ss}).(vari{vv})))
            % meanStats.(sensor{ss}).(vari{vv})(ii,1) = mean(placeholder.(sensor{ss}).(vari{vv})); 
        end
    end  
end

%% Small and Large Stabilization vs Volitional Head Turns
% clc

% Calculate average daily head turns for each subject
subID = fieldnames(dataClean);
for ii = 1:length(subID)
    % clearvars placeholder2
    dayNum = fieldnames(dataClean.(subID{ii}).headOnTrunkCount);
    for dd = 1:length(dayNum)
        try
            % it's not sensor
            sensor = {'stabilization','volitional'};
            for ss = 1:length(sensor)

                variT = 'amplitude';
                threshold = 20;
                turns = dataClean.(subID{ii}).headOnTrunkCount.(dayNum{dd}).(sensor{ss}).(variT);
                keep = turns>threshold;

                % Manual 
                if strcmp(variT,'amplitude')
                    placeholder2.(sensor{ss}).amplitudeThresh(dd, 1) = mean(nonzeros(turns(keep)));
                    other = dataClean.(subID{ii}).headOnTrunkCount.(dayNum{dd}).(sensor{ss}).angVel;
                    placeholder2.(sensor{ss}).angVelocityThresh(dd, 1) = mean(nonzeros(other(keep)));
                    placeholder2.(sensor{ss}).countThreshold(dd,1) = length(other(keep));
                else
                    placeholder2.(sensor{ss}).angVelocityThresh(dd, 1) = mean(nonzeros(turns(keep)));
                    other = dataClean.(subID{ii}).headOnTrunkCount.(dayNum{dd}).(sensor{ss}).amplitude;
                    placeholder2.(sensor{ss}).amplitudeThresh(dd, 1) = mean(nonzeros(other(keep)));
                    placeholder2.(sensor{ss}).countThreshold(dd,1) = length(other(keep));
                end
            end
        catch
            % warning('Data not available for %s on day %s', id{ii}, dayNum{dd});
        end
    end
    % placeholder2.(sensor{ss}).angVelocityThresh

    % fprintf('Subject: %s',subID{ii})
    % placeholder.(sensor{ss}).(vari{vv})

    % Save data into table
    for ss = 1:length(sensor)
        vari = fieldnames(placeholder2.(sensor{ss}));
        for vv = 1:length(vari)
            rowNumber = find(strcmp(subInfo.ID, subID{ii}));
            colName = append(sensor{ss},'_',vari{vv},num2str(threshold+10));
            % placeholder2.(sensor{ss}).(vari{vv})
            subInfo.(colName)(rowNumber) = mean(nonzeros(placeholder2.(sensor{ss}).(vari{vv})),'omitnan'); 
            % fprintf("sensor: %s, variable:, %s, mean: %2.2f\n",sensor{ss},vari{vv},mean(placeholder.(sensor{ss}).(vari{vv})))
            % meanStats.(sensor{ss}).(vari{vv})(ii,1) = mean(placeholder.(sensor{ss}).(vari{vv})); 
        end
    end  
end




%% Plotting freely

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


%%


% Split into small and large turns

id = subInfo.ID;
for ii = 1:length(id)
    dayNum = fieldnames(data.(id{ii}).turnData);
    for dd = 1:length(dayNum)
        try
        sensor = {'head','neck','waist'};
        for ss = 1:length(sensor)
            vari = fieldnames(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}));
            for vv = 1%:2
                small = find(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{vv})<45);
                large = find(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{vv})>=45);

                placeholder.(sensor{ss}).smallAmp(dd,1) = mean(nonzeros(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{1})(small)));
                placeholder.(sensor{ss}).largeAmp(dd,1) = mean(nonzeros(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{1})(large)));

                placeholder.(sensor{ss}).smallVel(dd,1) = mean(nonzeros(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{2})(small)));
                placeholder.(sensor{ss}).largeVel(dd,1) = mean(nonzeros(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{2})(large)));

                % fprintf("sensor: %s, variable:, %s, mean: %2.2f\n",sensor{ss},vari{vv},mean(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{vv})))               
                % placeholder.(sensor{ss}).(vari{vv})(dd,1) = mean(nonzeros(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{vv})));
                
            end
        end
        catch
        end
    end

    % try
    for ss = 1:length(sensor)

        subInfo.(append(sensor{ss},'smallAmp'))(ii,1) = mean(placeholder.(sensor{ss}).smallAmp);
        subInfo.(append(sensor{ss},'largeAmp'))(ii,1) = mean(placeholder.(sensor{ss}).largeAmp);
        subInfo.(append(sensor{ss},'smallVel'))(ii,1) = mean(placeholder.(sensor{ss}).smallVel);
        subInfo.(append(sensor{ss},'largeVel'))(ii,1) = mean(placeholder.(sensor{ss}).largeVel);


        % for vv = 1:2
        %     colName = append(sensor{ss},'_',vari{vv});
        %     subInfo.(colName)(ii,1) = mean(placeholder.(sensor{ss}).(vari{vv})); 
        %     % fprintf("sensor: %s, variable:, %s, mean: %2.2f\n",sensor{ss},vari{vv},mean(placeholder.(sensor{ss}).(vari{vv})))
        %     % meanStats.(sensor{ss}).(vari{vv})(ii,1) = mean(placeholder.(sensor{ss}).(vari{vv})); 
        % end
    end    
    % catch 
    % end
end
