%% 1) Loading in DHI and HC Data
clc

% CSTAR
cd('C:\Users\chose\Box\C-STAR Pilot')
addpath(genpath('CSTAR\'))
addpath(genpath('Data\'))
currentFoldPath = cd;
processPath = dir(fullfile(currentFoldPath,'\Data\Process'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

% Load CSTAR Data 
for ii = 1:numel(subjectnum)
    % Save Data into Process
    id = string(subjectnum(ii).name);
    % disp(id)   
    data.(id) = load(fullfile(subjectnum(ii).folder,subjectnum(ii).name,'data.mat'));   
end

% DHI-Lab
cd('C:\Users\chose\Box\DHI-Lab')
addpath(genpath('ProcessData\'))
currentFoldPath = cd;
processPath = dir(fullfile(currentFoldPath,'\ProcessData\Continuous'));
processPath = processPath(~ismember({processPath.name}, {'.', '..'}));
subjectnum = processPath(listdlg('PromptString',{'Select Subjects to Pull (can select multiple)',''},...
        'SelectionMode','multiple','ListString',{processPath.name}));

% Load DHI Data 
for ii = 1:numel(subjectnum)
    % Save Data into Process
    id = string(subjectnum(ii).name);
    % disp(id)   
    data.(id) = load(fullfile(subjectnum(ii).folder,subjectnum(ii).name,'data.mat'));   
end


%% Excel Sheet

subInfo = readtable("CSTAR\subject_info.xlsx",'sheet','All');

%% Mean
clc

id = subInfo.ID;
for ii = 1:length(id)
    dayNum = fieldnames(data.(id{ii}).turnData);
    for dd = 1:length(dayNum)
        try
        sensor = {'head','neck','waist'};
        for ss = 1:length(sensor)
            vari = fieldnames(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}));
            for vv = 1:2
                % fprintf("sensor: %s, variable:, %s, mean: %2.2f\n",sensor{ss},vari{vv},mean(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{vv})))               
                placeholder.(sensor{ss}).(vari{vv})(dd,1) = mean(nonzeros(data.(id{ii}).turnData.(dayNum{dd}).(sensor{ss}).(vari{vv})));
                
            end
        end
        catch
        end
    end

    try
    for ss = 1:length(sensor)
        for vv = 1:2
            colName = append(sensor{ss},'_',vari{vv});
            subInfo.(colName)(ii,1) = mean(placeholder.(sensor{ss}).(vari{vv})); 
            % fprintf("sensor: %s, variable:, %s, mean: %2.2f\n",sensor{ss},vari{vv},mean(placeholder.(sensor{ss}).(vari{vv})))
            % meanStats.(sensor{ss}).(vari{vv})(ii,1) = mean(placeholder.(sensor{ss}).(vari{vv})); 
        end
    end    
    catch 
    end
end

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

% offset = 0.01 * range(xData);
% for i = 1:height(subInfo)
%     text(xData(i) + offset, yData(i), subInfo.ID(i), 'FontSize', 8);
% end

xlabel(strrep(xVar, '_', '\_'));
ylabel(strrep(yVar, '_', '\_'));
legend("HC","mTBI")
title(sprintf('Scatter plot of %s vs %s', yVar, xVar), 'Interpreter', 'none');
saveas(gcf,append(xVar,'_',yVar),'svg')


%% Run simple t-test

[xIdx, okX] = listdlg('PromptString','Select variable for t-test:', ...
                      'SelectionMode','single', ...
                      'ListString', varName);

xVar = varName{xIdx};
xData = subInfo.(xVar);

hcData = xData(subInfo.ConcussLabel == 0);
mTBIData = xData(subInfo.ConcussLabel == 1);

% Perform two-sample t-test
[h, p, ci, stats] = ttest2(hcData, mTBIData);

fprintf('T-test results for variable %s:\n', xVar);
fprintf('p-value: %.4f\n', p);
fprintf('t-statistic: %.4f\n', stats.tstat);
fprintf('Degrees of freedom: %d\n', stats.df);
fprintf('Confidence interval: [%.4f, %.4f]\n', ci(1), ci(2));


%% Plot Ang Velocity of <30 years old

varName = subInfo.Properties.VariableNames';

% Ask user to select X variable
[xIdx, okX] = listdlg('PromptString','Select X variable:', ...
                      'SelectionMode','single', ...
                      'ListString', varName);

% Ask user to select Y variable
[yIdx, okY] = listdlg('PromptString','Select Y variable:', ...
                      'SelectionMode','single', ...
                      'ListString', varName);

% Get variable names
xVar = varName{xIdx};
yVar = varName{yIdx};

% Filter data for Age < 30
ageMask = subInfo.Age < 30;

% Apply filter
xData = subInfo.(xVar)(ageMask);
yData = subInfo.(yVar)(ageMask);
concussLabel = subInfo.ConcussLabel(ageMask);

% Plot
figure
hold on
scatter(xData(concussLabel==0), yData(concussLabel==0), 'filled');
scatter(xData(concussLabel==1), yData(concussLabel==1), 'filled');

xlabel(strrep(xVar, '_', '\_'));
ylabel(strrep(yVar, '_', '\_'));
legend("HC","mTBI")
title(sprintf('Scatter plot of %s vs %s (Age < 30)', yVar, xVar), 'Interpreter', 'none');




%% Plot violin plot freely

varName = subInfo.Properties.VariableNames';

% Ask user to select X variable
[xIdx, okX] = listdlg('PromptString','Select X variable:', ...
                      'SelectionMode','single', ...
                      'ListString', varName);
xVar = varName{xIdx};
xData = subInfo.(xVar);

% Apply filter to all relevant variables
xData = subInfo.(xVar);

% Plot violin
figure
hold on
Violin2(xData(subInfo.ConcussLabel==0),1,'Showdata',true,'Sides','Left','ShowMean',true);
Violin2(xData(subInfo.ConcussLabel==1),1,'Showdata',true,'Sides','Right','ShowMean',true);
title([strrep(xVar, '_', '\_') ]);
saveas(gcf,append("violin_",xVar),'svg')



%% Age Violin Plots

varName = subInfo.Properties.VariableNames';

% Ask user to select X variable
[xIdx, okX] = listdlg('PromptString','Select X variable:', ...
                      'SelectionMode','single', ...
                      'ListString', varName);
xVar = varName{xIdx};
xData = subInfo.(xVar);

% Apply filter to all relevant variables
ageMask = subInfo.Age <= 30;
xData = subInfo.(xVar)(ageMask);
concussLabel = subInfo.ConcussLabel(ageMask);

less30 = mes(xData(concussLabel==0),xData(concussLabel==1),'hedgesg')

% Plot violin
figure
Violin2(xData(concussLabel==0),1,'Showdata',true,'Sides','Left','ShowMean',true);
Violin2(xData(concussLabel==1),1,'Showdata',true,'Sides','Right','ShowMean',true);
ylim([70 140])
title([strrep(xVar, '_', '\_') ' (Age <= 30)']);
saveas(gcf,'less30','svg')

ageMask = subInfo.Age > 30;

% Apply filter to all relevant variables
xData = subInfo.(xVar)(ageMask);
concussLabel = subInfo.ConcussLabel(ageMask);
great30 = mes(xData(concussLabel==0),xData(concussLabel==1),'hedgesg')

figure
Violin2(xData(concussLabel==0),1,'Showdata',true,'Sides','Left','ShowMean',true);
Violin2(xData(concussLabel==1),1,'Showdata',true,'Sides','Right','ShowMean',true);
ylim([70 140])
title([strrep(xVar, '_', '\_') ' (Age > 30)']);
saveas(gcf,'greater30','svg')


%% descriptive stats
clc

fprintf("Control: %1.0f\n",length(find(subInfo.ConcussLabel==0)))
fprintf("Control Age: %1.1f (%1.1f)\n",mean(subInfo.Age(subInfo.ConcussLabel==0)),std(subInfo.Age(subInfo.ConcussLabel==0)))
fprintf("Control number of Females: %1.0f\n",length(find(strcmp(subInfo.Sex(subInfo.ConcussLabel==0),'F')==1)))

fprintf("Control NSI: %1.1f (%1.1f)\n",mean(subInfo.NSI_Score(subInfo.ConcussLabel==0),"omitnan"),std(subInfo.NSI_Score(subInfo.ConcussLabel==0),"omitnan"))
fprintf("Control miniBEST: %1.1f (%1.1f)\n",mean(subInfo.MiniBEST(subInfo.ConcussLabel==0),"omitnan"),std(subInfo.MiniBEST(subInfo.ConcussLabel==0),"omitnan"))
fprintf("Control DHI: %1.1f (%1.1f)\n",mean(subInfo.DHI(subInfo.ConcussLabel==0),"omitnan"),std(subInfo.DHI(subInfo.ConcussLabel==0),"omitnan"))

fprintf("mTBI: %1.0f\n",length(find(subInfo.ConcussLabel==1)))
fprintf("mTBI Age: %1.1f (%1.1f)\n",mean(subInfo.Age(subInfo.ConcussLabel==1)),std(subInfo.Age(subInfo.ConcussLabel==1)))
fprintf("mTBI Number of Females: %1.0f\n",length(find(strcmp(subInfo.Sex(subInfo.ConcussLabel==1),'F')==1)))

fprintf("mTBI NSI: %1.1f (%1.1f)\n",mean(subInfo.NSI_Score(subInfo.ConcussLabel==1)),std(subInfo.NSI_Score(subInfo.ConcussLabel==1)))
fprintf("mTBI miniBEST: %1.1f (%1.1f)\n",mean(subInfo.MiniBEST(subInfo.ConcussLabel==1)),std(subInfo.MiniBEST(subInfo.ConcussLabel==1)))
fprintf("mTBI DHI: %1.1f (%1.1f)\n",mean(subInfo.DHI(subInfo.ConcussLabel==1)),std(subInfo.DHI(subInfo.ConcussLabel==1)))


%% Hedge's G - Pairwise Effect sizes

% stats = mes(data.x_fgaScore_(data.x_label_==0),data.x_fgaScore_(data.x_label_==1),'hedgesg')
stats = mes(subInfo.head_angVelocity(subInfo.ConcussLabel==0),subInfo.head_angVelocity(subInfo.ConcussLabel==1),'hedgesg')

%% glm

subInfo.Sex = categorical(subInfo.Sex);
subInfo.ConcussLabel = categorical(subInfo.ConcussLabel);
subInfo.adjustedAge = subInfo.Age - mean(subInfo.Age);
% 
% glm = fitglm(subInfo, 'waist_amplitude ~ 1 + Sex + Age*ConcussLabel')
% glm = fitglm(subInfo, 'waist_amplitude ~ 1 + Sex + Age*ConcussLabel')
glm = fitglm(subInfo, 'head_angVelocity ~ 1 + Sex + Age*ConcussLabel')

%%
youngMask = subInfo.Age > 30;
youngData = subInfo(youngMask, :);  % This creates a filtered table

% Ensure categorical variables are preserved
youngData.Sex = categorical(youngData.Sex);
youngData.ConcussLabel = categorical(youngData.ConcussLabel);
youngData.adjustedAge = youngData.Age - mean(youngData.Age);

% Fit GLMs on filtered data
% glm1 = fitglm(youngData, 'waist_amplitude ~ 1 + Sex + Age*ConcussLabel');
glm2 = fitglm(youngData, 'head_angVelocity ~ 1 + Sex + Age*ConcussLabel')























%% OLD

%% Load Data In
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

% Small v Large Turns

mtbi_ID = {'DHI003','DHI007','DHI008','DHI009','DHI010','DHI011','DHI012','DHI015','DHI016'};
for i = 1:length(mtbi_ID)
    mtbi.(mtbi_ID{i}) = data.(mtbi_ID{i});    
end
data = rmfield(data,mtbi_ID);

%% mean
id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    
    for dd = 1:length(day)
        try
        idx_n = find(data.(id{ii}).turnData.(day{dd}).head.amplitude<40);
        idx_x = find(data.(id{ii}).turnData.(day{dd}).head.amplitude>40);

        smallTurnAmp(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
        largeTurnAmp(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
        % ang Velocity
        smallTurnVel(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
        largeTurnVel(dd) = mean(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));

        % number of turns
        numOfTurns(dd) = length(data.(id{ii}).turnData.(day{dd}).head.amplitude);
        catch
        end
    end
    stat.smallTurnAmp(ii) = mean(nonzeros(smallTurnAmp));
    stat.largeTurnAmp(ii) = mean(nonzeros(largeTurnAmp));
    stat.smallTurnVel(ii) = mean(nonzeros(smallTurnVel));
    stat.largeTurnVel(ii) = mean(nonzeros(largeTurnVel));
    stat.numOfTurns(ii) = mean(nonzeros(numOfTurns));

end


id = fieldnames(mtbi);
for ii = 1:length(id)
    day = fieldnames(mtbi.(id{ii}).turnData);
    
    for dd = 1:length(day)
        try
            idx_n = find(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude<40);
            idx_x = find(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude>40);
            % amplitude
            smallTurnAmp(dd) = mean(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
            largeTurnAmp(dd) = mean(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
            % ang velocity
            smallTurnVel(dd) = mean(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
            largeTurnVel(dd) = mean(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));

            % number of turns
            numOfTurns(dd) = length(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude);
        catch 
        end
    end
    mstat.smallTurnAmp(ii) = mean(nonzeros(smallTurnAmp));
    mstat.largeTurnAmp(ii) = mean(nonzeros(largeTurnAmp));
    mstat.smallTurnVel(ii) = mean(nonzeros(smallTurnVel));
    mstat.largeTurnVel(ii) = mean(nonzeros(largeTurnVel));
    mstat.numOfTurns(ii) = mean(nonzeros(numOfTurns));
end

%% median

id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    try
        for dd = 1:length(day)
            idx_n = find(data.(id{ii}).turnData.(day{dd}).head.amplitude < 45);
            idx_x = find(data.(id{ii}).turnData.(day{dd}).head.amplitude > 45);

            smallTurnAmp(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
            largeTurnAmp(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
            % ang Velocity
            smallTurnVel(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
            largeTurnVel(dd) = median(nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));
        end
        stat.smallTurnAmp(ii) = median(nonzeros(smallTurnAmp));
        stat.largeTurnAmp(ii) = median(nonzeros(largeTurnAmp));
        stat.smallTurnVel(ii) = median(nonzeros(smallTurnVel));
        stat.largeTurnVel(ii) = median(nonzeros(largeTurnVel));
    catch
    end
end

id = fieldnames(mtbi);
for ii = 1:length(id)
    day = fieldnames(mtbi.(id{ii}).turnData);
    for dd = 1:length(day)
        try
            idx_n = find(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude < 40);
            idx_x = find(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude > 40);
            % amplitude
            smallTurnAmp(dd) = median(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude(idx_n)));
            largeTurnAmp(dd) = median(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude(idx_x)));
            % ang velocity
            smallTurnVel(dd) = median(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_n)));
            largeTurnVel(dd) = median(nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity(idx_x)));
        catch
        end
    end
    mstat.smallTurnAmp(ii) = median(nonzeros(smallTurnAmp));
    mstat.largeTurnAmp(ii) = median(nonzeros(largeTurnAmp));
    mstat.smallTurnVel(ii) = median(nonzeros(smallTurnVel));
    mstat.largeTurnVel(ii) = median(nonzeros(largeTurnVel));
end

%% Mean with all turn with NO binning

id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    try
        for dd = 1:length(day)
            % amplitude
            ampData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude);
            allAmp(dd) = median(ampData);
            % angular velocity
            velData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity);
            allVel(dd) = median(velData);
        end
        stat.medallAmp(ii) = median(nonzeros(allAmp));
        stat.medallVel(ii) = median(nonzeros(allVel));
    catch
    end
end

id = fieldnames(mtbi);
for ii = 1:length(id)
    day = fieldnames(mtbi.(id{ii}).turnData);
    for dd = 1:length(day)
        try
            % amplitude
            ampData = nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude);
            allAmp(dd) = median(ampData);
            % angular velocity
            velData = nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity);
            allVel(dd) = median(velData);
        catch
        end
    end
    mstat.medallAmp(ii) = median(nonzeros(allAmp));
    mstat.medallVel(ii) = median(nonzeros(allVel));
end

%% Mean of all turns

id = fieldnames(data);
for ii = 1:length(id)
    day = fieldnames(data.(id{ii}).turnData);
    try
        for dd = 1:length(day)
            % amplitude
            ampData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.amplitude);
            allAmp(dd) = mean(ampData);
            % angular velocity
            velData = nonzeros(data.(id{ii}).turnData.(day{dd}).head.angVelocity);
            allVel(dd) = mean(velData);
        end
        stat.meanallAmp(ii) = mean(nonzeros(allAmp));
        stat.meanallVel(ii) = mean(nonzeros(allVel));
    catch
    end
end

id = fieldnames(mtbi);
for ii = 1:length(id)
    day = fieldnames(mtbi.(id{ii}).turnData);
    for dd = 1:length(day)
        try
            % amplitude
            ampData = nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.amplitude);
            allAmp(dd) = mean(ampData);
            % angular velocity
            velData = nonzeros(mtbi.(id{ii}).turnData.(day{dd}).head.angVelocity);
            allVel(dd) = mean(velData);
        catch
        end
    end
    mstat.meanallAmp(ii) = mean(nonzeros(allAmp));
    mstat.meanallVel(ii) = mean(nonzeros(allVel));
end




%% Scatter Plot Small V Big turns
close all

figure
hold on
scatter(stat.smallTurnAmp,stat.largeTurnAmp,'filled')
scatter(mstat.smallTurnAmp,mstat.largeTurnAmp,'filled')
xlabel('Small Turn Amp (deg)')
ylabel('Large Turn Amp (deg)')
xlim([10 40])
ylim([40 300])
% ylim([50 100])
legend("HC","mTBI")
title("Amplitude 40 deg Large v Small")

figure
hold on
scatter(stat.smallTurnVel,stat.largeTurnVel,'filled')
scatter(mstat.smallTurnVel,mstat.largeTurnVel,'filled')
xlabel('Small Turn Amp (deg/s)')
ylabel('Large Turn Amp (deg/s)')
xlim([30 90])
ylim([40 200])
legend("HC","mTBI")
title("AngVelocity of small v Large 40 deg")

%%

close all

% Plot for Amplitude
figure
hold on
scatter(stat.medallAmp, stat.medallVel, 'filled')  % Healthy control (HC)
scatter(mstat.medallAmp, mstat.medallVel, 'filled')  % mTBI
xlabel('med Amplitude (deg)')
ylabel('med Angular Velocity (deg/s)')
xlim([10 150])
ylim([10 150])
legend("HC", "mTBI")
title("med Amplitude vs med Angular Velocity")

% Plot for Angular Velocity
figure
hold on
scatter(stat.meanallAmp, stat.meanallVel, 'filled')  % Healthy control (HC)
scatter(mstat.meanallAmp, mstat.meanallVel, 'filled')  % mTBI
xlabel('Mean Amplitude (deg)')
ylabel('Mean Angular Velocity (deg/s)')
xlim([10 150])
ylim([10 150])
legend("HC", "mTBI")
title("Mean Angular Velocity of Turns")

%% Plot for Number Of Turns
figure
hold on
scatter(nonzeros(stat.numOfTurns), nonzeros(stat.numOfTurns), 'filled')  % Healthy control (HC)
scatter(nonzeros(mstat.numOfTurns), nonzeros(mstat.numOfTurns), 'filled')  % mTBI
% xlabel('Mean Amplitude (deg)')
% ylabel('Mean Angular Velocity (deg/s)')
% xlim([10 150])
% ylim([10 150])
legend("HC", "mTBI")
title("Mean Angular Velocity of Turns")

%% t-test  

disp(["Mean of HC Num of Turns ", mean(nonzeros(stat.numOfTurns)), std(nonzeros(stat.numOfTurns))])
disp(["Mean of mTBI Num of Turns ", mean(nonzeros(mstat.numOfTurns)), std(nonzeros(mstat.numOfTurns))])
disp("T-Test Number of Turns")
[~, p, ci, ~] = ttest2(nonzeros(stat.numOfTurns), nonzeros(mstat.numOfTurns))



disp(["Mean of HC Amplitude ", mean(nonzeros(stat.meanallAmp)), std(nonzeros(stat.meanallAmp))])
disp(["Mean of mTBI Amplitude ", mean(nonzeros(mstat.meanallAmp  )), std(nonzeros(mstat.meanallAmp))])
disp("T-Test Turn Amplitude")
[~, p, ci, ~] = ttest2(nonzeros(stat.meanallAmp), nonzeros(mstat.meanallAmp))

disp(["Mean of HC Ang Velocity", mean(nonzeros(stat.meanallVel)), std(nonzeros(stat.meanallVel))])
disp(["Mean of mTBI Ang Velocity", mean(nonzeros(mstat.meanallVel  )), std(nonzeros(mstat.meanallVel))])
disp("T-Test Turn Ang Velocity")
[~, p, ci, ~] = ttest2(nonzeros(stat.meanallVel), nonzeros(mstat.meanallVel))


%% mtbi symptom scores

mtbi_symptoms = scores([2 6 7 8 9 10 11],:);
close all

figure
nexttile
plot(mstat.medallVel,mtbi_symptoms.nsi_total_score,'*')
xlabel("median ang Velocity")
ylabel("NSI Score")
% Add text labels at each data point
for i = 1:length(mstat.medallVel)
    text(mstat.medallVel(i), mtbi_symptoms.nsi_total_score(i), mtbi_ID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
nexttile
plot(mstat.medallVel,mtbi_symptoms.qolibri_100,'*')
xlabel("median ang Velocity")
ylabel("Qolibri Score")
% Add text labels at each data point
for i = 1:length(mstat.medallVel)
    text(mstat.medallVel(i), mtbi_symptoms.qolibri_100(i), mtbi_ID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

%%mtbi_symptoms = nsiquolibriScores([2 6 7 8 9 10 11],:);
close all

figure
nexttile
plot(mstat.largeTurnVel,mtbi_symptoms.nsi_total_score,'*')
xlabel("large mean ang Velocity")
ylabel("NSI Score")
% Add text labels at each data point
for i = 1:length(mstat.largeTurnVel)
    text(mstat.largeTurnVel(i), mtbi_symptoms.nsi_total_score(i), mtbi_ID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end
nexttile
plot(mstat.largeTurnVel,mtbi_symptoms.qolibri_100,'*')
xlabel("large mean ang Velocity")
ylabel("Qolibri Score")
% Add text labels at each data point
for i = 1:length(mstat.largeTurnVel)
    text(mstat.largeTurnVel(i), mtbi_symptoms.qolibri_100(i), mtbi_ID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
end

%% Cycle through every score

scoreNames = mtbi_symptoms.Properties.VariableNames;

figure
for ss = 2:length(scoreNames)
    
    nexttile
    plot(mstat.medallVel,mtbi_symptoms.(scoreNames{ss}),'*')
    xlabel("large mean ang Velocity")
    ylabel(scoreNames{ss})
    % % Add text labels at each data point
    for i = 1:length(mstat.largeTurnVel)
        text(mstat.medallVel(i), mtbi_symptoms.(scoreNames{ss})(i), mtbi_ID{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
    end
end

%% Look At trunk turn
clc
% Stable v Volitional
id = fieldnames(data);
for ii = 1:length(id)
    days = fieldnames(data.(id{ii}).turnData);
    sensor = "waist";
    for dd = 1:length(days)
        try
            variables = fieldnames(data.(id{ii}).turnData.(days{dd}).(sensor));
            for vv = 1:2%length(variables)               
                meanVar.(id{ii}).(variables{vv})(dd) = mean(data.(id{ii}).turnData.(days{dd}).(sensor).(variables{vv}));  
            end
        catch
        end
    end
    for vv = 1:2%length(variables)               
        waist.(variables{vv})(ii,1) = mean(meanVar.(id{ii}).(variables{vv}));  
    end
        % stdVar.(id{ii}).(segment{ss}).(turnType{tt}).(variables{vv})(dd) = std(data.(id{ii}).(segment{ss}).(days{dd}).(turnType{tt}).(variables{vv}));
        % meanVar.(id{ii}).(segment{ss}).(turnType{tt}).count(dd) =  length(data.(id{ii}).(segment{ss}).(days{dd}).(turnType{tt}).(variables{vv}));
end

%%
clc
close all
subInfo = readtable("DHIsubjectInfo.xlsx");

healthyStat.amplitude = waist.amplitude(subInfo.ConcussLabel==0);
healthyStat.angVelocity = waist.angVelocity(subInfo.ConcussLabel==0);
concussStat.amplitude = waist.amplitude(subInfo.ConcussLabel==1);
concussStat.angVelocity = waist.angVelocity(subInfo.ConcussLabel==1);

subInfo.labAmplitude = waist.amplitude;
subInfo.labAngVelocity = waist.angVelocity;

figure
hold on
scatter(waist.angVelocity(subInfo.ConcussLabel==0),waist.amplitude(subInfo.ConcussLabel==0))
scatter(waist.angVelocity(subInfo.ConcussLabel==1),waist.amplitude(subInfo.ConcussLabel==1))
legend("HC","mTBI")
xlabel("angVelocity")
ylabel("amplitude")
title("Lumbar AngVel vs Amplitude")
